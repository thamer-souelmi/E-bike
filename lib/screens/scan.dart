import 'dart:async';
import 'package:e_bike/provider/notificationService.dart';
import 'package:e_bike/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();
  List<DiscoveredDevice> devices = [];
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  bool isScanning = false;
  bool isConnected = false;
  bool connecting = false;
  String? connectedDeviceId;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _listenToBluetoothState();
    scan();
  }

  void _listenToBluetoothState() {
    flutterReactiveBle.statusStream.listen((status) {
      if (!mounted) return;
      if (status == BleStatus.poweredOff || status == BleStatus.locationServicesDisabled) {
        _handleBluetoothOff();
      } else {
        // Bluetooth is on, you can continue BLE operations
      }
    }, onError: (error) {
      print('Bluetooth state stream error: $error');
    });
  }

  void _handleBluetoothOff() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bluetooth is off. Please turn it on to continue.'),
      ),
    );

    setState(() {
      isConnected = false;
      connecting = false;
    });
  }

  void connect(DiscoveredDevice device) {
    try {
      _connectionSubscription?.cancel();  // Ensure the previous subscription is cancelled
    } catch (e) {
      print('Error cancelling previous connection: $e');
    }

    setState(() {
      connecting = true;
      isScanning = false;
    });

    _connectionSubscription = flutterReactiveBle.connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 5),
    ).listen((connectionState) async {
      try {
        if (connectionState.connectionState == DeviceConnectionState.connected) {
          if (!mounted) return;
          setState(() {
            isConnected = true;
            connectedDeviceId = device.id;
            print('Connected to ${device.name}');
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const Home(),
            ));
            context.read<NotificationService>().setConnectedDevice(device);
          });
        }
      } catch (e) {
        print('Error during connection: $e');
        if (mounted) {
          setState(() {
            connecting = false;
          });
        }
      }
      if (connectionState.connectionState == DeviceConnectionState.disconnected) {
        setState(() {
          isConnected = false;
          connectedDeviceId = null;
        });
        print('Disconnected from ${device.name}');
      }
    }, onError: (error) {
      print('Connection error: $error');
      if (mounted) {
        setState(() {
          connecting = false;
          isConnected = false;
        });
      }
    });
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetooth]!.isGranted && statuses[Permission.location]!.isGranted) {
      scan();
    } else {
      const Text("open Bluetooth");
    }
  }

  Future<void> disconnect(String deviceId) async {
    try {
      print('Disconnecting from device: $deviceId');
      await _connectionSubscription?.cancel();
      print('Disconnected');
    } on Exception catch (e) {
      print("Error disconnecting from a device: $e");
    } finally {
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
  }

  Future<void> scan() async {
    devices.clear();

    setState(() {
      isScanning = true;
      connecting = false;
      _connectionSubscription?.cancel();
    });

    if (isConnected) {
      _connectionSubscription?.cancel();
      await disconnect(connectedDeviceId!);
    }

    flutterReactiveBle.scanForDevices(
      scanMode: ScanMode.lowLatency,
      withServices: [],
    ).listen((device) {
      if (mounted) {
        setState(() {
          if (!devices.any((d) => d.id == device.id) && device.name.startsWith('e')) {
            devices.add(device);
          }
        });
      }
    }, onError: (error) {
      print('Error: $error');
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();  // Cancel any active connections
    _deviceConnectionController.close();  // Close the stream controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.blueAccent;
    const Color accentColor = Colors.orangeAccent;
    final Color secondaryColor = Colors.white;

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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Scan for bike',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                    shadows: const [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isScanning ? null : scan,
                child: Text(isScanning ? 'Scanning...' : 'Scan'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: devices.isNotEmpty
                    ? ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Card(
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      child: ListTile(
                        title: Text(device.name),
                        subtitle: Text(device.id),
                        trailing: TextButton(
                          onPressed: () => connect(device),
                          child: const Text('Connect'),
                        ),
                      ),
                    );
                  },
                )
                    : Center(
                  child: Text(isScanning ? 'Scanning for devices...' : 'No devices found.'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '© 2024 E-Bike Inc. All rights reserved.',
                  style: TextStyle(
                    color: secondaryColor.withOpacity(0.7),
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
