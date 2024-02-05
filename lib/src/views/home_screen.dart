import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _pdfPath;
  double _distanceTraveled = 0.0; // Distance in kilometers
  double? _currentHeading;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _startTracking();
    _startCompass();
  }

  void _startTracking() {
    const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1);
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (_lastPosition != null) {
        _distanceTraveled += Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        ) / 1000; // Convert meters to kilometers
      }
      _lastPosition = position;
      setState(() {});
    });
  }

  void _startCompass() {
    _compassSubscription = FlutterCompass.events!.listen((CompassEvent event) {
      if (event.heading != null) {
        // Normalize the heading to ensure it's within 0 - 360 degrees
        double normalizedHeading = event.heading! % 360;

        // Remove decimal points by converting to int
        _currentHeading = normalizedHeading.toInt().toDouble(); // Convert to double for consistency

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _compassSubscription?.cancel();
    super.dispose();
  }

  void pickPDFFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfPath = result.files.single.path;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black, // Set background color to black
        body: Column(
          children: <Widget>[
            // New displays for distance and cap heading
            Padding(
              padding: const EdgeInsets.all(30.0), // Adjust the padding as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Space them evenly
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16), // Adjust padding as needed
                      color: Colors.grey[850], // Adjust the background color as needed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${_distanceTraveled.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), // Placeholder value
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16), // Adjust padding as needed
                      color: Colors.grey[850], // Adjust the background color as needed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${_currentHeading?.toInt() ?? 'N/A'}°', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), // Placeholder value
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // PDF view and upload button remain unchanged
            Expanded(
              child: _pdfPath == null
                  ? const Center(child: Text('No PDF selected', style: TextStyle(color: Colors.white)))
                  : Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 30), // Adjusted for visual balance
                child: PDFView(
                  filePath: _pdfPath,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: pickPDFFile,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // Button color
                    onPrimary: Colors.white, // Text color
                  ),
                  child: const Text('Upload PDF'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}