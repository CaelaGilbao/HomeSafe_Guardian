import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:get_storage/get_storage.dart';

class ManuallyAddCamera extends StatefulWidget {
  @override
  _ManuallyAddCameraState createState() => _ManuallyAddCameraState();
}

class _ManuallyAddCameraState extends State<ManuallyAddCamera> {
  TextEditingController _ipController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String _validationResult = '';
  bool _showSaveButton = false;
  List<Map<String, String>> _cameras = [];

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  Future<void> _testConnection() async {
    String ip = _ipController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Constructing multiple RTSP URL formats
    List<String> rtspUrls = [
      'rtsp://$username:$password@$ip:554/stream1',
    ];

    bool connectionSuccess = false;

    for (String url in rtspUrls) {
      FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
      int resultCode = await flutterFFmpeg.execute("-rtsp_transport tcp -i $url -t 1 -an -f null -");

      if (resultCode == 0) {
        connectionSuccess = true;
        setState(() {
          _showSaveButton = true;
        });
        break;
      }
    }

    setState(() {
      if (connectionSuccess) {
        _validationResult = 'Connection successful';
      } else {
        _validationResult = 'Connection failed';
        _showSaveButton = false;
      }
    });
  }

  Future<void> _loadCameras() async {
    final box = GetStorage();
    final List<dynamic> storedCameras = box.read('cameras') ?? [];
    setState(() {
      _cameras = storedCameras
          .map((dynamic item) => {
                'ip': item['ip'].toString(),
                'username': item['username'].toString(),
                'password': item['password'].toString(),
              })
          .toList();
    });
  }
  
 Future<void> _saveCamera() async {
  String ip = _ipController.text;
  String username = _usernameController.text;
  String password = _passwordController.text;

  _cameras.add({
    'ip': ip,
    'username': username,
    'password': password,
  });

  final box = GetStorage();
  await box.write('cameras', _cameras);
  

  // Show dialog upon successful save
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Success'),
        content: Text('Camera successfully saved!'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              // Close the dialog
              Navigator.pop(context);
              //Close the addcamera page
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
      appBar: AppBar(
        title: Text('Manually Add Camera'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(labelText: 'IP Address'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testConnection,
              child: Text('Test Connection'),
            ),
            SizedBox(height: 20),
            Text(
              _validationResult,
              style: TextStyle(
                color: _validationResult.contains('successful')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            if (_showSaveButton)
              ElevatedButton(
                onPressed: _saveCamera,
                child: Text('Save Camera'),
              ),
          ],
        ),
      ),
    );
  }
}
