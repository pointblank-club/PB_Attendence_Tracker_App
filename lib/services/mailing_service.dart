import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/participant_model.dart';
import 'package:qrscanner/utils/config_manager.dart';

class MailingService {
  final String baseUrl = ConfigManager.baseUrl;

  Future<List<ParticipantModel>> fetchParticipants(String eventName) async {
    try {
      final url = Uri.parse('$baseUrl/participants?event=${Uri.encodeComponent(eventName)}');

      print('DEBUG: Fetching participants from URL: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => ParticipantModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load participants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching participants: $e');
    }
  }

  Future<Map<String, dynamic>> sendEmails({
    required String subject,
    required String body,
    required bool includeQR,
    required List<Map<String, dynamic>> participants,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-emails'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'subject': subject,
          'body': body,
          'include_qr': includeQR,
          'participants': participants,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to connect to the server.');
    }
  }
}