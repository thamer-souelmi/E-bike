import 'package:flutter/material.dart';

class Device extends StatelessWidget {
   const Device({super.key , required this.name});
  final String name ;
  @override
  Widget build(BuildContext context) {
    return
       Expanded(child: Text(name ,style: const TextStyle(color: Colors.lightBlue),),)
    ;
  }
}
