import 'package:e_bike/screens/devices.dart';
import 'package:e_bike/screens/diag.dart';
import 'package:e_bike/widgets/form.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatelessWidget {
  const Home({super.key});


  @override
  Widget build(BuildContext context) {
    bool _isRequestingPermission = false;
    Future<bool> requestStoragePermission() async {
      if (_isRequestingPermission) {
        print("Permission request already in progress...");
        return false;
      }

      _isRequestingPermission = true;

      var status = await Permission.storage.status;
      if (status.isGranted) {
        _isRequestingPermission = false;
        return true;
      } else if (status.isDenied || status.isRestricted) {
        status = await Permission.storage.request();
        _isRequestingPermission = false;
        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied) {
          openAppSettings();
          return false;
        }
      }

      _isRequestingPermission = false;
      return false;
    }
    // Define a color palette
    const Color primaryColor = Colors.blueAccent;
    const Color secondaryColor = Colors.white;
    const Color accentColor = Colors.orangeAccent;

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

              // Custom App Bar
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'E-Bike Control Center',
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
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      // Devices Card
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const Devices(),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.devices,
                                size: 60,
                                color: primaryColor,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Devices',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Form Screen Card
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const FormScreen(),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit,
                                size: 60,
                                color: primaryColor,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const Diag(),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.security,
                                size: 60,
                                color: primaryColor,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Diag ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              // Footer or Additional Information (Optional)
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
        ),
      ),
    );
  }
}
