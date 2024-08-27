import 'dart:async';
import 'package:e_bike/data/gattservice.dart';
import 'package:e_bike/data/notificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class FireWall extends StatefulWidget {
  const FireWall({super.key});

  @override
  State<FireWall> createState() => _FireWallState();
}

class _FireWallState extends State<FireWall> {
  Timer? _timer;

  List<String> _groupedBytes = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData(); // Fetch initial data
    _startReadingData(); // Start periodic updates
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    print(groupedBytes.length);
    if (groupedBytes.length < 5) {
      // Handle the case where the data is too short
      print('Data length is too short');
      return;
    }



    // Store the parsed bytes in the devices list
    setState(() {


      _groupedBytes = groupedBytes ;
      print('----$_groupedBytes----');
    });
  }
  String chunk ="";
  String convert(String s){
    // print(s);
  String chunk = int.parse(s, radix: 16).toString();
  // print(chunk);


return chunk;
  }
  @override
  Widget build(BuildContext context) {
    // Define a color palette
    const Color primaryColor = Colors.blueAccent;
    const Color secondaryColor = Colors.white;
    const Color accentColor = Colors.orangeAccent;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Firmware ',
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard('SOH',  _groupedBytes.isNotEmpty ?  convert(_groupedBytes[58]): '*', width: 125, height: 100),
                        _buildInfoCard('SOC',  _groupedBytes.isNotEmpty ? convert(_groupedBytes[59]): '*', width: 150, height: 100),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInfoCard('Speed', _groupedBytes.isNotEmpty ? convert(_groupedBytes[1]) : '*', width: 150, height: 100),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard('ODO', _groupedBytes.length > 3 ? convert('${_groupedBytes[3]}${_groupedBytes[4]} ') : '*', width: 150, height: 100),
                        _buildInfoCard('Trip', _groupedBytes.length > 6 ? convert('${_groupedBytes[6]}${_groupedBytes[7]}') : '*', width: 150, height: 100),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInfoCard('Temperature', _groupedBytes.length > 32 ? convert(_groupedBytes[14]) : '*', width: 170, height: 100),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCard('BMS', _groupedBytes.length > 14 ? convert('${_groupedBytes[32]}${_groupedBytes[33]}') : '*', width: 150, height: 100),
                        _buildInfoCard('MOS', _groupedBytes.length > 27 ? convert(_groupedBytes[27]) : '*', width: 150, height: 100),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard('Current', _groupedBytes.length > 42 ? convert('${_groupedBytes[42]}${_groupedBytes[43]}') : '*', width: 150, height: 100),
                        _buildInfoCard('Voltage', _groupedBytes.length > 34 ? convert('${_groupedBytes[34]}${_groupedBytes[35]}') : '*', width: 150, height: 100),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '© 2024 E-Bike Inc. All rights reserved.',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle,
      {double width = 100, double height = 80}) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        color: Colors.white.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueAccent.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
