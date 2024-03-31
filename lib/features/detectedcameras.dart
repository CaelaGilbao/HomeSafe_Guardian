import 'package:flutter/material.dart';
import 'package:homesafe_guardian_app/features/automaticsearch.dart';

class DetectedCamerasScreen extends StatelessWidget {
  final List<Camera> detectedCameras;

  DetectedCamerasScreen({required this.detectedCameras});

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Color(0xFF005697);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png', // Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  Text(
                    'Detected Camera',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Camera List
          Container(
            margin: EdgeInsets.only(top: kToolbarHeight + 10),
            child: ListView.builder(
              itemCount: detectedCameras.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Handle camera click event
                    Navigator.pushNamed(context, 'homepage');
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt), // Your icon here
                        SizedBox(width: 10), // Adjust icon spacing
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detectedCameras[index].name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(detectedCameras[index].id),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
