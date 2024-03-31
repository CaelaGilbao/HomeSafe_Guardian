import 'package:homesafe_guardian_app/features/addcamera.dart';
import 'package:homesafe_guardian_app/features/automaticsearch.dart';
import 'package:homesafe_guardian_app/features/homepage.dart';
import 'package:homesafe_guardian_app/features/manualyaddcamera.dart';
import 'features/start_up.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); // Call the function from the imported file
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> connectedCameras = [];
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      initialRoute: 'home',
      routes: {
        'home': (context) => StartUp(),
        'homepage': (context) => Homepage(connectedCameras: connectedCameras),
        'addcamera': (context) =>  AddCamera(),
        'automaticsearch': (context) => AutomaticSearch(),
        'manualaddcamera': (context) => ManualAddCamera(),
      },
      home: StartUp(),
    );
  }
}
