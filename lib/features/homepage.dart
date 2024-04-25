import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'livestreaming.dart';
import 'manualyaddcamera.dart'; // Import the ManuallyAddCamera screen

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Color buttonColor = Color(0xFF005697);
  final box = GetStorage();
  List<Map<String, String>> connectedCameras = [];

  @override
  void initState() {
    super.initState();
    box.listen(() {
      loadConnectedCameras();
    });
    loadConnectedCameras();
  }

  void loadConnectedCameras() {
    final storedData = box.read('cameras');
    connectedCameras = [];

    if (storedData!= null) {
      if (storedData is List<dynamic>) {
        for (var item in storedData) {
          if (item is Map<String, dynamic>) {
            final String ip = item['ip'].toString();
            final String username = item['username'].toString();
            final String password = item['password'].toString();

            connectedCameras.add({
              'ip': ip,
              'username': username,
              'password': password,
            });
          } else {
            print('Invalid data format: $item');
          }
        }
      } else {
        print('Invalid data format: $storedData');
      }
    }
    setState(() {});
  }

  Future<void> _navigateToAddCameraScreen() async {
    Navigator.pushNamed(context, 'addcamera');
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: buildHomepage(),
  );
}

Widget buildHomepage() {
  return Stack(
    children: [
      // Background image
      Positioned.fill(
        child: Image.asset(
          'assets/background.png', 
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
      Positioned.fill(
        top: kToolbarHeight + MediaQuery.of(context).padding.top + 10,
        bottom: 80,
        left: 20,
        right: 20,
        child: connectedCameras.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: connectedCameras.length,
                itemBuilder: (context, index) {
                  final camera = connectedCameras[index];
                  final String ip = camera['ip']!;
                  final String username = camera['username']!;
                  final String password = camera['password']!;
                  final String cameraName = 'Camera ${index + 1}';
                  final String cameraInfo =
                      'IP: $ip, Username: $username, Password: $password';

                  return GestureDetector(
                    onTap: () {
                      // Handle tapping on camera item
                    },
                    child: Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.videocam),
                        title: Text(cameraName),
                        subtitle: Text(cameraInfo),
                        trailing: IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            // Handle edit button press for this camera
                            print('Edit button pressed for camera $index');
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      // Add Camera button
      Positioned(
        bottom: 20,
        right: 20,
        child: FloatingActionButton(
          onPressed: _navigateToAddCameraScreen,
          child: Icon(Icons.add),
          backgroundColor: buttonColor, // Circle color
          foregroundColor: Colors.white, // Icon color
          shape: CircleBorder(),
        ),
      ),
    ],
  );
}
}
