import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wc_2026_sticker_collector/app_exception.dart';

class UserProfile {
  String userID;
  String username;
  Map<String,Map<String,int>> stickersCollected;
  List<String> addedFriends;

  UserProfile({required this.userID, required this.username, required this.stickersCollected, required this.addedFriends});

  // This factory handles the messy Firestore parsing once, so your UI doesn't have to.
  factory UserProfile.fromFirestore(String userID, Map<String, dynamic> data) {
    final username = data['userName'] as String;
    final rawStickers = data['stickersCollected'] as Map<String, dynamic>? ?? {};
    final addedFriends = List<String>.from(data['addedFriends'] ?? []);
    
    final parsedStickers = rawStickers.map((key, value) => MapEntry(
      key, 
      Map<String, int>.from(value as Map),
    ));

    return UserProfile(userID: userID, username: username, stickersCollected: parsedStickers, addedFriends: addedFriends);
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

  List<String> getUserDuplicates() {
    List<String> duplicates = [];

    for (var collection in stickersCollected.entries) { // each subcollection in the collection
      for (var cards in collection.value.entries) { // each card in the subcollection
        for (int i = 1; i < cards.value; i++) { // for each card amount > 1
          duplicates.add(cards.key); // add card to duplicate list
        }
      }
    }

    return duplicates;
  }

  Future<void> addFriend(String friendUsername) async {
    var db = FirebaseFirestore.instance;

    if (addedFriends.length >= 5) { // hard limit of 5 friends for now
      throw AppException("Quantidade de amigos excedida.");
    }

    try {
      final querySnapshot = await db
        .collection('Users')
        .where('userName', isEqualTo: friendUsername)
        .get();

      // check if the user exists
      if (querySnapshot.docs.isEmpty) {
        throw AppException("Utilizador não encontrado.");
      }

      var friendDoc = querySnapshot.docs.first;
      String friendUID = friendDoc.id;

      if (addedFriends.contains(friendUID)) {
        throw AppException("Amigo já adicionado");
      }
      
      await db.collection('Users').doc(userID).update({
        'addedFriends': FieldValue.arrayUnion([friendUID])
      });

    } catch (e) {
      throw AppException("Erro a adicionar amigo. Tenta novamente.");
    }
  }

  Future<void> removeFriend(String friendUID) async {
    var db = FirebaseFirestore.instance;

    if (addedFriends.isEmpty) { // YOU HAVE NO FRIENDS :((
      throw AppException("Não tens quaisquer amigos :(");
    }

    if (!addedFriends.contains(friendUID)) {
      throw AppException("Utilizador não é teu amigo"); // should not happen but user does not have this user as a friend
    }

    try {
      await db.collection('Users').doc(userID).update({
        'addedFriends': FieldValue.arrayRemove([friendUID])
      });

    } catch (e) {
      throw AppException("Erro a remover amigo. Tenta novamente.");
    }
  }

  // gathers the info of the users friends
  Future<List<UserProfile>> getFriendsInfo() async {

    var db = FirebaseFirestore.instance;
    try {
      
      // gets from firebase the friends documents
      final querySnapshot = await db
        .collection("Users")
        .where(FieldPath.documentId, whereIn: addedFriends)
        .get(); 

      // returns a list of UserProfile containing the friends' info
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final uid = doc.id;
        return UserProfile.fromFirestore(uid, data);
      }).toList();
    }
    catch (e) {
      throw AppException("Erro a sacar informação dos teus amigos. Que pena...");
    }
  }

  int friendCount() {
    return addedFriends.length;
  }
}