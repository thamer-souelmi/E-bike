import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  String _notificationData = '';

  String get notificationData => _notificationData;

  void subscribeToCharacteristic(QualifiedCharacteristic characteristic) {
    _ble.subscribeToCharacteristic(characteristic).listen((data) {
      // Process the received data
      _notificationData = bytesToHex(data);
      notifyListeners(); // Notify all listeners about the data change
    });
  }
  String bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('-');
  }
}