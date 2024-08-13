import 'dart:async';
import 'package:e_bike/screens/devices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  // @override
  // Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();
  List<DiscoveredDevice> devices = [];
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  bool isScanning = false;
  bool isConnected = false;
  bool connecting = false ;
  String? connectedDeviceId;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _listenToBluetoothState();
     scan();
    _connectionSubscription?.cancel();

  }
  void _listenToBluetoothState() {
    flutterReactiveBle.statusStream.listen((status) {
      if (!mounted) return; // Add this check
      if (status == BleStatus.poweredOff || status == BleStatus.locationServicesDisabled) {
        _handleBluetoothOff();
// Bluetooth is on, you can continue BLE operations
      } else {
      }
    }, onError: (error) {
      print('Bluetooth state stream error: $error');
    });
  }

  void _handleBluetoothOff() {
    if (!mounted) return;  // Add this check

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
      _connectionSubscription?.cancel();
      // if(isConnected) {
      //   disconnect(connectedDeviceId!);
      // }
      // Ensure the previous subscription is cancelled
    } catch (e) {
      print('Error cancelling previous connection: $e');
    }

    setState(() {
      connecting = true;
      isScanning = false;
    });
    _connectionSubscription = flutterReactiveBle.connectToAdvertisingDevice(
      id: device.id,
      prescanDuration: const Duration(seconds: 5),
      withServices: device.serviceUuids,
    ).listen((connectionState) async {
      try {
        if (connectionState.connectionState == DeviceConnectionState.connected) {
          setState(() {
            isConnected = true;
            connectedDeviceId = device.id;
            print('Connected to ${device.name}');
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Devices(device: device),
            ));
          });
        }
      } catch (e) {
        print('Error during connection: $e');
        setState(() {
          connecting = false;
        });
      }
    }, onError: (error) {
      print('Connection error: $error');
      setState(() {
        connecting = false;
        isConnected = false;
      });
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

    if (statuses[Permission.bluetooth]!.isGranted && statuses[Permission.location]!.isGranted ) {
      scan();
    } else {
      const Text("open Bluetooth");
    }
  }
  Future<void> disconnect(String deviceId) async {
    try {
      print('disconnecting to device: $deviceId');
      await _connectionSubscription?.cancel();
      print('disconnected');
    } on Exception catch (e, _) {
      print("Error disconnecting from a device: $e");
    } finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
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
          // Ensure Bluetooth and location permissions are granted
          // if (!await _checkPermissions()) {
          // return;
          // }

          devices.clear();
          setState(() {
            devices.clear();
            isScanning = true;
            connecting = false;
          });

          if (isConnected) {
          disconnect(connectedDeviceId!);
          }

          flutterReactiveBle.scanForDevices(
          scanMode: ScanMode.lowLatency,
          withServices: [],
          ).listen((device) {
          setState(() {
          if (!devices.any((d) => d.id == device.id) && device.name.isNotEmpty) { //device.name.startsWith('e')
          devices.add(device);
          }
          });
          }, onError: (error) {
          print('Error: $error');
          setState(() {
          isScanning = false;
          });
          });
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel(); // Cancel any active connections
    _deviceConnectionController.close(); // Close the stream controller
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if(isConnected) {
      _connectionSubscription?.cancel();
      // disconnect(connectedDeviceId!);
}
// print('isconnected : $isConnected  ::: isScanning : $isScanning, connected device : $connectedDeviceId');
return Scaffold(
      appBar: AppBar(
        title: const Text('Scan for Available Bikes'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed:() {isScanning ? null : scan();},
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
                  child: ListTile(
                    title: Text(device.name),
                    subtitle: Text(device.id),
                    trailing: TextButton(
                      onPressed: (

                          ) {
                         connect(device);
                        print(device.name);
                      },
                      child:  Text(connecting ? 'connecting ...':'Connect'),
                    ),
                  ),
                );
              },
            )
                : Center(
                  child: Text(isScanning
                    ? 'Scanning for devices...'
                      : 'No devices found.'),
            ),
          ),
        ],
      ),
    );
  }
}