import 'dart:async';
import 'package:flutter/material.dart';
import 'package:homesafe_guardian_app/features/addcamera.dart';
import 'package:homesafe_guardian_app/features/detectedcameras.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Camera {
  final String id;
  final String name;

  Camera({required this.id, required this.name});
}

class AutomaticSearch extends StatefulWidget {
  @override
  _AutomaticSearchState createState() => _AutomaticSearchState();
}

class _AutomaticSearchState extends State<AutomaticSearch> {
  int countdownSeconds = 60;
  late Timer _timer;
  List<Camera> detectedCameras = []; // List to store detected cameras

  @override
  void initState() {
    super.initState();
    // Start the countdown timer and the automatic search process
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdownSeconds > 0) {
          countdownSeconds--;
        } else {
          // Navigate back to the previous screen after 10 seconds
          _timer.cancel();
          _showNoCameraDetectedDialog();
        }
      });
    });
    _startAutomaticSearch(); // Start automatic search after timer setup
  }

  void _showNoCameraDetectedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing on tap outside
      builder: (BuildContext context) {
        return _buildNoCameraDetectedDialog();
      },
    ).then((_) {
      // Reset the timer when the dialog is dismissed
      _restartSearch();
    });
  }

  AlertDialog _buildNoCameraDetectedDialog() {
    return AlertDialog(
      title: Text("No camera detected"),
      content: Text("Please try again."),
      actions: <Widget>[
        TextButton(
          child: Text("Retry"),
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _restartSearch() {
    setState(() {
      countdownSeconds = 60; // Reset the countdown timer
    });
    _startTimer(); // Start the timer again
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _navigateToDetectedCamerasScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetectedCamerasScreen(detectedCameras: detectedCameras),
      ),
    );
  }

  void _detectMockRTSPCamera() async {
    final String mockRTSPUrl =
        'http://192.168.1.8:554'; // URL of the mock RTSP server
    final String describeEndpoint =
        '$mockRTSPUrl/describe'; // DESCRIBE endpoint

    try {
      final http.Response response =
          await http.get(Uri.parse(describeEndpoint));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Camera camera = Camera(
          id: responseData['cameraId'],
          name: responseData['cameraName'],
        );
        setState(() {
          detectedCameras.add(camera);
        });
        _navigateToDetectedCamerasScreen(); // Navigate automatically when camera detected
        _timer.cancel(); // Cancel the timer as the camera is detected
      } else {
        print('Failed to detect mock RTSP camera: ${response.statusCode}');
      }
    } catch (e) {
      // Handle connection error
      print('Error detecting mock RTSP camera: $e');
      // Show a dialog or message to inform the user about the connection error
    }
  }

  void _startAutomaticSearch() {
    _detectMockRTSPCamera(); // Start detecting mock RTSP camera
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Color(0xFF005697);
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png', // Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Search available cameras',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontSize: 25,
                ),
              ),
            ),
          ),
          // Countdown timer and loading indicator
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Searching for cameras...',
                  style: TextStyle(
                    color: buttonColor,
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                ),
                SizedBox(height: 20),
                Text(
                  'Time remaining: $countdownSeconds seconds',
                  style: TextStyle(
                    color: buttonColor,
                    fontSize: 15,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: buttonColor, // Change button color here
                    borderRadius:
                        BorderRadius.circular(10), // Adjust button shape here
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Stop the search and navigate back to the previous screen
                      _timer.cancel();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white, // Change button text color here
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
