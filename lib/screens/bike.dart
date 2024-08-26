import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class BikeDashboardScreen extends StatelessWidget {
   const BikeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
             Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton( onPressed: () {}, color: Colors.white, icon: const Icon(Icons.highlight_rounded,),),
              const Row(
                children: [
                  Row(
                  children: [
                  Icon(Icons.battery_full, color: Colors.white),
                    SizedBox(width: 5),
                    Text('100%', style: TextStyle(color: Colors.white)),
            ],
          ),
                  SizedBox(width: 20),
                   Row(
                    children: [
                      Icon(Icons.sunny, color: Colors.white),
                      SizedBox(width: 5),
                      Text('152mile', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                ],
              ),
            ],
          ),
              const SizedBox(height: 20),
              CircularPercentIndicator(
                radius: 150.0,
                lineWidth: 15.0,
                percent: 0.75, // Example value
                center: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "36.9",
                      style: TextStyle(
                          color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "km/h",
                      style: TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const  SizedBox(height: 20),
              _buildStatsRow(),
              const  SizedBox(height: 20),
              _buildButtonsRow(),
            ],
          ),
        ),
      ),
    );
  }



  // Widget _buildIconText(IconData icon, String text) {
  //   return Row(
  //     children: [
  //       Icon(icon, color: Colors.white),
  //       const SizedBox(width: 5),
  //       Text(text, style: const TextStyle(color: Colors.white)),
  //     ],
  //   );
  // }

  // Widget _buildSpeedometer() {
  //   return CircularPercentIndicator(
  //     radius: 150.0,
  //     lineWidth: 15.0,
  //     percent: 0.75, // Example value
  //     center: const Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(
  //           "36.9",
  //           style: TextStyle(
  //               color: Colors.green, fontSize: 50, fontWeight: FontWeight.bold),
  //         ),
  //         Text(
  //           "km/h",
  //           style: TextStyle(
  //               color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
  //         ),
  //       ],
  //     ),
  //     progressColor: Colors.blue,
  //     backgroundColor: Colors.grey,
  //     circularStrokeCap: CircularStrokeCap.round,
  //   );
  // }

  Widget _buildStatsRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('Distance(km)', '84'),
            _buildStatCard('Riding Time', '00:49'),
            _buildStatCard('Speed(km/h)', '36.9'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('EC(Wh/km)', '2.4'),
            _buildStatCard('Calorie(kcal)', '2562'),
            _buildStatCard('Cadence(rpm)', '87'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ],
    );
  }

  Widget _buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton('EXIT'),
        _buildButton('CITY'),
      ],
    );
  }

  Widget _buildButton(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {},
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
