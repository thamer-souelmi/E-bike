import 'package:e_bike/provider/gattservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Component extends ConsumerStatefulWidget {
  const Component({super.key, required this.id, required this.deviceid});

  final String id;
  final String deviceid;

  @override
  ConsumerState<Component> createState() => _ComponentState();
}

class _ComponentState extends ConsumerState<Component> {
  List<String> components = [];
  String? selectedComponent;
  String? componentDetails;
  String selectedType = 'Software'; // Default to Software

  final Map<String, String> componentNames = {
    '01': 'CPU APP',
    '02': 'CPU BLD',
    '03': 'nRF APP',
    '04': 'nRF SDK',
    '05': 'nRF BLD',
    '06': 'STSPIN APP',
  };

  final Map<String, String> softwareVersions = {};

  String manufacturerCode = '';
  String year = '';
  String serialNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchComponentsData();
  }

  Future<void> _fetchComponentsData() async {
    final Gattservice gattservice = Gattservice();

    String a = widget.id.replaceAll('[', "").replaceAll("]", "");
    await gattservice.writeCharacteristic(
      deviceId: widget.deviceid,
      serviceId: Uuid.parse('1162'),
      characteristicId: Uuid.parse('4403'),
      value: '51$a', // Command to fetch components
    );

    String data1 = await gattservice.readCharacteristic(
      deviceId: widget.deviceid,
      serviceId: Uuid.parse("1162"),
      characteristicId: Uuid.parse("4403"),
    );

    setState(() {
      processDeviceData(data1);
    });
  }

  Future<void> processDeviceData(String hexString) async {
    hexString = hexString.replaceAll('[', '').replaceAll(']', '').replaceAll('-', '');

    List<String> groupedBytes = [];
    String remaining = hexString.substring(10);

    for (int i = 0; i < remaining.length; i += 2) {
      String chunk = remaining.substring(i, i + 2);
      groupedBytes.add(chunk);
    }

    setState(() {
      components = groupedBytes.toSet().toList(); // Ensure unique components
    });

    for (String component in components) {
      await fetchComponentDetails(component);
    }
    await fetchManufacturerAndSerialData();
  }

  Future<void> fetchComponentDetails(String component) async {
    final Gattservice gattservice = Gattservice();
    String commandPrefix = selectedType == 'Software' ? '52' : '52'; // Change command based on selection
    String command = '$commandPrefix${widget.id}$component';

    await gattservice.writeCharacteristic(
      deviceId: widget.deviceid,
      serviceId: Uuid.parse('1162'),
      characteristicId: Uuid.parse('4403'),
      value: command,
    );

    String details = await gattservice.readCharacteristic(
      deviceId: widget.deviceid,
      serviceId: Uuid.parse('1162'),
      characteristicId: Uuid.parse('4403'),
    );

    setState(() {
      componentDetails = details;
      processSoftwareData(component, details);
    });
  }

  Future<void> processSoftwareData(String component, String hexString) async {
    hexString = hexString.replaceAll('[', '').replaceAll(']', '').replaceAll('-', '');

    List<String> groupedBytes = [];
    String remaining = hexString.substring(10);

    for (int i = 0; i < remaining.length; i += 2) {
      String chunk = remaining.substring(i, i + 2);
      groupedBytes.add(chunk[1]);
    }

    String version = '${groupedBytes[0]}.${groupedBytes[1]}.${groupedBytes[2]}';
    setState(() {
      softwareVersions[component] = version;
    });
  }

  Future<void> processHardwareData(String hexString) async {
    hexString = hexString.replaceAll('[', '').replaceAll(']', '').replaceAll('-', '');

    List<String> groupedBytes = [];
    String remaining = hexString.substring(8);

    for (int i = 0; i < remaining.length; i += 2) {
      String chunk = remaining.substring(i, i + 2);
      groupedBytes.add(chunk);
    }
  }
// Fetch and process manufacturer code, year, and serial number
  Future<void> fetchManufacturerAndSerialData() async {
    final Gattservice gattservice = Gattservice();
    String command = '53${widget.id}'; // Command for hardware without component

    await gattservice.writeCharacteristic(
      deviceId: widget.deviceid,
      serviceId: Uuid.parse('1162'),
      characteristicId: Uuid.parse('4403'),
      value: command,
    );

    String details = await gattservice.readCharacteristic(
      deviceId: widget.deviceid,
      serviceId: Uuid.parse('1162'),
      characteristicId: Uuid.parse('4403'),
    );

    // Process the hardware details (manufacturer code, year, serial number)
    setState(() {
      processManufacturerData(details);
    });
  }

  void processManufacturerData(String hexString) {
    hexString = hexString.replaceAll('[', '').replaceAll(']', '').replaceAll('-', '');

    List<String> groupedBytes = [];
    String remaining = hexString.substring(8);

    for (int i = 0; i < remaining.length; i += 2) {
      String chunk = remaining.substring(i, i + 2);
      groupedBytes.add(chunk);
    }

    setState(() {
      manufacturerCode = groupedBytes[0];
      year = '202${groupedBytes[1][1]}'; // Assuming the year is stored as '0X' (X = last digit of year)
      serialNumber = int.parse('${groupedBytes[2]}${groupedBytes[3]}${groupedBytes[4]}', radix: 16).toString();
    });
  }
  // Future<void> fetchManufacturerAndSerialDatas() async {
  //   final Gattservice gattservice = Gattservice();
  //
  //   await gattservice.writeCharacteristic(
  //     deviceId: widget.deviceid,
  //     serviceId: Uuid.parse('1162'),
  //     characteristicId: Uuid.parse('4403'),
  //     value: '54',
  //   );
  //
  //   String details = await gattservice.readCharacteristic(
  //     deviceId: widget.deviceid,
  //     serviceId: Uuid.parse('1162'),
  //     characteristicId: Uuid.parse('4403'),
  //   );
  //
  //   setState(() {
  //     processManufacturerData(details);
  //   });
  // }

  void processManufacturerDatas(String hexString) {
    hexString = hexString.replaceAll('[', '').replaceAll(']', '').replaceAll('-', '');

    List<String> groupedBytes = [];
    String remaining = hexString.substring(8);

    for (int i = 0; i < remaining.length; i += 2) {
      String chunk = remaining.substring(i, i + 2);
      groupedBytes.add(chunk);
    }
    setState(() {
      manufacturerCode = groupedBytes[0];
      year = '202${groupedBytes[1][1]}'; // Assuming the year is stored as '0X' (X = last digit of year)
      serialNumber = int.parse('${groupedBytes[2]}${groupedBytes[3]}${groupedBytes[4]}', radix: 16).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return components.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: components.length,
            itemBuilder: (BuildContext context, int index) {
              String component = components[index];
              String componentName = componentNames[component] ?? "Unknown Component";
              String version = softwareVersions[component] ?? "Loading...";

              return ListTile(
                title: Text(
                  '$componentName : $version',
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                onTap: () async {
                  setState(() {
                    selectedComponent = component;
                    componentDetails = null; // Reset details when a new component is selected
                  });

                  await fetchComponentDetails(component);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16.0),
        if (manufacturerCode.isNotEmpty && year.isNotEmpty && serialNumber.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Code manufacturing: $manufacturerCode\nYear: $year\nSerial Number: $serialNumber",
              style: const TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
      ],
    )
        : const Center(child: CircularProgressIndicator());
  }
}
