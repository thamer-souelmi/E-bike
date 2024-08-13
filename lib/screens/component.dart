import 'package:e_bike/provider/gattservice.dart';
import 'package:e_bike/provider/notificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class Component extends StatefulWidget {
    const Component({super.key, required this.id, required this.deviceid});
   final String id  ;
   final String deviceid;
  @override
  State<Component> createState() => _ComponentState();
}


class _ComponentState extends State<Component> {

  @override
  void initState()  {
    super.initState();
    String a = widget.id.replaceAll('[', "").replaceAll("]", "");
    setState(() {
    print(a);

    });
    final Gattservice gattservice = new Gattservice();

    Future.delayed(const Duration(milliseconds: 500), ()
    {

      print("****************");

       gattservice.writeCharacteristic(deviceId: widget.deviceid, serviceId: Uuid.parse('1162'),
          characteristicId: Uuid.parse('4403'),
           value: '51$a');
      gattservice.readCharacteristic(
          deviceId: widget.deviceid,
          serviceId: Uuid.parse("1162"),
          characteristicId: Uuid.parse("4403"));

      // QualifiedCharacteristic c = QualifiedCharacteristic(characteristicId: Uuid.parse('4403'),
      //     serviceId: Uuid.parse('1162'),
      //     deviceId: widget.deviceid);
      // processDeviceData(test);
      // gattservice.subscribeToCharacteristic(c );

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.id)),
      body:  Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          return Center(
            child: Text(
              notificationService.notificationData.isNotEmpty
                  ? 'Latest Notification: ${notificationService.notificationData}'
                  : 'No notifications yet',
              style: const TextStyle(fontSize: 20,color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}