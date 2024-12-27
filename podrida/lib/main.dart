// In main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_demo_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [], // This hides both status and navigation bars until user swipes
  );

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
