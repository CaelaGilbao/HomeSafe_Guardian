// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:tflite/tflite.dart';
// import 'dart:ui' as ui;
// import 'package:image/image.dart' as imglib;

// class LiveStreamingPage extends StatefulWidget {
//   final Map<String, String> cameraInfo;

//   LiveStreamingPage({required this.cameraInfo});

//   @override
//   _LiveStreamingPageState createState() => _LiveStreamingPageState();
// }

// class _LiveStreamingPageState extends State<LiveStreamingPage> {
//   late VlcPlayerController _vlcController;
//   late String _rtspUrl;

//   @override
//   void initState() {
//     super.initState();
//     _rtspUrl = 'rtsp://${widget.cameraInfo['username']}:'
//         '${widget.cameraInfo['password']}@${widget.cameraInfo['ip']}:554/stream1';
//     _vlcController = VlcPlayerController.network(_rtspUrl);
//     _vlcController.addListener(_onFrameReceived);
//     _initializeModel();
//   }

//   @override
//   void dispose() {
//     _vlcController.dispose();
//     Tflite.close();
//     super.dispose();
//   }

//   void _onFrameReceived() async {
//     if (_vlcController.value.isPlaying) {
//       Uint8List? frameData = await _vlcController.takeSnapshot();
//       if (frameData != null) {
//         await _processFrame(frameData);
//       } else {
//         print('Frame data is null');
//       }
//     } else {
//       print('VLC controller is not playing');
//     }
//   }

//   void _initializeModel() async {
//     print('Initializing model...');
//     String modelPath = 'assets/model/yolov5s.tflite'; 
//     String labelsPath = 'assets/label/labels.txt';
//     await Tflite.loadModel(model: modelPath, labels: labelsPath);
//     print('Model initialized.');
//   }

//   Future<void> _processFrame(Uint8List frameData) async {
//   // Convert frameData to Image
//   ui.Image image = await decodeImageFromList(frameData);

//   // Convert Image to ImageData
//   imglib.Image imageData = imglib.Image.fromBytes(
//     image.width,
//     image.height,
//     frameData,
//   );

//   // Perform object detection on the image data
//   List<dynamic>? recognitions = await Tflite.detectObjectOnBinary(
//     binary: imageToByteListFloat32(imageData, 416, 0.0, 255.0),
//     model: "YOLO",
//     threshold: 0.3,
//     numResultsPerClass: 2,
//     anchors: anchors,
//     blockSize: 32,
//     numBoxesPerBlock: 5,
//     asynch: true,
//   );

//   // Process the recognition results
//   if (recognitions != null && recognitions.isNotEmpty) {
//     print('Detected objects: $recognitions');
//     // Update UI or perform other actions based on detections
//   } else {
//     print('No objects detected');
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Live Stream'),
//       ),
//       body: Center(
//         child: VlcPlayer(
//           controller: _vlcController,
//           aspectRatio: 16 / 9,
//           placeholder: Center(child: CircularProgressIndicator()),
//         ),
//       ),
//     );
//   }
// }
