import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wc_2026_sticker_collector/model/sticker_catalog_service.dart';
import 'package:wc_2026_sticker_collector/model/sticker_data.dart';
import 'package:wc_2026_sticker_collector/model/user_profile.dart';
import 'package:wc_2026_sticker_collector/view/album_screen.dart';
import 'package:wc_2026_sticker_collector/view/welcome_screen.dart';
import 'package:wc_2026_sticker_collector/viewmodel/account_view_model.dart';
import 'package:wc_2026_sticker_collector/viewmodel/sticker_view_model.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, required this.title});

  final String title;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final accountViewModel = AccountViewModel();
  final stickerViewModel = StickerViewModel();

  late TextEditingController stickerController;
  late TextEditingController addFriendController;

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    stickerController = TextEditingController();
    addFriendController = TextEditingController();
  }

  @override
  void dispose() {
    addFriendController.dispose();
    stickerController.dispose();
    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    final padding = (MediaQuery.widthOf(context) / 12).clamp(16.0, 100.0);

    // safely handle the split-second where it might be null
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:Text(widget.title),
        centerTitle: true,
        leadingWidth: 180,
        leading: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 10.0),
          child: Image(
            image: AssetImage("assets/images/Logo_caxoro.png"),
            fit: BoxFit.fitWidth),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          
          // 1. Handle Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handle Errors
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final profile = UserProfile.fromFirestore(currentUser!.uid, data);

          return Center(
            child: Padding(
              padding: EdgeInsetsGeometry.directional(start: padding, end: padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 15,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          TextSpan(text:'👋\nBem-vindo ',
                            style: TextStyle(fontSize: 32)
                          ),
                          TextSpan(text: profile.username,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)
                          ),
                        ]
                      )
                    )
                  ),
                  Expanded(
                    flex: 75,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // If the screen is wider than 800 pixels (PC / Tablet)
                        if (constraints.maxWidth > 800) {
                          return Row(
                            children: [
                              Expanded(
                                flex: 60,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Coleção", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                                      SizedBox(height: 10.0),
                                      Padding(
                                        padding: EdgeInsetsGeometry.symmetric(horizontal: padding),
                                        child: TextFormField(
                                          controller: stickerController,
                                          textInputAction: TextInputAction.done, 
                                          onFieldSubmitted: (_) => _registerSticker(),
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            labelText: 'Código do cromo',
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                Icons.add_circle_outline
                                              ),
                                              onPressed: () => _registerSticker()
                                            )
                                          ),
                                        ),
                                      ),
                                      for (var group in StickerData.groups.entries)
                                        groupWidget(group, profile)
                                    ],
                                  ),
                                )
                              ),
                              VerticalDivider(width: 5, color: Colors.grey[400], thickness: 5),
                              Expanded(
                                flex: 40,
                                child: userInfo(profile)
                              )
                            ]
                          );
                        }
                        else {
                          return SingleChildScrollView( // Allows scrolling on small phones
                            child: Column(
                              children: [
                                Text("A tua coleção", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                                for (var group in StickerData.groups.entries)
                                  groupWidget(group, profile),

                                Divider(height: 20, color: Theme.of(context).appBarTheme.backgroundColor),
                                userInfo(profile),
                              ],
                            ),
                          );
                        }
                      }
                    ) 
                  ),
                  Expanded(
                    flex: 5,
                    child: TextButton(
                      child: const Text(
                        "Terminar Sessão", 
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
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
                  ),
                  SizedBox(height: 20.0),
                  Expanded(
                    flex:5,
                    child: Text(
                      "This app is a fan-made project and is not affiliated with, sponsored by, or endorsed by Panini S.p.A., The Coca-Cola Company or FIFA. All product names, logos, and brands are property of their respective owners.",
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    )
                  )
                ]
              )
            )
          );
        }
      )
    );
  }
  

  Widget groupWidget(MapEntry<String, List<String>> group, UserProfile profile) {
    final padding = MediaQuery.heightOf(context)/32;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding), 
      child: Row(
        // Aligns the text to the top if the chips wrap to multiple lines
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          
          SizedBox(
            width: 80, // Optional: Force a fixed width so all group texts align perfectly
            child: Text(
              group.key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 16), // A little gap between the text and the chips

          Expanded(
            child: Wrap(
              spacing: 16.0, // Gap between chips horizontally
              runSpacing: 8.0, // Gap between chips vertically (if they wrap to a new line)
              children: group.value.map((countryCode) {
                
                String displayName = StickerData.paniniToName[countryCode] ?? countryCode;

                // total amount of stickers for this country/sticker group
                int total = stickerService.groupedCatalog.containsKey(countryCode) ? stickerService.groupedCatalog[countryCode]!.length : 0;
                // amount collected by user
                int collected = profile.stickersCollected[countryCode]?.values.where((amount) => amount > 0).length ?? 0;

                double progress = (total == 0) ? 0.0 : (collected / total);
                bool isComplete = (collected == total);

                return ActionChip(
                  avatar: Stack(
                    alignment: Alignment.center,
                    children: [
                      // flag
                      StickerData.getFlagAvatar(countryCode), 
                      
                      // progress circle
                      SizedBox(
                        width: 28, // Make it slightly larger than the 24px flag
                        height: 28,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2.5, // Thickness of the ring
                          backgroundColor: Colors.grey[300],
                          color: isComplete ? Colors.green : Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  
                  // The label just stays simple text now
                  label: Text(
                    "$displayName  $collected/$total",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: Colors.grey[100],

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlbumScreen(title: widget.title, countryCode: countryCode),
                      )
                    );
                  },
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget userInfo(UserProfile profile) {
    final padding = MediaQuery.widthOf(context)/12;
    Future<List<UserProfile>> friendsFuture = profile.getFriendsInfo();
    
    int totalStickers = stickerService.flatCatalog.length;
    int collectedStickers = 0;

    profile.stickersCollected.forEach((_, countryMap) {
      collectedStickers += countryMap.values.where((amount) => amount > 0).length;
    });

    double totalProgress = (totalStickers == 0) ? 0.0 : (collectedStickers/totalStickers)*100;

    int missingStickers = totalStickers - collectedStickers;

    List<String> duplicates = profile.getUserDuplicates();

    return SingleChildScrollView(
      child: Column(
        children: [
          Text("Amigos (${profile.friendCount()}/5)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
          SizedBox(height: 10),

          // field where you write a user's name to add it to your friend list (means that you can follow his profile)
          Text("Adicionar amigos"),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: padding),
            child: TextField(
              controller: addFriendController,
              textInputAction: TextInputAction.done, 
              onSubmitted: (_) => _addFriend(profile),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Nome de utilizador',
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.add_circle_outline
                  ),
                  onPressed: () => _addFriend(profile)
                )
              )
            ),
          ),

          SizedBox(height: 20),

          FutureBuilder<List<UserProfile>>(
            future: friendsFuture, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasData) {
                List<UserProfile> friendProfiles = snapshot.data!;

                if (friendProfiles.isEmpty) {
                  return const Text("Ainda não tens amigos :(\nAdiciona alguém!", style: TextStyle(fontSize: 20));
                }

                else {
                  return Wrap(
                    spacing: 8.0,
                    children: friendProfiles.map((profile) {
                      return ActionChip(
                        label: Text(profile.username, style: const TextStyle(fontSize: 20)),
                        onPressed: () {
                          // Logic to view friend's album
                        },
                      );
                    }).toList(),
                  );
                }
              }
              else {
                return Text("Erro a sacar os teus amigos");
              }
            }
          ),
          Divider(height: 40, color: Colors.grey[400]),
          Text("A tua coleção", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
          SizedBox(height: 40),
          ActionChip(
            label: Text("Nº de duplicados: ${duplicates.length}", style: TextStyle(fontSize: 20)),
            backgroundColor: Colors.grey[100],
            onPressed: () {},
          ),
          SizedBox(height: 20),
          Text("Progresso total: ${totalProgress.toStringAsFixed(2)}%", style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          Text("Faltam-te $missingStickers cromos", style: TextStyle(fontSize: 20)),
        ]
      )
    );
  }

  Future<void> _registerSticker() async {
    String stickerCode = stickerController.text;
    if (!stickerService.flatCatalog.any((sticker) => sticker['code'] == stickerCode.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cromo $stickerCode não existe.\nVerifica se escreveste o código exatamente como apresentado no cromo.")));
    }
    else {
      try {
        final categoryCode = stickerService.getCategoryCode(stickerCode);

        await stickerViewModel.incrementCard(currentUser!.uid, categoryCode, stickerCode);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cromo $stickerCode adicionada à coleção")));

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _addFriend(UserProfile profile) async {
    String friendUsername = addFriendController.text;

    try {
      await profile.addFriend(friendUsername);

      if (!mounted) return;

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}