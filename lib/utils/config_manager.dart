import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigManager {
  static String baseUrl = 'http://fallback.url'; // Fallback URL
  static const _key = 'api_base_url';

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final localUrl = prefs.getString(_key);
    if (localUrl != null && localUrl.isNotEmpty) {
      baseUrl = localUrl;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('config')
          .get();
          
      if (doc.exists && doc.data() != null) {
        final remoteUrl = doc.data()!['api_endpoint'] as String?;
        if (remoteUrl != null && remoteUrl.isNotEmpty) {
          baseUrl = remoteUrl;
          await prefs.setString(_key, remoteUrl);
        }
      }
    } catch (e) {
      print('Error fetching remote config, using local version: $e');
    }
  }
}