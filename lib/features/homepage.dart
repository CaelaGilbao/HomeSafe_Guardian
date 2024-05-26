import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'livestreaming.dart';

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

    if (storedData != null) {
      if (storedData is List<dynamic>) {
        for (var item in storedData) {
          if (item is Map<String, dynamic>) {
            final String name = item['name'].toString();
            final String ip = item['ip'].toString();
            final String username = item['username'].toString();
            final String password = item['password'].toString();

            connectedCameras.add({
              'name': name,
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

   void _editCameraName(int index) {
    TextEditingController nameController =
        TextEditingController(text: connectedCameras[index]['name']);
    bool _obscurePassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final camera = connectedCameras[index];
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                'Edit Camera',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Camera Name:',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  TextField(
                    controller: nameController,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'IP Address: ${camera['ip']}',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Username: ${camera['username']}',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Password: ${_obscurePassword ? '•' * camera['password']!.length : camera['password']}',
                          style: TextStyle(fontFamily: 'Montserrat'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    'Save',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  onPressed: () {
                    setState(() {
                      connectedCameras[index]['name'] = nameController.text
                              .trim()
                              .isEmpty
                          ? 'Camera ${index + 1}'
                          : nameController.text.trim();
                    });
                    box.write('cameras', connectedCameras);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _deleteCamera(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Delete',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          content: Text(
            'Are you sure you want to delete this camera?',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              onPressed: () {
                setState(() {
                  connectedCameras.removeAt(index);
                });
                box.write('cameras', connectedCameras);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
                        child: Text(
                          'Settings',
                          style: TextStyle(fontSize: 18),
                        ),
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
                  child: Text('No camera added'),
                )
              : ListView.builder(
                  itemCount: connectedCameras.length,
                  itemBuilder: (context, index) {
                    final camera = connectedCameras[index];
                    final String name = camera['name']!;
                    final String ip = camera['ip']!;
                    final String username = camera['username']!;
                    final String password = camera['password']!;
                    final String cameraInfo =
                        'IP: $ip, Username: $username, Password: ${'•' * password.length}';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LiveStreamingPage(
                              cameraInfo: camera,
                              cameraName: name,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.videocam),
                          title: Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold, // Bold for camera name
                            ),
                          ),
                          subtitle: Text(
                            cameraInfo,
                            style: TextStyle(fontFamily: 'Montserrat'),
                          ), // Normal font for other texts
                          trailing: PopupMenuButton<String>(
                            onSelected: (String result) {
                              if (result == 'edit') {
                                _editCameraName(index);
                              } else if (result == 'delete') {
                                _deleteCamera(index);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text(
                                  'Edit',
                                  style: TextStyle(fontFamily: 'Montserrat'),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: TextStyle(fontFamily: 'Montserrat'),
                                ),
                              ),
                            ],
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
