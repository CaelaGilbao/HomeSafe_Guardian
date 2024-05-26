import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:get_storage/get_storage.dart';

class AutomaticSearch extends StatefulWidget {
  @override
  _AutomaticSearchState createState() => _AutomaticSearchState();
}

class _AutomaticSearchState extends State<AutomaticSearch> {
  final NetworkInfo _networkInfo = NetworkInfo();
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  List<String> _discoveredIps = [];
  String _selectedIp = '';
  String _validationResult = '';
  bool _showSaveButton = false;
  List<Map<String, String>> _cameras = [];

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCameras();
    _discoverDevices();
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

  Future<void> _discoverDevices() async {
    final wifiIP = await _networkInfo.getWifiIP();
    if (wifiIP == null) return;

    final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
    const port = 554;

    for (var i = 0; i < 256; i++) {
      String ip = '$subnet.$i';
      try {
        final socket = await Socket.connect(ip, port, timeout: Duration(milliseconds: 50));
        print('Found device: $ip');
        setState(() {
          _discoveredIps.add(ip);
        });
        socket.destroy();
      } catch (e) {
        // Ignore errors
      }
    }
  }

  Future<void> _testConnection() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String ip = _selectedIp;

    List<String> rtspUrls = [
      'rtsp://$username:$password@$ip:554/stream1',
    ];

    bool connectionSuccess = false;

    for (String url in rtspUrls) {
      int resultCode = await _flutterFFmpeg.execute("-rtsp_transport tcp -i $url -t 1 -an -f null -");
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
        _validationResult = 'Connection successful for IP: $ip';
      } else {
        _validationResult = 'Connection failed for IP: $ip';
        _showSaveButton = false;
      }
    });
  }

  Future<void> _saveCamera() async {
    String ip = _selectedIp;
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
                Navigator.pop(context);
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
        title: Text('Automatic Search for Cameras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _discoveredIps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_discoveredIps[index]),
                    onTap: () {
                      setState(() {
                        _selectedIp = _discoveredIps[index];
                      });
                    },
                    selected: _selectedIp == _discoveredIps[index],
                    selectedTileColor: Colors.blue[100],
                  );
                },
              ),
            ),
            if (_selectedIp.isNotEmpty) ...[
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
          ],
        ),
      ),
    );
  }
}
