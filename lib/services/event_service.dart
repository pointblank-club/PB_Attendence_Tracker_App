import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:qrscanner/utils/config_manager.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String baseUrl = ConfigManager.baseUrl;


  /// Provides a stream of all events.
  Stream<QuerySnapshot> getEventsStream() {
    return _firestore.collection('events').snapshots();
  }

  /// Fetches the number of participants for a given event.
  Future<int> getParticipantCount(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<String> exportEventToCsv(String eventId) async {
    try {
      final url = Uri.parse('$baseUrl/export-csv?event=$eventId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return response.body; 
      } else {
        throw Exception('Failed to download CSV: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting CSV: $e');
    }
  }

  // stream of participants for a given event.
  Stream<QuerySnapshot> getParticipantsStream(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('attendees')
        .snapshots();
  }
}