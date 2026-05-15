import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wc_2026_sticker_collector/firebase_options.dart';
import 'package:wc_2026_sticker_collector/view/splash_screen.dart';
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
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A398D),
          foregroundColor: Colors.white,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          
          // loading screen when checking if a user is authenticated
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // if it throws an error
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Ocorreu um erro! Reinicie e tente mais tarde")),
            );
          }
          
          // if the snapshot has data, the user is valid and logged in
          if (snapshot.hasData) {
            return const SplashScreen(title: "WC 2026 Sticker Collector® by Caxoro™");
          }
          
          // if it reaches here, user is not logged in yet
          return const WelcomeScreen(title: "WC 2026 Sticker Collector® by Caxoro™"); 
        },
      )
    );
  }
}