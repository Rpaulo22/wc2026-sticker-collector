import 'dart:developer';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class Utils {

  static Future<void> uploadStickersFromCsv() async {
    try {
      
      final byteData = await rootBundle.load('assets/stickers.csv');

      // 2. Decode the bytes using Latin-1 (which handles European special characters)
      final rawData = latin1.decode(byteData.buffer.asUint8List());

      // 2. Parse manually (No package needed!)
      // Split the giant text block into individual lines
      List<String> lines = rawData.split('\n');

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Loop through the lines (starting at 1 to skip the header)
      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        
        if (line.isNotEmpty) {
          // Split the line into columns using your semicolon
          List<String> row = line.split(';');
          
          // Make sure we actually have 4 columns to avoid errors
          if (row.length >= 4) {
            final String code = row[0];
            final String title = row[1];
            final String section = row[2];
            final bool isFoil = row[3].toUpperCase() == 'TRUE';

            final docRef = firestore.collection('stickers').doc(code);

            batch.set(docRef, {
              'code': code,
              'title': title,
              'section': section,
              'isFoil': isFoil,
            });
          }
        }
      }

      await batch.commit();

    } catch (e) {
      log('❌ Error uploading stickers: $e');
    }
  }
}