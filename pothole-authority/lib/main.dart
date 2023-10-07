import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:geocoder/geocoder.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:my_app/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(title: 'Pothole detection'),
    );
  }
}
