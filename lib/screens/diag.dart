import 'dart:async';
import 'dart:io';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:e_bike/data/gattservice.dart';
import 'package:e_bike/data/notificationService.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Diag extends StatefulWidget {
  const Diag({super.key});

  @override
  State<Diag> createState() => _FireWallState();
}

class _FireWallState extends State<Diag> {
  Timer? _timer;
  List<String> _groupedBytes = [];
  final Excel _excel = Excel.createExcel(); // Create an Excel instance
  int _rowIndex = 0;
  bool _isSaving = false;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _fetchInitialData(); // Fetch initial data
    _startReadingData(); // Start periodic updates
    _requestPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    _saveTimer?.cancel();

  }

  void _addDataToExcel() {
    final sheet = _excel['Sheet1'];

    // Add data row with specific metrics
    sheet.appendRow([
      _groupedBytes.length > 58 ? convertToPercentage(_groupedBytes[58]) : '0', // SOC
      _groupedBytes.length > 59 ? convertToPercentage(_groupedBytes[59]) : '0', // SOH
      _groupedBytes.length > 3 ? convertToPercentage('${_groupedBytes[3]}${_groupedBytes[4]}') / 100 : '0', // ODO
      _groupedBytes.isNotEmpty ? convertToPercentage(_groupedBytes[1]) : '0', // Speed
      _groupedBytes.length > 6 ? convertToPercentage('${_groupedBytes[6]}${_groupedBytes[7]}') / 100 : '0', // Trip
      _groupedBytes.length > 14 && convertToPercentage(_groupedBytes[14])>0
          ? "${(convertToPercentage(_groupedBytes[14]))} °C"
          : '0°C', // MTR
      _groupedBytes.length > 32 &&convertToPercentage('${_groupedBytes[32]}${_groupedBytes[33]}')>0
          ? "${(formatToTwoDecimalPlaces('${_groupedBytes[32]}${_groupedBytes[33]}'))} °C"
          : '0°C', // BMS
      _groupedBytes.length > 27 && convertToPercentage(_groupedBytes[27]) >0
          ? "${(convertToPercentage(_groupedBytes[27]))} °C"
          : '0°C',// MOS
      _groupedBytes.length > 42 ? convertToPercentage('${_groupedBytes[42]}${_groupedBytes[43]}') : '0', // Current
      _groupedBytes.length > 34 ? convertToPercentage('${_groupedBytes[34]}${_groupedBytes[35]}') : '0', // Voltage
    ]);

    _rowIndex++;
  }


  Future<void> _requestPermission() async {
    // For Android 10 and above (API level 29+)
    if (await Permission.storage.request().isGranted) {
      print('Storage permission granted');
    } else {
      print('Storage permission denied');
    }

    // If you need to manage all files on Android 11 and above
    if (await Permission.manageExternalStorage.request().isGranted) {
      print('Manage external storage permission granted');
    } else {
      print('Manage external storage permission denied');
    }
  }

  Future<void> _startSavingToExcel() async {
    _isSaving = true; // Set saving flag to true

    final sheet = _excel['Sheet1'];

    // Add headers if they don't already exist
    if (sheet.maxRows == 0) {
      sheet.appendRow([
        'SOC',
        'SOH',
        'ODO',
        'Speed',
        'Trip',
        'MTR Temp',
        'BMS Temp',
        'MOS Temp',
        'Current',
        'Voltage',
      ]);
    }

    _saveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSaving) {
        _addDataToExcel(); // Call the updated method to add data
      } else {
        timer.cancel(); // Stop the timer if saving is stopped
      }
    });
  }


  Future<void> _stopAndSaveExcel() async {
    _isSaving = false; // Set saving flag to false

    // Generate a unique filename using timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '/storage/emulated/0/Download/e_bike_data_$timestamp.xlsx';

    // Save the file
    var fileBytes = _excel.save();
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    print('Data saved to $path');
  }


  Future<void> _saveDataToExcel() async {
    if (!_isSaving) {
      await _startSavingToExcel(); // Start saving data if not already started
    } else {
      await _stopAndSaveExcel(); // Stop saving and save the Excel file
    }
  }

  Future<void> _fetchInitialData() async {
    final device = context.read<NotificationService>().connectedDevice;
    if (device != null) {
      Gattservice gattservice = Gattservice();
      try {
        final data = await gattservice.readCharacteristic(
          deviceId: device.id,
          serviceId: Uuid.parse('1166'),
          characteristicId: Uuid.parse('8800'),
        );
        await _processDeviceData(data);
      } catch (e) {
        // Handle any errors
        print('Error reading data: $e');
      }
    } else {
      // Handle the case when no device is connected
      print('No device connected');
    }
  }

  void _startReadingData() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchDeviceData();
    });
  }

  Future<void> _fetchDeviceData() async {
    final device = context.read<NotificationService>().connectedDevice;
    if (device != null) {
      Gattservice gattservice = Gattservice();
      try {
        final data = await gattservice.readCharacteristic(
          deviceId: device.id,
          serviceId: Uuid.parse('1166'),
          characteristicId: Uuid.parse('8800'),
        );
        await _processDeviceData(data);
      } catch (e) {
        // Handle any errors
        print('Error reading data: $e');
      }
    } else {
      // Handle the case when no device is connected
      print('No device connected');
    }
  }

  Future<void> _processDeviceData(String hexString) async {
    hexString = hexString
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('-', '');

    List<String> groupedBytes = [];
    for (int i = 0; i < hexString.length; i += 2) {
      String chunk = hexString.substring(i, i + 2);
      groupedBytes.add(chunk);
    }

    if (groupedBytes.length < 5) {
      print('Data length is too short');
      return;
    }

    setState(() {
      _groupedBytes = groupedBytes;
    });
  }

  int convertToPercentage(String s) {
    return (int.parse(s, radix: 16));
  }
  String formatToTwoDecimalPlaces(String s) {
    int i = (int.parse(s, radix: 16));
   double res = i/10 -273.15 ;
    print("------------- ${res.toStringAsFixed(2)}");
     return res.toStringAsFixed(2);
  }
  int extractLast3Bits(String hexString) {
    // Convert the hex string to an integer
    print('hexStringgggggggggg : $hexString');
    int hexValue = int.parse(hexString, radix: 16);

    // Extract the last 3 bits using a bitwise AND with 0x07 (binary 00000111)
    int last3Bits = hexValue & 0x07;
  print('result $last3Bits');
    return last3Bits;
  }

  @override
  Widget build(BuildContext context) {
     int batteryPercentage = _groupedBytes.length > 59
        ? int.parse(_groupedBytes[59], radix: 16)
        : 0;
    // final
      int stateofhealth = _groupedBytes.length > 59 ?
      int.parse(_groupedBytes[58], radix: 16): 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Diag',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black26,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        BatteryIndicator(
                          batteryFromPhone: false,
                          batteryLevel: stateofhealth,
                          style: BatteryIndicatorStyle.flat,
                          colorful: true,
                          showPercentNum: false,
                          mainColor: Colors.white,
                          size: 25.0,
                          ratio: 3.0,
                          showPercentSlide: true,
                        ),
                        Text(
                          'SOH $stateofhealth%',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10,),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        BatteryIndicator(
                          batteryFromPhone: false,
                          batteryLevel: batteryPercentage,
                          style: BatteryIndicatorStyle.flat,
                          colorful: true,
                          showPercentNum: false,
                          mainColor: Colors.white,
                          size: 25.0,
                          ratio: 3.0,
                          showPercentSlide: true,
                        ),
                        Text(
                          'SOC $batteryPercentage%',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 180, // Adjust the width as needed
                          height: 80, // Adjust the height as needed
                          child: _buildMetricCard1(
                            Icons.info,
                            _groupedBytes.isNotEmpty
                                ? "${extractLast3Bits( _groupedBytes[0])} "
                                : '0 ',
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 200, // Adjust the width as needed
                          height: 80, // Adjust the height as needed
                          child: _buildMetricCard1(
                            Icons.speed,

                            _groupedBytes.isNotEmpty
                                ? "${convertToPercentage(_groupedBytes[1])} km/h"
                                : '0 km/h',
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Second row: ODO, Speed, Trip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              Icons.refresh,
                              'ODO',
                              _groupedBytes.length > 6
                                  ? "${(convertToPercentage('${_groupedBytes[6]}${_groupedBytes[7]}'))/100}"
                                  : '0',
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Expanded(
                          //   child: _buildMetricCard(
                          //     Icons.speed,
                          //     '',
                          //     _groupedBytes.isNotEmpty
                          //         ? "${convertToPercentage(_groupedBytes[1])} km/h"
                          //         : '0 km/h',
                          //   ),
                          // ),
                          // const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              Icons.trip_origin,
                              'Trip',
                              _groupedBytes.length > 3
                                  ? "${convertToPercentage('${_groupedBytes[3]}${_groupedBytes[4]}')} km"
                                  : '0 km',

                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      // Third row: MTR, BMS, MOS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              Icons.thermostat,
                              'MTR',
                              _groupedBytes.length > 32 && convertToPercentage(_groupedBytes[14])>0
                                  ? "${(convertToPercentage(_groupedBytes[14]))} °C"
                                  : '0°C',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              Icons.thermostat,
                              'BMS',
                              _groupedBytes.length > 14 && convertToPercentage('${_groupedBytes[32]}${_groupedBytes[33]}')>0
                                  ? "${(formatToTwoDecimalPlaces('${_groupedBytes[32]}${_groupedBytes[33]}'))} °C"
                                  : '0°C',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              Icons.thermostat,
                              'MOS',
                              _groupedBytes.length > 27 && convertToPercentage(_groupedBytes[27]) >0
                                  ? "${(convertToPercentage(_groupedBytes[27]))} °C"
                                  : '0°C',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      // Fourth row: Current, Voltage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              Icons.electrical_services,
                              'Current',
                              _groupedBytes.length > 42
                                  ? "${convertToPercentage('${_groupedBytes[42]}${_groupedBytes[43]}')} mA"
                                  : '0 mA',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              Icons.power,
                              'Voltage',
                              _groupedBytes.length > 34
                                  ? "${convertToPercentage('${_groupedBytes[34]}${_groupedBytes[35]}')} mV"
                                  : '0 mV',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ElevatedButton(
            onPressed: _saveDataToExcel,
            child: Text(_isSaving ? 'Saving ...' : 'Save to Excel'),
          ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    '© 2024 E-Bike Inc. All rights reserved.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.0,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildMetricCard1(IconData icon,  String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.0,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 8),
            // const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
