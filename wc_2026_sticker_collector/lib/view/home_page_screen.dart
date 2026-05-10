import 'package:firebase_auth/firebase_auth.dart';
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

    User? currentUser = FirebaseAuth.instance.currentUser;

    // safely handle the split-second where it might be null
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Future<String> userNameFuture = accountViewModel.getUserName(currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsetsGeometry.directional(start: padding, end: padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FutureBuilder(
                  future: userNameFuture,
                  builder: (context, snapshot) { // waiting for user's name
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    else {
                      return RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(text:'👋\nBem-vindo ',
                              style: TextStyle(fontSize: 32)
                            ),
                            TextSpan(text: '${snapshot.data}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)
                            ),
                          ]
                        )
                      );
                    }
                  }
                ),
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
      )
    );
  }

  Map<String, List<String>> groups = {
    "Group A": ["MEX","RSA","KOR","CZE"],
    "Group B": ["CAN","BIH","QAT","SUI"],
    "Group C": ["BRA","MAR","HAI","SCO"],
    "Group D": ["USA","PAR","AUS","TUR"],
    "Group E": ["GER","CUW","CIV","ECU"],
    "Group F": ["NED","JPN","SWE","TUN"],
    "Group G": ["BEL","EGY","IRN","NZL"],
    "Group H": ["ESP","CPV","KSA","URU"],
    "Group I": ["FRA","SEN","IRQ","NOR"],
    "Group J": ["ARG","ALG","AUT","JOR"],
    "Group K": ["POR","COD","UZB","COL"],
    "Group L": ["ENG","CRO","GHA","PAN"],
    "Others":  ["00", "FWC", "CC"]
  };

}