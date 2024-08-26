import 'package:e_bike/provider/gattservice.dart';
import 'package:e_bike/provider/notificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _field1Controller = TextEditingController();
  final TextEditingController _field2Controller = TextEditingController();
  final TextEditingController _field3Controller = TextEditingController();
  final TextEditingController _field4Controller = TextEditingController();
  final TextEditingController _field5Controller = TextEditingController();

  Gattservice gattservice = Gattservice();
  String? _selectedOption;
  // String? _selectedOption1;

  @override
  void dispose() {
    _field1Controller.dispose();
    _field2Controller.dispose();
    _field3Controller.dispose();
    _field4Controller.dispose();
    _field5Controller.dispose();

    super.dispose();
  }

  String? _validateDropdown(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an option';
    }
    return null;
  }
  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    } else if (int.tryParse(value) == null || int.parse(value) <= 0) {
      return 'Value must be greater than 0';
    }
    return null;
  }
  // String? _validateField1(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'This field cannot be empty';
  //   } else if (int.tryParse(value) == null || int.parse(value) <= 0) {
  //     return 'Value must be greater than 0';
  //   }
  //   return null;
  // }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final device = context.read<NotificationService>().connectedDevice;

      if (device != null) {
        // Convert the input values to hexadecimal
        String partNumberHex = int.parse(_field5Controller.text).toRadixString(16).toUpperCase();
        String codeManufacturingHex = int.parse(_field1Controller.text).toRadixString(16).toUpperCase();
        String snHex = int.parse(_field4Controller.text).toRadixString(16).toUpperCase();

        final fieldValues = [
          _selectedOption ?? '',
          partNumberHex,
          codeManufacturingHex,
          '0${_field2Controller.text[3]}',
          snHex,
        ].join(',');

        String value = '55${fieldValues.replaceAll(',', "")}';

        gattservice.writeCharacteristic(
          deviceId: device.id,
          serviceId: Uuid.parse('1162'),
          characteristicId: Uuid.parse('4403'),
          value: value,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data sent to GATT service')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No device connected')),
        );
      }
    }
  }


  String? _validateSNField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }
  String? _validatePNField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  String? _validateFieldC(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.blueAccent;
    const Color accentColor = Colors.orangeAccent;
    const Color secondaryColor = Colors.white;


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
    'Form Screen',
    style: TextStyle(
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
    Expanded(
    child: SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

    DropdownButtonFormField<String>(
    decoration: const InputDecoration(
    labelText: 'Controller device',
    labelStyle: TextStyle(color: secondaryColor),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: secondaryColor),
    ),
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: secondaryColor),
    ),
    ),
    dropdownColor: Colors.black,
    style: const TextStyle(color: secondaryColor),
    value: _selectedOption,
    items: const [
    DropdownMenuItem(value: '0A', child: Text('Pack system')),
    DropdownMenuItem(value: 'OB', child: Text('BMS device')),
    DropdownMenuItem(value: '0C', child: Text('Controller device')),
    ],
    onChanged: (value) {
    setState(() {
    _selectedOption = value;
    });
    },
    validator: _validateDropdown,
    ),
    const SizedBox(height: 20),
      TextFormField(
        controller: _field5Controller,
        decoration: const InputDecoration(
          labelText: 'Part Number device',
          labelStyle: TextStyle(color: secondaryColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: secondaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: secondaryColor),
          ),
        ),
        style: const TextStyle(color: secondaryColor),
        keyboardType: TextInputType.text,
        validator: _validatePNField,
      ),
      const SizedBox(height: 20),
    TextFormField(
    controller: _field1Controller,
    decoration: const InputDecoration(
    labelText: 'Code Manufacturing',
    labelStyle: TextStyle(color: secondaryColor),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: secondaryColor),
    ),
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: secondaryColor),
    ),
    ),
    style: const TextStyle(color: secondaryColor),
    keyboardType: TextInputType.number,
    validator: _validateFieldC,
    ),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(
    decoration: const InputDecoration(
    labelText: 'Year',
    labelStyle: TextStyle(color: secondaryColor),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: secondaryColor),
    ),
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: secondaryColor),
    ),
    ),
    dropdownColor: Colors.black,
    style: const TextStyle(color: secondaryColor),
    value: _field2Controller.text.isEmpty ? null : _field2Controller.text,
    items: List.generate(50, (index) {
    final year = (DateTime.now().year - index).toString();
    return DropdownMenuItem(value: year, child: Text(year));
    }),
    onChanged: (value) {
    setState(() {
    _field2Controller.text = value!;
    });
    },
    validator: _validateField,
    ),
    const SizedBox(height: 20),
    TextFormField(
    controller: _field4Controller,
    decoration: const InputDecoration(
    labelText: 'SN',
    labelStyle: TextStyle(color: secondaryColor),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: secondaryColor),
    ),
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: secondaryColor),
    ),
    ),
    style: const TextStyle(color: secondaryColor),
    keyboardType: TextInputType.text,
    validator: _validateSNField,
    ),
    const SizedBox(height: 20),
    Center(
    child: ElevatedButton(
    onPressed: _submitForm,
    style: ElevatedButton.styleFrom(
    foregroundColor: secondaryColor,
    backgroundColor: Colors.orangeAccent,
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
    ),
    ),
    child: const Text('Submit'),
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    ));
  }
}

