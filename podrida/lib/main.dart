import 'package:flutter/material.dart';
import 'game_demo_screen.dart';

void main() {
  runApp(const PodridaApp());
}

class PodridaApp extends StatelessWidget {
  const PodridaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Podrida',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GameDemoScreen(),
    );
  }
}
