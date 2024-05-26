// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/services.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:flutter_vision/flutter_vision.dart';

// class LiveStreamingPage extends StatefulWidget {
//   final Map<String, String> cameraInfo;
//   final String cameraName; // Add this line

//   LiveStreamingPage({required this.cameraInfo, required this.cameraName}); // Modify this line

//   @override
//   _LiveStreamingPageState createState() => _LiveStreamingPageState();
// }


// class _LiveStreamingPageState extends State<LiveStreamingPage> {
//   late VlcPlayerController _vlcController;
//   late String _rtspUrl;
//   late FlutterVision vision;
//   bool _isDetecting = false;
//   bool _isModelLoaded = false;
//   List<Map<String, dynamic>> _yoloResults = [];
//   bool _isFullScreen = false; // Add this flag

//   @override
//   void initState() {
//     super.initState();
//     String ip = widget.cameraInfo['ip']!;
//     String username = widget.cameraInfo['username']!;
//     String password = widget.cameraInfo['password']!;
//     _rtspUrl = 'rtsp://$username:$password@$ip:554/stream1';
//     _vlcController = VlcPlayerController.network(
//       _rtspUrl,
//       autoPlay: true,
//       options: VlcPlayerOptions(),
//       onInit: () {
//         print('VLC player initialized');
//         _loadYoloModel();
//       },
//     );
//     vision = FlutterVision();
//   }

//   @override
//   void dispose() {
//     _vlcController.dispose();
//     vision.closeYoloModel();
//     super.dispose();
//   }

//   Future<void> _loadYoloModel() async {
//     print('Loading YOLO model...');
//     try {
//       await vision.loadYoloModel(
//         labels: 'assets/label/labels.txt',
//         modelPath: 'assets/model/yolov5s.tflite',
//         modelVersion: "yolov5",
//         quantization: true,
//         numThreads: 2,
//         useGpu: false, // Set to false for testing without GPU delegate
//       );

//       setState(() {
//         _isModelLoaded = true;
//       });
//       print('YOLO model loaded');
//       _processFramePeriodically();
//     } catch (e) {
//       print('Error loading YOLO model: $e');
//     }
//   }

//   Future<void> _processFramePeriodically() async {
//     print('Processing frames periodically...');
//     while (mounted) {
//       await _processFrame();
//       await Future.delayed(Duration(milliseconds: 1000 ~/ 30));
//     }
//   }

//   Future<void> _processFrame() async {
//     if (!_isDetecting &&
//         _vlcController.value.isInitialized &&
//         _isModelLoaded) {
//       _isDetecting = true;
//       try {
//         print('Capturing snapshot...');
//         final snapshot = await _vlcController.takeSnapshot();
//         print('Snapshot captured');

//         print('Decoding snapshot to image...');
//         final ui.Codec codec = await ui.instantiateImageCodec(snapshot);
//         final ui.FrameInfo frameInfo = await codec.getNextFrame();
//         final ui.Image img = frameInfo.image;
//         print('Image decoded');

//         print('Converting image to ByteData...');
//         final ByteData? byteData =
//             await img.toByteData(format: ui.ImageByteFormat.rawRgba);
//         if (byteData == null) {
//           print('ByteData conversion failed');
//           setState(() {
//             _yoloResults = [];
//           });
//           _isDetecting = false;
//           return;
//         }
//         final Uint8List imageData = byteData.buffer.asUint8List();
//         print('Image converted to ByteData');
//         print('Image dimensions: ${img.width} x ${img.height}');
//         print('ByteData length: ${imageData.length}');

//         // Resize image if necessary for performance
//         // Use a lower resolution if the current resolution is too high
//         final int targetWidth = 416;
//         final int targetHeight = 416;
//         final ByteData resizedData =
//             await resizeImage(img, targetWidth, targetHeight);
//         final Uint8List resizedImageData =
//             resizedData.buffer.asUint8List();
//         print('Image resized to: $targetWidth x $targetHeight');

//         print('Running YOLO inference...');
//         final result = await vision.yoloOnFrame(
//           bytesList: [resizedImageData],
//           imageHeight: targetHeight,
//           imageWidth: targetWidth,
//           iouThreshold: 0.3, // Lower IOU threshold for testing
//           confThreshold: 0.3, // Lower confidence threshold for testing
//           classThreshold: 0.3, // Lower class threshold for testing
//         );
//         print('YOLO inference completed');
//         print('Inference result: $result');

