import 'dart:convert';
import 'package:flutter/services.dart';

/// Helper to load mock / static JSON data for testing the Butcher TV Display offline.
class ButcherSampleDataLoader {
  static Future<Map<String, dynamic>> loadSampleJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/butcher_sample.json');
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}
