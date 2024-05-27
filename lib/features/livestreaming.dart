import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class LiveStreamingPage extends StatefulWidget {
  final Map<String, String> cameraInfo;
  final String cameraName;

  LiveStreamingPage({required this.cameraInfo, required this.cameraName});

  @override
  _LiveStreamingPageState createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage> {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  late String _rtspUrl;
  late FlutterVision vision;
  bool _isDetecting = false;
  bool _isModelLoaded = false;
  List<Map<String, dynamic>> _yoloResults = [];
  bool _isFullScreen = false;
  late VlcPlayerController _vlcController;

  @override
  void initState() {
    super.initState();
    String ip = widget.cameraInfo['ip']!;
    String username = widget.cameraInfo['username']!;
    String password = widget.cameraInfo['password']!;
    _rtspUrl = 'rtsp://$username:$password@$ip:554/stream1';
    vision = FlutterVision();
    _vlcController = VlcPlayerController.network(
      _rtspUrl,
      autoPlay: true,
      options: VlcPlayerOptions(),
      onInit: () {
        _loadYoloModel();
      },
    );
  }

  @override
  void dispose() {
    _vlcController.dispose();
    vision.closeYoloModel();
    super.dispose();
  }

  Future<void> _loadYoloModel() async {
    print('Loading YOLO model...');
    try {
      await vision.loadYoloModel(
        labels: 'assets/label/labels.txt',
        modelPath: 'assets/model/yolov5s.tflite',
        modelVersion: "yolov5",
        quantization: true,
        numThreads: 2,
        useGpu: false,
      );
      setState(() {
        _isModelLoaded = true;
      });
      print('YOLO model loaded');
      _processFramePeriodically();
    } catch (e) {
      print('Error loading YOLO model: $e');
    }
  }

  Future<void> _processFramePeriodically() async {
    print('Processing frames periodically...');
    while (mounted) {
      await _processFrame();
      await Future.delayed(Duration(milliseconds: 1000 ~/ 30));
    }
  }

  Future<void> _processFrame() async {
  if (!_isDetecting && _isModelLoaded) {
    _isDetecting = true;
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String outputImagePath = '${directory.path}/frame_$timestamp.jpg';

      // Extract frame
      final int ffmpegResult = await _flutterFFmpeg.execute(
          '-i $_rtspUrl -vframes 1 -q:v 2 $outputImagePath');
      if (ffmpegResult != 0) {
        print('Error extracting frame with ffmpeg');
        _isDetecting = false;
        return;
      }
      print('Frame extracted: $outputImagePath');

      // Load and get dimensions of the extracted image
      final Uint8List fileData = await File(outputImagePath).readAsBytes();
      final img.Image originalImage = img.decodeImage(fileData)!;
      print('Original image dimensions: ${originalImage.width} x ${originalImage.height}');

      // YOLO Inference using original dimensions
      print('Running YOLO inference...');
      final yoloResults = await vision.yoloOnFrame(
        bytesList: [fileData],
        imageHeight: originalImage.height,
        imageWidth: originalImage.width,
        iouThreshold: 0.3,
        confThreshold: 0.3,
        classThreshold: 0.3,
      );
      print('YOLO inference completed: $yoloResults');

      // Update results and clean up old frames
      setState(() {
        _yoloResults = yoloResults;
      });
      print('Results updated: $_yoloResults');
    } catch (e) {
      print('Error processing frame: $e');
    } finally {
      _isDetecting = false;
      print('Frame processing completed');
    }
  }
}


  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.videocam, color: Colors.white),
            SizedBox(width: 8),
            Text(
              widget.cameraName,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        leadingWidth: 40,
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: VlcPlayer(
                controller: _vlcController,
                aspectRatio: _isFullScreen ? MediaQuery.of(context).size.aspectRatio : 16 / 9,
                placeholder: Center(child: CircularProgressIndicator()),
              ),
            ),
            ..._displayBoxesAroundRecognizedObjects(MediaQuery.of(context).size),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _toggleFullScreen,
                child: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _displayBoxesAroundRecognizedObjects(Size screen) {
    if (_yoloResults.isEmpty) return [];

    double factorX = screen.width / 416;
    double factorY = screen.height / 416;
    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return _yoloResults.map((detectionResult) {
      return Stack(
        children: [
          Positioned(
            left: detectionResult["box"][0] * factorX,
            top: detectionResult["box"][1] * factorY,
            width: (detectionResult["box"][2] - detectionResult["box"][0]) * factorX,
            height: (detectionResult["box"][3] - detectionResult["box"][1]) * factorY,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                border: Border.all(color: Colors.pink, width: 2.0),
              ),
            ),
          ),
          Positioned(
            left: (detectionResult["box"][0] * factorX) - 5,
            top: (detectionResult["box"][1] * factorY) - 25,
            child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: colorPick,
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Text(
                "${detectionResult['tag']} ${(detectionResult['box'][4] * 100).toStringAsFixed(0)}%",
                style: const TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
