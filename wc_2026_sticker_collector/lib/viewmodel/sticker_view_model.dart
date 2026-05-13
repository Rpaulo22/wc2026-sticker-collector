import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wc_2026_sticker_collector/app_exception.dart';

class StickerViewModel {

  Future<void> incrementCard(String userID, String categoryCode, String stickerCode) async {
    try {
      FirebaseFirestore.instance.collection('Users').doc(userID).update({
        'stickersCollected.$categoryCode.$stickerCode': FieldValue.increment(1),
      });
    } catch (e) {
      throw AppException("Erro a registar carta. Tenta novamente mais tarde.");
    }
  }

  Future<void> decrementCard(String userID, String categoryCode, String stickerCode) async {
    try {
      FirebaseFirestore.instance.collection('Users').doc(userID).update({
        'stickersCollected.$categoryCode.$stickerCode': FieldValue.increment(-1),
      });
    } catch (e) {
      throw AppException("Erro a retirar carta. Tenta novamente mais tarde.\nErro - ${e.toString()}");
    }
  }
  
}