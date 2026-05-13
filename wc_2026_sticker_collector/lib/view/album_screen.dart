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

          final profile = UserProfile.fromFirestore(currentUser.uid, userData);

          // grab the stickers for the specific country 
          final countryStickers = stickerService.groupedCatalog[widget.countryCode] ?? [];

          // total amount of stickers for this country/sticker group
          int total = countryStickers.length;
          // amount collected by user
          int collected = profile.stickersCollected[widget.countryCode]?.values.where((amount) => amount > 0).length ?? 0;


          return LayoutBuilder(
            builder: (context, constraints) {
              int gridAxisCount = 2;
              // If the screen is wider than 800 pixels (PC / Tablet)
              if (constraints.maxWidth > 800) { 
                gridAxisCount = 5;
              }
              return Padding(
                padding: EdgeInsetsGeometry.directional(start: padding, end: padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 15,
                      child: Row(
                        children: [
                          // Leading Flag
                          SizedBox(
                            width: 100,
                            child: StickerData.getFlagAvatar(widget.countryCode),
                          ),
                          
                          // Center Title
                          Expanded(
                            child: Text(
                              StickerData.paniniToName[widget.countryCode]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          // Trailing Flag
                          SizedBox(
                            width: 100,
                            child: StickerData.getFlagAvatar(widget.countryCode),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 75,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridAxisCount, // 4 stickers per row in pc, 2 in mobile
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8, 
                        ),
                        itemCount: countryStickers.length,
                        itemBuilder: (context, index) {
                          final sticker = countryStickers[index];
                          final String stickerCode = sticker['code']; // sticker code (e.g BRA1, HAI17)

                          int amountOwned = profile.amountOwned(stickerCode); // how many of this sticker a user has

                          Color countryColor = StickerData.getColor(widget.countryCode);

                          return Container(
                            decoration: BoxDecoration(
                              color:  (amountOwned > 0) ? countryColor.withValues(alpha: 0.2) : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (amountOwned > 0) ? countryColor.withValues() : Colors.grey[400]!, 
                                width: (amountOwned > 0) ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Expanded forces the text to take up all the empty space at the top
                                Expanded(
                                  child: Stack(
                                    children: [
                                      // background flag
                                      Center(
                                        child: FractionallySizedBox(
                                          // 0.5 means it will take up exactly 50% of the available width/height
                                          widthFactor: 0.5, 
                                          heightFactor: 0.5,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Opacity(
                                              // 30% opacity when owned, drops to 10% when missing
                                              opacity: (amountOwned > 0) ? 0.3 : 0.1, 
                                              child: (amountOwned > 0)
                                                  ? StickerData.getFlagAvatar(widget.countryCode) // Colored
                                                  : ColorFiltered( // Black & White
                                                      colorFilter: const ColorFilter.matrix(<double>[
                                                        0.2126, 0.7152, 0.0722, 0, 0,
                                                        0.2126, 0.7152, 0.0722, 0, 0,
                                                        0.2126, 0.7152, 0.0722, 0, 0,
                                                        0,      0,      0,      1, 0,
                                                      ]),
                                                      child: StickerData.getFlagAvatar(widget.countryCode),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsGeometry.symmetric(horizontal: 12.0),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 20,
                                              child: Center(
                                                child: Text(
                                                  stickerCode,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22,
                                                    color: (amountOwned > 0) ? Colors.black : Colors.grey[600],
                                                  ),
                                                ),
                                              )
                                            ),
                                            Spacer(flex:80),
                                          ]
                                        )
                                      ),
                                      Center(
                                        child: Text(
                                          sticker['title'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: (amountOwned > 0) ? Colors.black : Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ]
                                  )
                                ),

                                // A small container to house the controls
                                Container(
                                  height: 36, // Keep it compact!
                                  decoration: BoxDecoration(
                                    color: (amountOwned > 0) ? countryColor.withValues(alpha: 0.4) : Colors.grey[300],
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      
                                      // Decrement Button (-)
                                      IconButton(
                                        onPressed: () async {
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
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Não é possível ter cromos negativos otário")));
                                          }
                                        },
                                        // Lower the opacity if they have 0 to show it's disabled
                                        icon: Icon(
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
                                      IconButton(
                                        onPressed: () async {
                                          try {
                                            await stickerViewModel.incrementCard(currentUser.uid, widget.countryCode, stickerCode);
                                            if (!context.mounted) return;
                                          }
                                          catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                          }
                                        },
                                        icon: const Icon(
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
                      flex: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Cromos: $collected/$total"),
                          SizedBox(
                            width: 100, // prevents progress indicator from crashing
                            child: LinearProgressIndicator(
                              value: (total != 0) ? (collected/total) : 0.0,
                              backgroundColor: Colors.grey[300],
                              color: (collected == total) ? Colors.green : Colors.blueAccent,
                            ),
                          ),
                          Text("${(total != 0) ? ((collected/total)*100).toStringAsFixed(0) : 0}%")
                        ],
                      ),
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
              );
            }
          );
        }
      )
    );
  }
}