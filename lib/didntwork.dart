// import 'dart:typed_data';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
// import 'package:tflite/tflite.dart';
// import 'package:image/image.dart' as img;

// class LiveStreamingPage extends StatefulWidget {
//   final Map<String, String> cameraInfo;

//   LiveStreamingPage({required this.cameraInfo});

//   @override
//   _LiveStreamingPageState createState() => _LiveStreamingPageState();
// }

// class _LiveStreamingPageState extends State<LiveStreamingPage> with WidgetsBindingObserver {
//   late FlutterFFmpeg _flutterFFmpeg;
//   late String _rtspUrl;
//   late bool isStreaming;
//   late List<dynamic> recognitionsList;
//   Uint8List? currentFrame;

//   @override
//   void initState() {
//     super.initState();
//     _flutterFFmpeg = FlutterFFmpeg();
//     String ip = widget.cameraInfo['ip']!;
//     String username = widget.cameraInfo['username']!;
//     String password = widget.cameraInfo['password']!;
//     _rtspUrl = 'rtsp://$username:$password@$ip:554/stream1';
//     isStreaming = false;
//     recognitionsList = [];
//     loadModel();
//     startStreaming();
//   }

//   @override
//   void dispose() {
//     _flutterFFmpeg.cancel();
//     super.dispose();
//   }

//   void startStreaming() async {
//     setState(() {
//       isStreaming = true;
//     });

//     // Execute FFmpeg command to capture frames from RTSP stream
//     await _flutterFFmpeg.executeWithArguments([
//       '-rtsp_transport', 'tcp',
//       '-i', _rtspUrl,
//       '-vf', 'fps=1', // Capture one frame per second
//       '-f', 'image2pipe',
//       '-vcodec', 'mjpeg',
//       'pipe:1'
//     ]).then((rc) {
//       if (rc == 0) {
//         print('Streaming started successfully');
//       } else {
//         print('Error starting streaming');
//       }
//     });
//   }

//   Future<void> loadModel() async {
//     await Tflite.loadModel(
//       model: "assets/model/yolov5s.tflite",
//       labels: "assets/label/labels.txt",
//     );
//   }

//   Future<void> runModel(Uint8List imageBytes) async {
//     // Get temporary directory
//     final tempDir = await getTemporaryDirectory();
//     final tempFile = File('${tempDir.path}/frame.jpg');

//     // Write bytes to the file
//     await tempFile.writeAsBytes(imageBytes);

//     // Perform object detection on the image file
//     List<dynamic>? recognitions = await Tflite.detectObjectOnImage(
//       path: tempFile.path,
//       numResultsPerClass: 1,
//       threshold: 0.4,
//     );

//     if (recognitions != null) {
//       for (var recognition in recognitions) {
//         print('Detected ${recognition['detectedClass']} with confidence ${recognition['confidenceInClass']}');
//       }
//     }

//     setState(() {
//       recognitionsList = recognitions ?? [];
//     });
//   }

//   List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
//     if (recognitionsList.isEmpty) return [];

//     double factorX = screen.width;
//     double factorY = screen.height;

//     Color colorPick = Colors.pink;

//     return recognitionsList.map((result) {
//       return Positioned(
//         left: result["rect"]["x"] * factorX,
//         top: result["rect"]["y"] * factorY,
//         width: result["rect"]["w"] * factorX,
//         height: result["rect"]["h"] * factorY,
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(10.0)),
//             border: Border.all(color: Colors.pink, width: 2.0),
//           ),
//           child: Text(
//             "${result['detectedClass']} ${(result['confidenceInClass'] * 100).toStringAsFixed(0)}%",
//             style: TextStyle(
//               background: Paint()..color = colorPick,
//               color: Colors.black,
//               fontSize: 18.0,
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Live Stream'),
//       ),
//       body: isStreaming
//           ? Stack(
//               children: <Widget>[
//                 currentFrame != null
//                     ? Image.memory(
//                         currentFrame!,
//                         width: size.width,
//                         height: size.height,
//                         fit: BoxFit.cover,
//                       )
//                     : Container(
//                         color: Colors.black,
//                         width: size.width,
//                         height: size.height,
//                         child: Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                       ),
//                 ...displayBoxesAroundRecognizedObjects(size),
//               ],
//             )
//           : Center(
//               child: Text("Waiting for stream to start..."),
//             ),
//     );
//   }
// }
