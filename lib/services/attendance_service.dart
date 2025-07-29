import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:qrscanner/utils/config_manager.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
 
  final String baseUrl = ConfigManager.baseUrl;

 
  Future<bool> isParticipantCheckedIn(String eventName, String participantId) async {
    final attendeeDocRef = _firestore
        .collection('events')
        .doc(eventName)
        .collection('attendees') 
        .doc(participantId);

    final snapshot = await attendeeDocRef.get();
    return snapshot.exists;
  }

  // marks attendance and triggers the confirmation email.
  Future<String> updateAttendance(Map<String, dynamic> attendeeData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mark-attendance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(attendeeData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['message'] ?? 'Attendance marked successfully.';
      } else {
        throw Exception(responseData['message'] ?? 'Failed to mark attendance.');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server.');
    }
  }
}