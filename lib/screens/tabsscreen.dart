import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:e_bike/screens/scan.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:e_bike/screens/bike.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsscreenState();
}

class _TabsscreenState extends State<TabsScreen> {

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  int _selectedPageIndex = 0;
  late StreamSubscription<DiscoveredDevice> _scanSubscription;
  late StreamSubscription<BleStatus> _bluetoothStateSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStartScanning();
  }

  Future<void> _checkPermissionsAndStartScanning() async {
    final bluetoothPermission = await Permission.bluetoothScan.request();
    final locationPermission = await Permission.locationWhenInUse.request();

    if (bluetoothPermission.isGranted || locationPermission.isGranted) {
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable Bluetooth and Location services.'),
        ),
      );
    }
  }
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _showEnableBluetoothDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth Disabled'),
          content: const Text('Bluetooth is off. Please enable it to continue.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openBluetoothSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openBluetoothSettings() async {
    String url;

    if (Theme.of(context).platform == TargetPlatform.android) {
      url = 'android.settings.BLUETOOTH_SETTINGS';
    }  else {
      // Handle other platforms if necessary
      return;
    }

    try {
      if (await canLaunchUrlString(url)) {
        await canLaunchUrlString(url);
      } else {
        // Handle the case where the URL cannot be launched
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open settings.'),
          ),
        );
      }
    } catch (e) {
      // Handle any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }

//   const AndroidIntent(
//   action:
//   'android.bluetooth.adapter.action.REQUEST_ENABLE',
//   ).launch().catchError(
//   (e) => AppSettings.openBluetoothSettings());
// } else {
// AppSettings.openBluetoothSettings();
// }

  // void _selectPage(int index) {
  //   setState(() {
  //     _selectedPageIndex = index;
  //     if (index == 0) {
  //       _checkPermissionsAndStartScanning();
  //     }
  //   });
  // }

  @override
  void dispose() {
    _scanSubscription.cancel();
    _bluetoothStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const Scan();
    if (_selectedPageIndex == 1) {
      activePage = const BikeDashboardScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/a.png',
          height: 40,
        ),
      ),
      body: Column(
        children: [
          Expanded(child: activePage),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: ElevatedButton(
          //     onPressed: _openBluetoothSettings,
          //     child: const Text('Turn On Bluetooth'),
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bike),
            label: 'Bike',
          ),
        ],
      ),
    );
  }
}
