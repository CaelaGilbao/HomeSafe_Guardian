import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter_vision/flutter_vision.dart';

class LiveStreamingPage extends StatefulWidget {
  final Map<String, String> cameraInfo;
  final String cameraName;

  LiveStreamingPage({required this.cameraInfo, required this.cameraName});

  @override
  _LiveStreamingPageState createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage> {
  late VlcPlayerController _vlcController;
  late String _rtspUrl;
  late FlutterVision vision;
  bool _isDetecting = false;
  bool _isModelLoaded = false;
  List<Map<String, dynamic>> _yoloResults = [];
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    String ip = widget.cameraInfo['ip']!;
    String username = widget.cameraInfo['username']!;
    String password = widget.cameraInfo['password']!;
    _rtspUrl = 'rtsp://$username:$password@$ip:554/stream1';
    _vlcController = VlcPlayerController.network(
      _rtspUrl,
      autoPlay: true,
      options: VlcPlayerOptions(),
      onInit: () {
        print('VLC player initialized');
        _loadYoloModel();
      },
    );
    vision = FlutterVision();
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
    if (!_isDetecting &&
        _vlcController.value.isInitialized &&
        _isModelLoaded) {
      _isDetecting = true;
      try {
        print('Capturing snapshot...');
        final snapshot = await _vlcController.takeSnapshot();
        print('Snapshot captured: ${snapshot.length} bytes');

        print('Decoding snapshot to image...');
        final ui.Codec codec = await ui.instantiateImageCodec(snapshot);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        final ui.Image img = frameInfo.image;
        print('Image decoded: ${img.width}x${img.height}');

        print('Converting image to ByteData...');
        final ByteData? byteData =
            await img.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (byteData == null) {
          print('ByteData conversion failed');
          setState(() {
            _yoloResults = [];
          });
          _isDetecting = false;
          return;
        }
        final Uint8List imageData = byteData.buffer.asUint8List();
        print('Image converted to ByteData');
        print('ByteData length: ${imageData.length}');

        print('Running YOLO inference...');
        final result = await vision.yoloOnFrame(
          bytesList: [imageData],
          imageHeight: 1080, // fixed to 1080p
          imageWidth: 1920, // fixed to 1080p
          iouThreshold: 0.4,
          confThreshold: 0.4,
          classThreshold: 0.5,
        );
        print('YOLO inference completed');
        print('Inference result: $result');

        setState(() {
          _yoloResults = result;
        });
        print('Results updated: $_yoloResults');
      } catch (e) {
        print('Error processing frame: $e');
      } finally {
        _isDetecting = false;
        print('Frame processing completed');
      }
    } else {
      print(
          'Skipping frame processing: detecting=$_isDetecting, initialized=${_vlcController.value.isInitialized}, modelLoaded=$_isModelLoaded');
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
                aspectRatio: _isFullScreen
                    ? MediaQuery.of(context).size.aspectRatio
                    : 16 / 9,
                placeholder: Center(child: CircularProgressIndicator()),
              ),
            ),
            ..._displayBoxesAroundRecognizedObjects(MediaQuery.of(context).size),
          ],
        ),
      ),
    );
  }

  List<Widget> _displayBoxesAroundRecognizedObjects(Size screen) {
    if (_yoloResults.isEmpty) return [];

    double factorX = screen.width / 1920;
    double factorY = screen.height / 1080;
    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return _yoloResults.map((result) {
      return Stack(
        children: [
          Positioned(
            left: result["box"][0] * factorX,
            top: result["box"][1] * factorY,
            width: (result["box"][2] - result["box"][0]) * factorX,
            height: (result["box"][3] - result["box"][1]) * factorY,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                border: Border.all(color: Colors.pink, width: 2.0),
              ),
            ),
          ),
          Positioned(
            left: (result["box"][0] * factorX) - 5,
            top: (result["box"][1] * factorY) - 25,
            child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: colorPick,
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Text(
                "${result['tag']} ${(result['confidence'] * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
