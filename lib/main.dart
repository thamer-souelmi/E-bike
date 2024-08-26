import 'package:e_bike/data/notificationService.dart';
import 'package:e_bike/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.blueAccent, // Use a color that matches your gradient
        ),
        textTheme: GoogleFonts.latoTextTheme().copyWith(
          headlineSmall: GoogleFonts.lato(),
        ),
        scaffoldBackgroundColor: Colors.transparent, // Ensure background is transparent
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(186, 0, 81, 255),
        ),
        textTheme: GoogleFonts.latoTextTheme().copyWith(
          headlineSmall: GoogleFonts.lato(),
        ),
        scaffoldBackgroundColor: Colors.transparent, // Ensure background is transparent
      ),
      themeMode: ThemeMode.light,
      home: const Loading(),
    );
  }
}
