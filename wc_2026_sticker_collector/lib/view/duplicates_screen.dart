import 'package:flutter/material.dart';
import 'package:wc_2026_sticker_collector/model/sticker_catalog_service.dart';
import 'package:wc_2026_sticker_collector/model/sticker_data.dart';
import 'package:wc_2026_sticker_collector/model/user_profile.dart';


class DuplicatesScreen extends StatefulWidget {
  const DuplicatesScreen({super.key, required this.title, required this.profile});

  final String title;
  final UserProfile profile;

  @override
  State<DuplicatesScreen> createState() => _DuplicatesScreenState();
}

class _DuplicatesScreenState extends State<DuplicatesScreen> {

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.widthOf(context);
    final padding = (width / 12).clamp(16.0, 100.0);
    final isMobile = width < 800;

    UserProfile profile = widget.profile;
    List<String> duplicateStickers = profile.getUserDuplicates();

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
      body: Padding(
        padding: EdgeInsetsGeometry.directional(top:10, start: padding, end: padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 10,
              child: Container(
                width: double.infinity, // Forces the box to take full width
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A398D).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.only(topLeft: .circular(16), topRight: .circular(16)), // Rounded corners only on top                  
                  border: Border.all(color: const Color(0xFF2A398D)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), // Very soft modern shadow
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text:"Cromos duplicados de ", 
                        style: TextStyle(
                          fontSize: 32
                        ),
                      ),
                      TextSpan(
                        text: profile.username, 
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ]
                  )
                )
              ),
            ),
            Expanded(
              flex: 85,
              child: Container(
                width: double.infinity, // Forces the box to take full width
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA), // Soft, light gray-blue background
                  border: Border.all(color: Colors.grey.shade300), 
                  borderRadius: BorderRadius.only(bottomLeft: .circular(16), bottomRight: .circular(16)), // Rounded corners only on bottom
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), // Very soft modern shadow
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int gridAxisCount = 2;
                    // If the screen is wider than 800 pixels (PC / Tablet)
                    if (constraints.maxWidth > 800) { 
                      gridAxisCount = 5;
                    }
                    if (duplicateStickers.isNotEmpty) {
                      return Column(
                        children: [
                          Expanded(
                            flex: 95,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridAxisCount, // 5 stickers per row in pc, 2 in mobile
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.8, 
                              ),
                              itemCount: duplicateStickers.length,
                              itemBuilder: (context, index) {
                                final stickerCode = duplicateStickers[index];
                                final stickerInfo = stickerService.flatCatalog.firstWhere(

                                  (sticker) => sticker['code'] == stickerCode, 
                                  
                                  // if for some reason the sticker does not exist
                                  orElse: () => {'code': 'ERRO', 'title': 'Desconhecido'}, 
                                );

                                int amountDuplicate = profile.amountOwned(stickerCode)-1; // how many of this sticker a user has
                                
                                String categoryCode = stickerService.getCategoryCode(stickerCode);

                                Color countryColor = StickerData.getColor(categoryCode);

                                return Container(
                                  decoration: BoxDecoration(
                                    color: countryColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: countryColor.withValues(),
                                      width: 1.5,
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
                                                    // 30% opacity
                                                    opacity: 0.3, 
                                                    child: StickerData.getFlagAvatar(categoryCode) // Colored
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
                                                          color:Colors.black,
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
                                                stickerInfo['title'],
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ]
                                        )
                                      ),
                                      Container(
                                        height: 36, // Keep it compact!
                                        decoration: BoxDecoration(
                                          color: countryColor.withValues(alpha: 0.4),
                                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$amountDuplicate',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            )
                                          ]
                                        )
                                      )
                                    ]
                                  )
                                );
                              }
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text: "Total de ", style: TextStyle(fontSize: 20)),
                                  TextSpan(text: "${duplicateStickers.length}", style: TextStyle(fontSize: 20)),
                                  TextSpan(text: " duplicado(s)", style: TextStyle(fontSize: 20))
                                ]
                              )
                            )
                          )
                        ]
                      );
                    }
                    else {
                      return Center(child: Text("Atualmente não tem duplicados", style: TextStyle(fontSize: 32)));
                    }
                  }
                )
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
          ],
        )
      )
    );
  }
}