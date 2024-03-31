import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  final List<String> connectedCameras;

  const Homepage({Key? key, required this.connectedCameras}) : super(key: key);

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
          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'HomeSafe Guardian',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontSize: 25,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.more_vert),
                  iconSize: 35,
                  color: Colors.white,
                  alignment: Alignment.centerRight,
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        MediaQuery.of(context).size.width,
                        kToolbarHeight + MediaQuery.of(context).padding.top,
                        0,
                        0,
                      ),
                      items: [
                        PopupMenuItem(
                          child:
                              Text('Settings', style: TextStyle(fontSize: 18)),
                          onTap: () {
                            // Handle settings option
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Content
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, 'addcamera');
              },
              child: Icon(Icons.add),
              backgroundColor: buttonColor, // Circle color
              foregroundColor: Colors.white, // Icon color
              shape: CircleBorder(),
            ),
          ),
          // Display "No camera added" message if connectedCameras is empty
          if (connectedCameras.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No camera added',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    color: buttonColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
