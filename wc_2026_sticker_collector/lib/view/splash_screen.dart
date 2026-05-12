import 'package:flutter/material.dart';
import 'package:wc_2026_sticker_collector/model/sticker_catalog_service.dart';
import 'package:wc_2026_sticker_collector/view/home_page_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.title});

  final String title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<void> catalogFuture;

  @override
  void initState() {
    super.initState();
    // makes sure that the load only happens once when entering the app
    catalogFuture = stickerService.loadCatalog();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: catalogFuture,
      builder: (context, snapshot) {
        
        // While downloading, show a loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Once it's done, move to the actual app
        return HomePageScreen(title: widget.title); 
      },
    );
  }
}