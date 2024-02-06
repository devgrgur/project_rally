import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:project_rally/src/utils/asset/asset_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _pdfPath;
  double _distanceTraveled = 0.0;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _updateTimer;
  double _currentHeading = 0.0;
  Timer? _debounceTimer;
  late StreamSubscription<CompassEvent> _compassSubscription;

  @override
  void initState() {
    super.initState();
    _startTracking();
    _startCompass();
  }

  void _startTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      // Debounce to mitigate rapid minor position changes
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 1), () {
        if (_lastPosition != null) {
          final double distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          // Apply a minimal movement threshold to filter out GPS noise
          // For example, only add distance if moved more than 2 meters
          if (distance > 2) {
            _distanceTraveled += distance / 1000; // Keeping distance in kilometers
            _lastPosition = position;

            setState(() {}); // Update UI here
          }
        } else {
          // If _lastPosition is null, just set the current position without adding to _distanceTraveled
          _lastPosition = position;
        }
      });
    });
  }

  void _startCompass() {
    _compassSubscription = FlutterCompass.events!.listen((CompassEvent event) {
      if (event.heading != null) {
        double normalizedHeading = event.heading! % 360;
        _currentHeading = normalizedHeading; // Store the latest heading
      }
    });

    _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentHeading = _currentHeading.toInt().toDouble();
      });
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _debounceTimer?.cancel();
    _compassSubscription.cancel();
    _updateTimer?.cancel();
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

  void resetPDFFile() async {

    setState(() {
      _pdfPath = null;
      _distanceTraveled = 0.0;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            _pdfPath != null ?
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _distanceTraveled.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Orbitron',
                                  ),
                                ),
                                WidgetSpan(
                                  child: Transform.translate(
                                    offset: const Offset(0, -20),
                                    child: const Text(
                                      ' km',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Orbitron',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${_currentHeading.toInt() ?? 'N/A'}°', style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
            : const SizedBox.shrink(),
            Expanded(
                child: _pdfPath == null
                    ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AssetHelper.getPngPath('app_logo'), height: 200, width: 200),
                    const Text('No PDF selected, upload one below.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontFamily: 'OpenSans')),
                  ],
                ))
                    : Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey,
                        width: 8.0
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: PDFView(filePath: _pdfPath),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 20),
              child: _pdfPath == null ?
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: pickPDFFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text('Upload PDF', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'OpenSans', fontSize: 12)),
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                      onPressed: resetPDFFile,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Icon(Icons.cancel_outlined, color: Colors.red, size: 50),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Image.asset(AssetHelper.getPngPath('app_logo'), height: 50, width: 200),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}