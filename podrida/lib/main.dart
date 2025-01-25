import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/game/game_screen.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  try {
    await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ));
  } catch (e) {
    print('Supabase initialization failed: $e');
    // Handle error appropriately
  }

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
