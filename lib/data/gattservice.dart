import 'package:e_bike/data/notificationService.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class Gattservice {
FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
List<String> notifications = [];

  Future<String> readCharacteristic({
    required String deviceId,
    required Uuid serviceId,
    required Uuid characteristicId,
  }) async {
    final flutterReactiveBle = FlutterReactiveBle();
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: characteristicId,
        deviceId: deviceId,
      );
      List<int> response = await flutterReactiveBle.readCharacteristic(characteristic);
      print('response : -------- ${bytesToHex(response).toUpperCase()}');
      // int decimalValue = int.parse(response.toString());
      print('decimalValue : -------- $response');
      return bytesToHex(response).toUpperCase();

    } catch (e) {
      print('Error reading characteristic: $e');
      return 'Error';
    }
  }

  Future<void> writeCharacteristic({
    required String deviceId,
    required Uuid serviceId,
    required Uuid characteristicId,
    required String value,
  }) async {
    final flutterReactiveBle = FlutterReactiveBle();
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: characteristicId,
        deviceId: deviceId,
      );
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristic,
        value: hexToBytes(value),
      );
      print("Written value (Hex): $value");
    } catch (e) {
      print('Error writing characteristic: $e');
    }
  }
final NotificationService _notificationService = NotificationService();

Future<Stream<List<int>>> subscribeToCharacteristics(QualifiedCharacteristic characteristic) async {
  return flutterReactiveBle.subscribeToCharacteristic(characteristic);
}

Future<void> subscribeToCharacteristic(QualifiedCharacteristic characteristic ) async {
    try {
      flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((data) {
          notifications.add(bytesToHex(data).toUpperCase());
          String test123 = bytesToHex(data).toUpperCase();
          print(test123);
        print('Notification received: ${bytesToHex(data).toUpperCase()}');
          _notificationService.subscribeToCharacteristic(characteristic);


      }
        , onError: (dynamic error) {
          print('Error subscribing to characteristic: $error');
      });
    } catch (e) {
      print('Error enabling notifications: $e');
    }
  }

  QualifiedCharacteristic toQualifiedCharacteristic( characteristicInfo, String deviceId) {
    return QualifiedCharacteristic(
      serviceId: characteristicInfo.serviceId,
      characteristicId: characteristicInfo.characteristicId,
      deviceId: deviceId,
    );
  }

  String bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('-');
  }
  List<int> hexToBytes(String hex) {
    final buffer = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      buffer.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return buffer;
  }
}