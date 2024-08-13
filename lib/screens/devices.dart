import 'package:e_bike/screens/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:e_bike/provider/gattservice.dart';
class Devices extends StatefulWidget {
      const Devices({super.key,  required this.device });
   final  DiscoveredDevice device   ;

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
   String value ='50';

   String t ='null';
   bool isDataProcessed = false;

   // String test='[50020060F60060F9000000]';

      Gattservice gattservice = Gattservice() ;

      List<List<String>> devices = [];
   String nbre = '02';

    @override
  void initState()  {
      super.initState();
      Future.delayed(const Duration(milliseconds: 500), ()
      {

        gattservice.writeCharacteristic(deviceId: widget.device.id, serviceId: Uuid.parse('1162'),
            characteristicId: Uuid.parse('4403'),
            value: '50');
        gattservice.readCharacteristic(
            deviceId: widget.device.id,
            serviceId: Uuid.parse("1162"),
            characteristicId: Uuid.parse("4403"));

        QualifiedCharacteristic c = QualifiedCharacteristic(characteristicId: Uuid.parse('4403'), serviceId: Uuid.parse('1162'), deviceId: widget.device.id);
        // processDeviceData(test);
        gattservice.subscribeToCharacteristic(c );
        setState(() {
           isDataProcessed = true;

        });
         read();
      });
    }

    List<int> deviceData =[];
      Future<void> processDeviceData(String hexString) async {
        // Remove the brackets
        hexString = hexString.replaceAll('[', '').replaceAll(']', '').replaceAll('-', '');



        List<String> groupedBytes = [];
        String remaining = hexString.substring(4);
        nbre = hexString.substring(2,4);
        for (int i = 0; i < remaining.length; i += 6) {
          String chunk = remaining.substring(i, i + 6);
          groupedBytes.add(chunk);
        }

        devices = [
          ...groupedBytes.map((chunk) => [chunk])
        ];

      }

      Future<String> read () async{
       try{
      Gattservice gattservice = Gattservice() ;

      t =  await gattservice.readCharacteristic(
          deviceId: widget.device.id,
          serviceId: Uuid.parse("1162"),
          characteristicId: Uuid.parse("4403")) ;
       setState(() {
         isDataProcessed = true;

         processDeviceData(t);
       });
       return t ;}
           catch(e){
             return e.toString() ;
           }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name)),
      body: isDataProcessed
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text("Number of devices : $nbre",style: const TextStyle(color: Colors.white),),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text("Device Data: ${devices[index]}"),
                      leading: const Icon(Icons.device_hub, color: Colors.blue),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: (
                              
                              ) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Component(id: devices[index].toString(), deviceid: widget.device.id,)),
                            );
                            // Component(id: widget.device.id, deviceid: '',);
                            print('Button pressed for item: ${devices[index]}');
                          },
                        ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()), // Show a loading indicator while waiting for data
    );
  }}