//         setState(() {
//           _yoloResults = result;
//         });
//         print('Results updated: $_yoloResults');
//       } catch (e) {
//         print('Error processing frame: $e');
//       } finally {
//         _isDetecting = false;
//         print('Frame processing completed');
//       }
//     } else {
//       print(
//           'Skipping frame processing: detecting=$_isDetecting, initialized=${_vlcController.value.isInitialized}, modelLoaded=$_isModelLoaded');
//     }
//   }

//   // Helper function to resize image
//   Future<ByteData> resizeImage(
//       ui.Image image, int targetWidth, int targetHeight) async {
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);
//     final paint = Paint();
//     final src = Rect.fromLTWH(
//         0, 0, image.width.toDouble(), image.height.toDouble());
//     final dst = Rect.fromLTWH(
//         0, 0, targetWidth.toDouble(), targetHeight.toDouble());
//     canvas.drawImageRect(image, src, dst, paint);
//     final ui.Picture picture = recorder.endRecording();
//     final ui.Image resizedImage =
//         await picture.toImage(targetWidth, targetHeight);
//     final ByteData? byteData =
//         await resizedImage.toByteData(format: ui.ImageByteFormat.rawRgba);
//     if (byteData == null) {
//       throw Exception('Failed to convert image to ByteData');
//     }
//     return byteData;
//   }

//   void _toggleFullScreen() {
//     setState(() {
//       _isFullScreen = !_isFullScreen;
//     });
//     if (_isFullScreen) {
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//       SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
//     } else {
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//       SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
//     }
//   }

//   @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.black,
//     appBar: AppBar(
//       title: Row(
//         children: [
//           Icon(Icons.videocam, color: Colors.white), // Camera icon
//           SizedBox(width: 8), // Spacer
//           Text(
//             widget.cameraName,
//             style: TextStyle(
//               color: Colors.white,
//               fontFamily: 'Montserrat',
//             ),
//           ),
//         ],
//       ),
//       backgroundColor: Colors.black,
//       iconTheme: IconThemeData(color: Colors.white),
//       leadingWidth: 40, // Set leading width to reduce space
//     ),
//     body: Container(
//       color: Colors.black,
//       child: Stack(
//         children: [
//           Center(
//             child: VlcPlayer(
//               controller: _vlcController,
//               aspectRatio: _isFullScreen ? MediaQuery.of(context).size.aspectRatio : 16 / 9,
//               placeholder: Center(child: CircularProgressIndicator()),
//             ),
//           ),
//           ..._displayBoxesAroundRecognizedObjects(MediaQuery.of(context).size),
//           Positioned(
//             bottom: MediaQuery.of(context).padding.bottom + 16, // Align with bottom of screen including bottom padding
//             right: 16,
//             child: FloatingActionButton(
//               onPressed: _toggleFullScreen,
//               child: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
//               backgroundColor: Colors.transparent,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }


// List<Widget> _displayBoxesAroundRecognizedObjects(Size screen) {
//   if (_yoloResults.isEmpty) return [];

//   double factorX = screen.width / 416; // Assuming 416 is the target width
//   double factorY = screen.height / 416; // Assuming 416 is the target height
//   Color colorPick = const Color.fromARGB(255, 50, 233, 30);

//   return _yoloResults.map((result) {
//     return Stack(
//       children: [
//         Positioned(
//           left: result["box"][0] * factorX,
//           top: result["box"][1] * factorY,
//           width: (result["box"][2] - result["box"][0]) * factorX,
//           height: (result["box"][3] - result["box"][1]) * factorY,
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.all(Radius.circular(10.0)),
//               border: Border.all(color: Colors.pink, width: 2.0),
//             ),
//           ),
//         ),
//         Positioned(
//           left: (result["box"][0] * factorX) - 5,
//           top: (result["box"][1] * factorY) - 25,
//           child: Container(
//             padding: const EdgeInsets.all(2.0),
//             decoration: BoxDecoration(
//               color: colorPick,
//               borderRadius: const BorderRadius.all(Radius.circular(5.0)),
//             ),
//             child: Text(
//               "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
//               style: const TextStyle(color: Colors.white, fontSize: 18.0),
//             ),
//           ),
//         ),
//       ],
//     );
//   }).toList();
// }
// }
