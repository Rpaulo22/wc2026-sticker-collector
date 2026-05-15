import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wc_2026_sticker_collector/model/sticker_catalog_service.dart';
import 'package:wc_2026_sticker_collector/model/sticker_data.dart';
import 'package:wc_2026_sticker_collector/model/user_profile.dart';
import 'package:wc_2026_sticker_collector/view/album_screen.dart';
import 'package:wc_2026_sticker_collector/view/duplicates_screen.dart';
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
    final width = MediaQuery.widthOf(context);
    final padding = (width / 12).clamp(16.0, 100.0);
    bool isMobile = (width < 800);

    // safely handle the split-second where it might be null
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isMobile ? 80 : 56, // Tall on mobile, standard on PC
        title: Text(
          widget.title, 
          style: TextStyle(fontSize: isMobile ? 16 : 28),
          maxLines: isMobile ? 2 : 1,
        ),
        centerTitle: true,
        leadingWidth: isMobile ? 130 : 180,
        leading: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 10.0),
          child: Image(
            image: AssetImage("assets/images/Logo_caxoro.png"),
            fit: BoxFit.contain),
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
                  SizedBox(height:5),

                  Expanded(
                    flex: 10,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          TextSpan(text:'Bem-vindo ',
                            style: TextStyle(fontSize: 28)
                          ),
                          TextSpan(text: profile.username,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)
                          ),
                          TextSpan(text: " 👋",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)
                          ),
                        ]
                      )
                    )
                  ),
                  Expanded(
                    flex: 80,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // If the screen is wider than 800 pixels (PC / Tablet)
                        if (constraints.maxWidth > 800) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 60,
                                child: SingleChildScrollView(
                                  child: collectionWidget(profile)
                                )
                              ),
                              Expanded(
                                flex: 40,
                                child: userInfo(profile)
                              )
                            ]
                          );
                        }
                        else {
                          return SingleChildScrollView( // Allows scrolling on smaller phones
                            child: Column(
                              children: [
                                collectionWidget(profile),
                                SizedBox(height: 20),
                                userInfo(profile)
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
                              title: const Text("Terminar Sessão", textAlign: TextAlign.center),
                              content: const Text("Tem a certeza que deseja sair da sua conta?", textAlign: TextAlign.center),
                              actionsAlignment: MainAxisAlignment.spaceAround,
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
  
  Widget collectionWidget(UserProfile profile) {
    List<String> duplicates = profile.getUserDuplicates(); // the user's duplicate stickers

    return Container(
      width: double.infinity, // Forces the box to take full width
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Rounded corners
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Very soft modern shadow
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cromos", 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 30
                )
              ),

              TextButton(
                child: Text(
                  "Os teus duplicados (${duplicates.length})", 
                  style: TextStyle(
                    color: Color(0xFF2A398D),
                    fontWeight: FontWeight.bold,
                    fontSize: 26
                  )
                ),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => DuplicatesScreen(title: widget.title, profile: profile),
                    )
                  );
                },
              )
            ]
          ),
          const SizedBox(height: 10.0),
          const Text("Adicionar cromos", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: stickerController,
            textInputAction: TextInputAction.done, 
            onFieldSubmitted: (_) => _registerSticker(),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: 'Código do cromo',
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF2A398D),
                ),
                onPressed: () => _registerSticker()
              )
            ),
          ),
          for (var group in StickerData.groups.entries)
            groupWidget(group, profile)
        ],
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
                color: Color(0xFF2A398D)
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
    final width = MediaQuery.widthOf(context);
    final padding = width / 24;
    final bool isDesktop = width > 800; // check if we are on PC
    
    Future<List<UserProfile>> friendsFuture = profile.getFriendsInfo();
    
    int totalStickers = stickerService.flatCatalog.length; 
    int collectedStickers = 0; 

    profile.stickersCollected.forEach((_, countryMap) {
      collectedStickers += countryMap.values.where((amount) => amount > 0).length; 
    });

    double totalProgress = (totalStickers == 0) ? 0.0 : (collectedStickers/totalStickers)*100; 
    int missingStickers = totalStickers - collectedStickers; 

    // --- BOX 1: FRIENDS ---
    Widget friendsBox = Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: SingleChildScrollView( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text("Amigos (${profile.friendCount()}/5)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            const SizedBox(height: 15),

            const Text("Adicionar amigos", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            
            TextField(
              controller: addFriendController,
              textInputAction: TextInputAction.done, 
              onSubmitted: (_) => _addFriend(profile),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), 
                labelText: 'Nome de utilizador',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2A398D)),
                  onPressed: () => _addFriend(profile)
                )
              ),
            ),
            const SizedBox(height: 20),

            FutureBuilder<List<UserProfile>>(
              future: friendsFuture, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  List<UserProfile> friendProfiles = snapshot.data!;
                  if (friendProfiles.isEmpty) {
                    return const Text("Ainda não tens amigos :(\nAdiciona alguém!", style: TextStyle(fontSize: 16));
                  } else {
                    return Wrap(
                      spacing: 8.0,
                      children: friendProfiles.map((profile) {
                        return ActionChip(
                          backgroundColor: const Color(0xFF2A398D),
                          label: Text(profile.username, style: const TextStyle(fontSize: 16, color: Colors.white)),
                          onPressed: () {
                            showDialog(
                              context: context, 
                              builder: (BuildContext context) => friendDialog(profile)
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                } else {
                  return const Text("Erro a sacar os teus amigos");
                }
              }
            ),
          ],
        ),
      ),
    );

    // --- BOX 2: STATS ---
    Widget statsBox = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centers stats vertically in the box
        children: [
          const Text("A tua coleção", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
          const SizedBox(height: 25), 
          
          Row(
            children: [
              Expanded(
                flex: 30, 
                child: AspectRatio(
                  aspectRatio: 1, 
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: totalProgress / 100,
                          strokeWidth: 10, 
                          color: (missingStickers == 0) ? Colors.green : const Color(0xFF2A398D),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      Center(
                        child: Text(
                          "${totalProgress.toStringAsFixed(1)}%", 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A398D), fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20), 
              Expanded(
                flex: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$collectedStickers / $totalStickers", 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Faltam $missingStickers cromos", 
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              )
            ]
          )
        ],
      ),
    );

    return Padding(
      padding: EdgeInsetsGeometry.directional(start: padding),
      child: Column(
        children: [
          // divide the space in half for desktop
          isDesktop ? Expanded(flex: 50, child: statsBox) : statsBox,
           
          const SizedBox(height: 24),
          
          isDesktop ? Expanded(flex: 50, child: friendsBox) : friendsBox,
        ],
      ),
    );
  }

  Widget friendDialog(UserProfile friendProfile) {
    int totalStickers = stickerService.flatCatalog.length; // total amount of stickers in the whole collection

    int collectedStickers = 0; // how many sticker the friend has collected

    friendProfile.stickersCollected.forEach((_, countryMap) {
      collectedStickers += countryMap.values.where((amount) => amount > 0).length;
    });

    double totalProgress = (totalStickers == 0) ? 0.0 : (collectedStickers/totalStickers)*100; // friend's collection progress

    int missingStickers = totalStickers - collectedStickers; // how many stickers this friend is missing from the collectionn

    List<String> duplicates = friendProfile.getUserDuplicates(); // the friend's duplicates

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
      child: Padding(
        padding: const EdgeInsets.all(24.0), // Gives the dialog content some breathing room
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Text(
                friendProfile.username, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),

              ActionChip(
                label: Text("Duplicados: ${duplicates.length}", style: const TextStyle(fontSize: 18, color: Colors.white)),
                backgroundColor: const Color(0xFF2A398D),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => DuplicatesScreen(title: widget.title, profile: friendProfile),
                    )
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  SizedBox(
                    width: 200, // Looks good on both mobile and web!
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: totalProgress / 100,
                            strokeWidth: 10,  
                            color: (missingStickers == 0) ? Colors.green : const Color(0xFF2A398D),
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        Center(
                          child: Text(
                            "${totalProgress.toStringAsFixed(1)}%", 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A398D), fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20), 
                  Expanded(
                    flex: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$collectedStickers / $totalStickers", 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Faltam $missingStickers cromos", 
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  )
                ]
              )
            ]
          )
        )
      ),
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

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$stickerCode adicionada à coleção")));

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