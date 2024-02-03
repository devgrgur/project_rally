import 'package:flutter/material.dart';
import 'package:project_rally/src/views/settings_screen.dart';
import 'package:project_rally/src/views/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}