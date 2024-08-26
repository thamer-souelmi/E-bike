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
  List<String> devices = [];
  List<String> displayedData = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startReadingData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startReadingData() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchDeviceData();
    });
  }

  Future<void> _fetchDeviceData() async {
    final device = context
        .read<NotificationService>()
        .connectedDevice;

    if (device != null) {
      Gattservice gattservice = Gattservice();

      try {
        final data = await gattservice.readCharacteristic(
          deviceId: device.id,
          serviceId: Uuid.parse('1166'),
          characteristicId: Uuid.parse('8800'),
        );
        await processDeviceData(data);
      } catch (e) {
        // Handle any errors
        print('Error reading data: $e');
      }
    } else {
      // Handle the case when no device is connected
      print('No device connected');
    }
  }

  Future<void> processDeviceData(String hexString) async {
    hexString =
        hexString.replaceAll('[', '').replaceAll(']', '').replaceAll('-', '');

    // Group bytes into chunks of 2 characters (1 byte)
    List<String> groupedBytes = [];
    for (int i = 0; i < hexString.length; i += 2) {
      String chunk = hexString.substring(i, i + 2);
      groupedBytes.add(chunk);
    }

    if (groupedBytes.length < 5) {
      // Handle the case where the data is too short
      print('Data length is too short');
      return;
    }

    // Parse the bytes
    String sof = groupedBytes[0];
    String orByte = groupedBytes[1];
    String idByte = groupedBytes[2];
    String sizeByte = groupedBytes[3];
    String crcByte = groupedBytes.last;
    List<String> dataBytes = groupedBytes.sublist(4, groupedBytes.length - 1);

    // Store the parsed bytes in the devices list
    setState(() {
      devices = [
        'SOF: $sof',
        'O-R: $orByte',
        'ID: $idByte',
        'Size: $sizeByte',
        'CRC: $crcByte',
      ];
      displayedData = dataBytes;
    });
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
              const Text(
                'FireWall',
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
              const SizedBox(height: 20),
              // Expanded widget ensures the scrollable area takes up the remaining space
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Display non-data bytes (SOF, O-R, ID, Size, CRC)
                      ...devices.map((device) =>
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              device,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          )),
                      const SizedBox(height: 20),
                      // Display data bytes together on a single line
                      if (displayedData.isNotEmpty)
                        Text(
                          'Data: ${displayedData.join(' ')}',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 18),
                        ),
                    ],
                  ),
                ),
              ),
              // Footer stays at the bottom of the screen
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
}