class UserProfile {
  String username;
  Map<String,Map<String,int>> stickersCollected;

  UserProfile({required this.username, required this.stickersCollected});

  // This factory handles the messy Firestore parsing once, so your UI doesn't have to.
  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    final username = data['userName'] as String;
    final rawStickers = data['stickersCollected'] as Map<String, dynamic>? ?? {};
    
    final parsedStickers = rawStickers.map((key, value) => MapEntry(
      key, 
      Map<String, int>.from(value as Map),
    ));

    return UserProfile(username: username, stickersCollected: parsedStickers);
  }

  int amountOwned(String stickerCode) {
    String categoryCode = getCategoryCode(stickerCode);

    if (!stickersCollected.containsKey(categoryCode)) return 0;

    Map<String,int> countryStickers = stickersCollected[categoryCode]!;

    return countryStickers[stickerCode] ?? 0;

  }

  String getCategoryCode(String stickerCode) {
    final prefixRegex = RegExp(r'^([A-Za-z]+)');

    if (stickerCode.isNotEmpty) {
      String categoryCode;

      // Apply the Regex to the code
      final match = prefixRegex.firstMatch(stickerCode);

      if (match != null) {
        // If it found letters at the start, use them
        categoryCode = match.group(1)!.toUpperCase();
      } else {
        categoryCode = stickerCode; 
      }
      return categoryCode;
    }
    else {
      return "";
    }
  }
}