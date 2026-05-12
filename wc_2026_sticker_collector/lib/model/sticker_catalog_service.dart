import 'package:cloud_firestore/cloud_firestore.dart';

class StickerCatalogService {

  List<Map<String, dynamic>> _flatCatalog = [];
  Map<String, List<Map<String, dynamic>>> _groupedCatalog = {};

  List<Map<String, dynamic>> get flatCatalog => _flatCatalog;
  Map<String, List<Map<String, dynamic>>> get groupedCatalog => _groupedCatalog;

  // variables to prevent the ui to download the stickers twice because of auth changes
  bool _isLoaded = false;
  Future<void>? _activeDownload;

  Future<void> loadCatalog() async {
    // if stickers have already been loaded, return
    if (_isLoaded) return;

    // if download is happening, no need to download again: just waits for that to happen
    if (_activeDownload != null) {
      await _activeDownload;
      return;
    }

    // locks and starts downloading
    _activeDownload = _fetchFromFirebase();
    await _activeDownload;
  }

  Future<void> _fetchFromFirebase() async {
    flatCatalog.clear();
    groupedCatalog.clear();

    final snapshot = await FirebaseFirestore.instance.collection('stickers').get();
    
    _flatCatalog = snapshot.docs.map((doc) => doc.data()).toList();

    for (var sticker in _flatCatalog) {
      final String code = sticker['code'] ?? ''; 
      
      if (code.isNotEmpty) {
        String categoryCode = getCategoryCode(code);

        if (!_groupedCatalog.containsKey(categoryCode)) {
          _groupedCatalog[categoryCode] = [];
        }

        _groupedCatalog[categoryCode]!.add(sticker);
      }
    }

    _groupedCatalog.forEach((key, list) {
      list.sort((a, b) {
        String codeA = a['code'] as String;
        String codeB = b['code'] as String;

        final numberRegex = RegExp(r'\d+');
        final matchA = numberRegex.firstMatch(codeA);
        final matchB = numberRegex.firstMatch(codeB);

        if (matchA != null && matchB != null) {
          int numA = int.parse(matchA.group(0)!); 
          int numB = int.parse(matchB.group(0)!); 
          
          return numA.compareTo(numB); 
        }

        return codeA.compareTo(codeB);
      });
    });

    // download is finished and is marked as so
    _isLoaded = true;
    _activeDownload = null;
  }

  String getCategoryCode(String stickerCode) {
    // This looks for 1 or more letters (A-Z) at the very start (^) of the string.
    final prefixRegex = RegExp(r'^([A-Za-z]+)');
    if (stickerCode.isNotEmpty) {
      // Apply the Regex to the code
      final match = prefixRegex.firstMatch(stickerCode);

      if (match != null) {
        // If it found letters at the start, use them
        return match.group(1)!.toUpperCase();
      } else {
        return stickerCode; 
      }
    }
    return "";
  }

}

// Create a global instance
final stickerService = StickerCatalogService();