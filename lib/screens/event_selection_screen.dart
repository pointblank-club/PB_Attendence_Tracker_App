
import 'package:flutter/material.dart';
import '../screens/participant_selection_screen.dart'; 



class AppEvent {
  final String id;
  final String displayName; 

  const AppEvent({required this.id, required this.displayName});
}

class EventSelectionScreen extends StatefulWidget {
  final String subject;
  final String body;
  final bool includeQR;

  const EventSelectionScreen({
    super.key,
    required this.subject,
    required this.body,
    required this.includeQR,
  });

  @override
  State<EventSelectionScreen> createState() => _EventSelectionScreenState();
}

class _EventSelectionScreenState extends State<EventSelectionScreen> {
  final List<AppEvent> _availableEvents = [
    const AppEvent(id: 'ctf_event_2025', displayName: 'CTF Championship 2025'),
   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select an Event'),
      ),
      body: ListView.builder(
        itemCount: _availableEvents.length,
        itemBuilder: (context, index) {
          final event = _availableEvents[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(event.displayName), 
              leading: const Icon(Icons.event_note),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParticipantSelectionScreen(
                      subject: widget.subject,
                      body: widget.body,
                      includeQR: widget.includeQR,
                      eventName: event.id, 
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}