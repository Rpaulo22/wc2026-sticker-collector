import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wc_2026_sticker_collector/model/sticker_catalog_service.dart';
import 'package:wc_2026_sticker_collector/model/sticker_data.dart';
import 'package:wc_2026_sticker_collector/model/user_profile.dart';
import 'package:wc_2026_sticker_collector/viewmodel/sticker_view_model.dart';

class AlbumScreen extends StatefulWidget {

  const AlbumScreen({super.key, required this.title, required this.countryCode});

  final String title;
  final String countryCode;

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {

  final stickerViewModel = StickerViewModel();

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    final padding = MediaQuery.widthOf(context)/12;

    // safely handle the split-second where it might be null
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          
          // when loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // if an error 
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Erro a sacar merdas.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final profile = UserProfile.fromFirestore(userData);

          // grab the stickers for the specific country 
          final countryStickers = stickerService.groupedCatalog[widget.countryCode] ?? [];

          // total amount of stickers for this country/sticker group
          int total = countryStickers.length;
          // amount collected by user
          int collected = profile.stickersCollected[widget.countryCode]?.values.where((amount) => amount > 0).length ?? 0;
      
          return Padding(
            padding: EdgeInsetsGeometry.directional(start: padding, end: padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 15,
                  child: ListTile(
                    leading: StickerData.getFlagAvatar(widget.countryCode),
                    title: Text(
                      StickerData.paniniToName[widget.countryCode]!, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32
                      ),
                      textAlign: TextAlign.center,
                    ),
                    trailing: StickerData.getFlagAvatar(widget.countryCode),
                  )
                ),
                Expanded(
                  flex: 75,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4 stickers per row
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9, // Classic rectangular sticker shape
                    ),
                    itemCount: countryStickers.length,
                    itemBuilder: (context, index) {
                      final sticker = countryStickers[index];
                      final String stickerCode = sticker['code']; // sticker code (e.g BRA1, HAI17)

                      int amountOwned = profile.amountOwned(stickerCode); // how many of this sticker a user has

                      return Container(
                        decoration: BoxDecoration(
                          color:  (amountOwned > 0) ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Expanded forces the text to take up all the empty space at the top
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsGeometry.symmetric(horizontal: 12.0),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Text(
                                        stickerCode,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: (amountOwned > 0) ? Theme.of(context).primaryColor : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    Divider(height: 6.0, color: Theme.of(context).primaryColor),
                                    Center(
                                      child: Text(
                                        sticker['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: (amountOwned > 0) ? Theme.of(context).primaryColor : Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ]
                                )
                              )
                            ),

                            // A small container to house the controls
                            Container(
                              height: 36, // Keep it compact!
                              decoration: BoxDecoration(
                                color: (amountOwned > 0) ? Colors.blue[100] : Colors.grey[300],
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  
                                  // Decrement Button (-)
                                  GestureDetector(
                                    onTap: () async {
                                      // dont let it go below 0
                                      if (amountOwned > 0) {
                                        try {
                                          await stickerViewModel.decrementCard(currentUser.uid, widget.countryCode, stickerCode);
                                          if (!context.mounted) return;
                                        }
                                        catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Não é possível ter cartas negativas otário")));
                                      }
                                    },
                                    // Lower the opacity if they have 0 to show it's disabled
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      size: 20,
                                      color: amountOwned > 0 ? Colors.redAccent : Colors.grey[400],
                                    ),
                                  ),

                                  Text(
                                    '$amountOwned',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),

                                  // 3. Increment Button (+)
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        await stickerViewModel.incrementCard(currentUser.uid, widget.countryCode, stickerCode);
                                        if (!context.mounted) return;
                                      }
                                      catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                      }
                                    },
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      size: 20,
                                      color: Colors.green,
                                    ),
                                  ),
                                  
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ),
                Expanded(
                  flex: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Cartas: $collected/$total"),
                      SizedBox(
                        width: 100, // prevents progress indicator from crashing
                        child: LinearProgressIndicator(
                          value: (total != 0) ? (collected/total) : 0.0,
                          backgroundColor: Colors.grey[300],
                          color: (collected == total) ? Colors.green : Colors.blueAccent,
                        ),
                      ),
                      Text("${(total != 0) ? (collected/total)*100 : 0}%")
                    ],
                  ),
                )
              ]
            )
          );
        }
      )
    );
  }
}