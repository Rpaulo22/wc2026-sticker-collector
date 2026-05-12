import 'package:cloud_firestore/cloud_firestore.dart';

class StickerCatalogService {

  List<Map<String, dynamic>> _flatCatalog = [];
  Map<String, List<Map<String, dynamic>>> _groupedCatalog = {};

  List<Map<String, dynamic>> get flatCatalog => _flatCatalog;
  Map<String, List<Map<String, dynamic>>> get groupedCatalog => _groupedCatalog;

  Future<void> loadCatalog() async {
    flatCatalog.clear();
    groupedCatalog.clear();

    final snapshot = await FirebaseFirestore.instance.collection('stickers').get();
    
    _flatCatalog = snapshot.docs.map((doc) => doc.data()).toList();

    // This looks for 1 or more letters (A-Z) at the very start (^) of the string.
    final prefixRegex = RegExp(r'^([A-Za-z]+)');

    for (var sticker in _flatCatalog) {
      final String code = sticker['code'] ?? ''; // e.g., "BRA01" or "00"
      
      if (code.isNotEmpty) {
        String categoryCode;

        // Apply the Regex to the code
        final match = prefixRegex.firstMatch(code);

        if (match != null) {
          // If it found letters at the start, use them
          categoryCode = match.group(1)!.toUpperCase();
        } else {
          categoryCode = code; 
        }

        // Initialize the list if this category doesn't exist yet
        if (!_groupedCatalog.containsKey(categoryCode)) {
          _groupedCatalog[categoryCode] = [];
        }

        // Add the sticker to its category
        _groupedCatalog[categoryCode]!.add(sticker);
      }
    }

    // 3. Sort each category's list numerically
    _groupedCatalog.forEach((key, list) {
      list.sort((a, b) {
        String codeA = a['code'] as String;
        String codeB = b['code'] as String;

        // Extract just the numbers from the code
        final numberRegex = RegExp(r'\d+');
        final matchA = numberRegex.firstMatch(codeA);
        final matchB = numberRegex.firstMatch(codeB);

        // If both codes have numbers, compare them mathematically
        if (matchA != null && matchB != null) {
          int numA = int.parse(matchA.group(0)!); // e.g., converts "2" to int 2
          int numB = int.parse(matchB.group(0)!); // e.g., converts "10" to int 10
          
          return numA.compareTo(numB); // 2 correctly comes before 10
        }

        // Fallback: If no numbers are found (e.g., just "INTRO"), sort alphabetically
        return codeA.compareTo(codeB);
      });
    });
  }
}

// Create a global instance
final stickerService = StickerCatalogService();