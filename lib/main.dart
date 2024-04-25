import 'package:flutter/material.dart';
import 'package:homesafe_guardian_app/features/addcamera.dart';
import 'package:homesafe_guardian_app/features/automaticsearch.dart';
import 'package:homesafe_guardian_app/features/homepage.dart';
import 'package:homesafe_guardian_app/features/manualyaddcamera.dart';

void main() {
  runApp(const MyApp()); // Call the function from the imported file
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      initialRoute: 'homepage',
      routes: {
        'homepage': (context) => Homepage(),
        'addcamera': (context) =>  AddCamera(),
        'automaticsearch': (context) => AutomaticSearch(),
        'manualaddcamera': (context) => ManuallyAddCamera(),
      },
    );
  }
}
