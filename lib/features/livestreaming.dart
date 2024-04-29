import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class LiveStreamingPage extends StatefulWidget {
  final Map<String, String> cameraInfo;

  LiveStreamingPage({required this.cameraInfo});

  @override
  _LiveStreamingPageState createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage> with WidgetsBindingObserver {
  late FlutterFFmpeg _flutterFFmpeg;
  late VlcPlayerController _vlcController;
  late String _rtspUrl;

  @override
  void initState() {
    super.initState();
    _flutterFFmpeg = FlutterFFmpeg();
    String ip = widget.cameraInfo['ip']!;
    String username = widget.cameraInfo['username']!;
    String password = widget.cameraInfo['password']!;
    _rtspUrl = 'rtsp://$username:$password@$ip:554/stream1';
    _vlcController = VlcPlayerController.network(_rtspUrl);
    startStreaming();
  }

  @override
  void dispose() {
    _flutterFFmpeg.cancel();
    _vlcController.dispose();
    super.dispose();
  }

  void startStreaming() async {
    // Execute FFmpeg command to start streaming
    int rc = await _flutterFFmpeg.execute(
        '-rtsp_transport tcp -i $_rtspUrl -c:v copy -c:a aac -f flv -');

    if (rc == 0) {
      print('Streaming started successfully');
    } else {
      print('Error starting streaming');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Stream'),
      ),
      body: Center(
        child: VlcPlayer(
          controller: _vlcController,
          aspectRatio: 16 / 9,
          placeholder: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
