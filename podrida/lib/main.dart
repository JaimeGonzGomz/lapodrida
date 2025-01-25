import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/game/game_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: 'https://zbiqcmbliekgryhgwmdo.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpiaXFjbWJsaWVrZ3J5aGd3bWRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc3OTY1ODYsImV4cCI6MjA1MzM3MjU4Nn0.EVdaUW6pYcFaHYxjJez6yHmz23eMLPe4NUp8jLQbEGE');

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
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
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.session != null) {
            return const GameScreen();
          }
          return LoginScreen();
        },
      ),
    );
  }
}
