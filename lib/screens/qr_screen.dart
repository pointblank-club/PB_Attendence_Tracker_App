import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../services/attendance_service.dart';
import '../utils/constants.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  bool _isProcessing = false;

  void _validateRequiredFields(Map<String, dynamic> data) {
    for (var field in kRequiredFields) {
      if (!data.containsKey(field) ||
          data[field] == null ||
          data[field].toString().trim().isEmpty) {
        throw Exception('Missing or empty required field: $field');
      }
    }
  }

  Future<void> _processScannedCode(String? rawValue) async {
    if (rawValue == null || rawValue.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final decodedBytes = base64.decode(rawValue);
      final decodedString = utf8.decode(decodedBytes);
      final decodedData = jsonDecode(decodedString) as Map<String, dynamic>;

      _validateRequiredFields(decodedData);

      final String eventName = decodedData['event_name'];
      final String participantId = decodedData['participant_id'];
      final String participantName = decodedData['participant_name'];

      // check for duplicates
      final bool alreadyCheckedIn = await _attendanceService
          .isParticipantCheckedIn(eventName, participantId);

      if (alreadyCheckedIn) {
        // show already marked dialog
        if (!mounted) return;
        await showDialog(
            context: context,
            builder: (c) => AlertDialog(
                  title: const Text('Already Marked'),
                  content: Text(
                      'Participant $participantName is already marked present.'),
                  actions: [
                    TextButton(
                        child: const Text('OK'),
                        onPressed: () => Navigator.of(c).pop()),
                  ],
                ));
      } else {
        // show confirmation dialog
        if (!mounted) return;
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 10),
                Text('Confirm Attendance'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(decodedData['participant_name'] ?? 'N/A'),
                    subtitle: const Text('Name'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(decodedData['participant_email'] ?? 'N/A'),
                    subtitle: const Text('Email'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(decodedData['phone']?.toString() ?? 'N/A'),
                    subtitle: const Text('Phone'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.cake),
                    title: Text(decodedData['age']?.toString() ?? 'N/A'),
                    subtitle: const Text('Age'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: Text(decodedData['team_id'] ?? 'N/A'),
                    subtitle: const Text('Team ID'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(decodedData['affiliationName'] ?? 'N/A'),
                    subtitle:
                        Text(decodedData['affiliationType'] ?? 'Affiliation'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: Text(decodedData['experienceLevel'] ?? 'N/A'),
                    subtitle: const Text('Experience Level'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(c).pop(false)),
              FilledButton(
                  child: const Text('Confirm'),
                  onPressed: () => Navigator.of(c).pop(true)),
            ],
          ),
        );

        if (confirmed == true) {
          final String successMessage =
              await _attendanceService.updateAttendance(decodedData);
          if (!mounted) return;
          _showResultDialog(true, successMessage);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showResultDialog(false, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showResultDialog(bool isSuccess, String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isSuccess ? 'Success' : 'Error'),
        content: Text(message),
        actions: [
          TextButton(
              child: const Text('OK'), onPressed: () => Navigator.of(c).pop()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              onDetect: (capture) {
                if (capture.barcodes.isNotEmpty && !_isProcessing) {
                  _processScannedCode(capture.barcodes.first.rawValue);
                }
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Position QR code in the camera view',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
