import 'package:flutter/material.dart';
import 'package:wc_2026_sticker_collector/view/welcome_screen.dart';
import 'package:wc_2026_sticker_collector/viewmodel/account_view_model.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, required this.title});

  final String title;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final accountViewModel = AccountViewModel();
  
  @override
  Widget build (BuildContext context) {
    final padding = MediaQuery.widthOf(context)/10;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.directional(start: padding, end: padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ListTile(
                trailing: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Terminar Sessão", 
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Terminar Sessão"),
                        content: const Text("Tem a certeza que deseja sair da sua conta?"),
                        actions: [
                          // Cancel Button
                          TextButton(
                            onPressed: () => Navigator.pop(context), 
                            child: const Text("Cancelar"),
                          ),
                          // Confirm Button
                          TextButton(
                            onPressed: () async {
                              // Close the dialog first
                              Navigator.pop(context); 

                              try {
                                await accountViewModel.signOutUser();

                                if (!context.mounted) return;

                                // Send user back to Login
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => WelcomeScreen(title: widget.title)),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString()))
                                );
                              }
                            },
                            child: const Text(
                              "Sair", 
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              )
            ]
          )
        )
      )
    );
  }
}