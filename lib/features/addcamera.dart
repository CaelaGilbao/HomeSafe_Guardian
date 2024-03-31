import 'package:flutter/material.dart';

class AddCamera extends StatelessWidget {
  const AddCamera({super.key});

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
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      // Handle back button pressed
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                  ),
                  SizedBox(
                      width: 0), // Adjust spacing between back button and title
                  Text(
                    'Add Camera',
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
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'automaticsearch'
                          //print('Add camera button pressed!');
                          );
                      print('Automatic search for camera');
                    },
                    style: ElevatedButton.styleFrom(
                      primary: buttonColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/search_logo.png',
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'AUTOMATIC DISCOVERY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  width: 150,
                  height: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'manualaddcamera'
                          //print('Add camera button pressed!');
                          );
                      // Handle manual addition of camera
                      print('Manual addition of camera');
                    },
                    style: ElevatedButton.styleFrom(
                      primary: buttonColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 55, color: Colors.white),
                            SizedBox(height: 5),
                            Text(
                              'ADD MANUALLY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ],
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
