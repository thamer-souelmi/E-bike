import 'package:e_bike/data/notificationService.dart';
import 'package:e_bike/screens/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:e_bike/data/gattservice.dart';
import 'package:provider/provider.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  String? selectedDevice;
  bool isDataProcessed = false;
  Gattservice gattservice = Gattservice();
  List<String> devices = [];
  String nbre = '';
  String id = '';
  String? name ='';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final device = context.watch<NotificationService>().connectedDevice;
    if (device != null) {
      setState(() {
        id = device.id;
        isDataProcessed = true;
      });
      _fetchDeviceData();
    }
  }

  Future<void> _fetchDeviceData() async {
    try {
      await gattservice.writeCharacteristic(
        deviceId: id,
        serviceId: Uuid.parse('1162'),
        characteristicId: Uuid.parse('4403'),
        value: '50',
      );

      String data = await gattservice.readCharacteristic(
        deviceId: id,
        serviceId: Uuid.parse('1162'),
        characteristicId: Uuid.parse('4403'),
      );

      setState(() {
        processDeviceData(data);
        isDataProcessed = true;
      });
    } catch (e) {
      print('Error fetching device data: $e');
    }
  }

  Future<void> processDeviceData(String hexString) async {
    hexString = hexString.replaceAll('[', '').replaceAll(']', '').replaceAll('-', '');
    List<String> groupedBytes = [];
    String remaining = hexString.substring(4);
    nbre = hexString.substring(2, 4);

    for (int i = 0; i < remaining.length; i += 6) {
      String chunk = remaining.substring(i, i + 6);
      groupedBytes.add(chunk);
    }

    setState(() {
      devices = groupedBytes.map((chunk) => chunk).toList();
    });
  }

  String getDeviceName(String device) {
    switch (device) {
      case "0060F9":
        return "BMS";
      case "0060F6":
        return "CTRL";
      default:
        return "Unknown Device";
    }
  }
  List<String> devicees = ['BMS','CTRL'];

  @override
  Widget build(BuildContext context) {
    final connectedDevice = context.watch<NotificationService>().connectedDevice;
    String? name ='';
    name = connectedDevice?.name;
    const Color primaryColor = Colors.blueAccent;
    const Color accentColor = Colors.orangeAccent;
    const Color secondaryColor = Colors.white;
    return Scaffold(
      body: Container(
        decoration:  const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isDataProcessed
            ? SafeArea(
              child: Column(
                        children: [
                           Text(
                            name!,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Number of devices: $nbre",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (BuildContext context, int index) {
                    String device = devices[index];
                    bool isSelected = selectedDevice == device;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedDevice == device) {
                            isSelected = !isSelected;
                            if (!isSelected) {
                              selectedDevice = null;
                            }
                          } else {
                            selectedDevice = device;
                            isSelected = true;
                          }
                        });
                      },
                      child: Card(
                        color: isSelected
                            ? Colors.orangeAccent.withOpacity(0.8)
                            : Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                devicees[index],
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Component(
                                    id: selectedDevice!,
                                    deviceid: connectedDevice?.id ?? '',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
            )
            : const Center(child: CircularProgressIndicator()),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}