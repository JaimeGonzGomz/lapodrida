import 'package:flutter/material.dart';
import 'game_demo_screen.dart';

void main() {
  runApp(const PodridaApp());
}

class PodridaApp extends StatelessWidget {
  const PodridaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Podrida',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameDemoScreen(),
    );
  }
}
