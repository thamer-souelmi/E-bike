import 'package:flutter/material.dart';

class Cards extends StatelessWidget {
   Cards({super.key,required this.icon,required this.value});
String value = "";
   IconData icon ;
  @override
  Widget build(BuildContext context) {
    return   Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24.0,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 8),
              // const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }


