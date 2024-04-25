import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class LiveStreaming extends StatefulWidget {
  final String rtspUrl;

  const LiveStreaming({Key? key, required this.rtspUrl}) : super(key: key);

  @override
  _LiveStreamingState createState() => _LiveStreamingState();
}

class _LiveStreamingState extends State<LiveStreaming> {
  late FlutterFFmpeg _flutterFFmpeg;

  @override
  void initState() {
    super.initState();
    _flutterFFmpeg = FlutterFFmpeg();
    _startStreaming();
  }

  void _startStreaming() async {
    // Command to start streaming
    String command = "-rtsp_transport tcp -i ${widget.rtspUrl} -c copy -f flv rtmp://example.com/live/stream";

    // Execute FFmpeg command
    int resultCode = await _flutterFFmpeg.execute(command);

    if (resultCode == 0) {
      print('Streaming started successfully');
    } else {
      print('Failed to start streaming. Error code: $resultCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Streaming'),
      ),
      body: Center(
        child: Text(
          'Live streaming of ${widget.rtspUrl}',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterFFmpeg.cancel();
    super.dispose();
  }
}
