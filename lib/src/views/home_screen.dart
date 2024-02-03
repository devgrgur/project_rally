import 'package:flutter/material.dart';
import 'package:project_rally/src/animations/slide_page_route.dart';
import 'package:project_rally/src/views/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Rally Application'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 30),
            onPressed: () {
              Navigator.of(context).push(
                SlidePageRoute(builder: (BuildContext context) {
                    return const SettingsScreen();
                  },
                  slideFromLeft: false,
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Text('Welcome to Rally Application!', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}