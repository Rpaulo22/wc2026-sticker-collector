import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wc_2026_sticker_collector/firebase_options.dart';
import 'package:wc_2026_sticker_collector/view/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // if it's the duplicate app error
    if (e.toString().contains('duplicate-app')) {
      print('Firebase was already initialized natively');
    } else {
      // if it's a different error
      rethrow; 
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WC 2026 Sticker Collector',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF3CAC3B),
          brightness: Brightness.light,
        ),
        // You can also customize specific components
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A398D),
          foregroundColor: Colors.white,
        ),
      ),
      home: const WelcomeScreen(title: "WC 2026 Sticker Collector® by Caxoro™"),
    );
  }
}