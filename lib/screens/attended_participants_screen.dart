import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../utils/date_formatter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/participant_search_bar.dart';
import '../models/filter_model.dart';
import '../screens/filter_screen.dart';

enum AttendeeSortOption {
  checkInTime,
  name,
  teamId,
  affiliationType,
  experienceLevel,
  age
}

class AttendanceListScreen extends StatefulWidget {
  final String eventName;
  final String eventId;

  const AttendanceListScreen({
    super.key,
    required this.eventName,
    required this.eventId,
  });

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  final EventService _eventService = EventService();

  final TextEditingController _searchController = TextEditingController();
  AttendeeSortOption _sortOption = AttendeeSortOption.checkInTime;

  FilterModel _activeFilters = FilterModel();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSortContextRow(Map<String, dynamic> data) {
    String? contextText;
    switch (_sortOption) {
      case AttendeeSortOption.affiliationType:
        contextText = 'Type: ${data['affiliationType'] ?? 'N/A'}';
        break;
      case AttendeeSortOption.experienceLevel:
        contextText = 'Experience: ${data['experienceLevel'] ?? 'N/A'}';
        break;
      case AttendeeSortOption.age:
        contextText = 'Age: ${data['age']?.toString() ?? 'N/A'}';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Text(
      contextText,
      style: const TextStyle(
          fontSize: 12, color: Colors.deepPurple, fontStyle: FontStyle.italic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _activeFilters.isFilterActive ? Colors.blue : null,
            ),
            tooltip: 'Advanced Filters',
            onPressed: () async {
              final newFilters = await Navigator.push<FilterModel>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FilterScreen(initialFilters: _activeFilters),
                ),
              );

              if (newFilters != null) {
                setState(() {
                  _activeFilters = newFilters;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export as CSV',
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating CSV...')),
                );

                // service call to get the data
                final csvData =
                    await _eventService.exportEventToCsv(widget.eventId);

                // temporary directory to save the file
                final directory = await getTemporaryDirectory();
                final path =
                    '${directory.path}/${widget.eventName}_attendance.csv';
                final file = File(path);

                // write the CSV data to the file
                await file.writeAsString(csvData);

                // share_plus to open the native share dialog
                final shareParams = ShareParams(
                  text: 'Here is the attendance list for ${widget.eventName}.',
                  files: [XFile(path)],
                );

                await SharePlus.instance.share(shareParams);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('CSV Export not implemented yet.')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ParticipantSearchBar(controller: _searchController),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8.0,
              children: [
                ChoiceChip(
                  label: const Text('Sort by Time'),
                  selected: _sortOption == AttendeeSortOption.checkInTime,
                  onSelected: (selected) => setState(
                      () => _sortOption = AttendeeSortOption.checkInTime),
                ),
                ChoiceChip(
                  label: const Text('Sort by Name'),
                  selected: _sortOption == AttendeeSortOption.name,
                  onSelected: (selected) =>
                      setState(() => _sortOption = AttendeeSortOption.name),
                ),
                ChoiceChip(
                  label: const Text('Sort by Team'),
                  selected: _sortOption == AttendeeSortOption.teamId,
                  onSelected: (selected) =>
                      setState(() => _sortOption = AttendeeSortOption.teamId),
                ),
                ChoiceChip(
                  label: const Text('Affiliation Type'),
                  selected: _sortOption == AttendeeSortOption.affiliationType,
                  onSelected: (selected) => setState(
                      () => _sortOption = AttendeeSortOption.affiliationType),
                ),
                ChoiceChip(
                  label: const Text('Experience'),
                  selected: _sortOption == AttendeeSortOption.experienceLevel,
                  onSelected: (selected) => setState(
                      () => _sortOption = AttendeeSortOption.experienceLevel),
                ),
                ChoiceChip(
                  label: const Text('Age'),
                  selected: _sortOption == AttendeeSortOption.age,
                  onSelected: (selected) =>
                      setState(() => _sortOption = AttendeeSortOption.age),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _eventService.getParticipantsStream(widget.eventId),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(child: Text('No attendees found.'));

                var participants = snapshot.data!.docs;

                // filters
                if (_activeFilters.isFilterActive) {
                  participants = participants.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (_activeFilters.genders.isNotEmpty &&
                        !_activeFilters.genders.contains(data['gender'])) {
                      return false;
                    }
                    if (_activeFilters.affiliationTypes.isNotEmpty &&
                        !_activeFilters.affiliationTypes
                            .contains(data['affiliationType'])) {
                      return false;
                    }
                    if (_activeFilters.experienceLevels.isNotEmpty &&
                        !_activeFilters.experienceLevels
                            .contains(data['experienceLevel'])) {
                      return false;
                    }
                    return true;
                  }).toList();
                }

                final query = _searchController.text.toLowerCase();

                // Search Filter
                if (query.isNotEmpty) {
                  participants = participants.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nameLower =
                        (data['participant_name'] as String? ?? '')
                            .toLowerCase();
                    final emailLower =
                        (data['participant_email'] as String? ?? '')
                            .toLowerCase();
                    return nameLower.contains(query) ||
                        emailLower.contains(query);
                  }).toList();
                }

                // Sorting
                participants.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  switch (_sortOption) {
                    case AttendeeSortOption.checkInTime:
                      final timeA = dataA['check_in_time'] as Timestamp? ??
                          Timestamp(0, 0);
                      final timeB = dataB['check_in_time'] as Timestamp? ??
                          Timestamp(0, 0);
                      return timeB.compareTo(timeA);
                    case AttendeeSortOption.name:
                      return (dataA['participant_name'] as String? ?? '')
                          .compareTo(
                              dataB['participant_name'] as String? ?? '');
                    case AttendeeSortOption.teamId:
                      return (dataA['team_id'] as String? ?? '')
                          .compareTo(dataB['team_id'] as String? ?? '');
                    case AttendeeSortOption.affiliationType:
                      return (dataA['affiliationType'] as String? ?? '')
                          .compareTo(dataB['affiliationType'] as String? ?? '');
                    case AttendeeSortOption.experienceLevel:
                      return (dataA['experienceLevel'] as String? ?? '')
                          .compareTo(dataB['experienceLevel'] as String? ?? '');
                    case AttendeeSortOption.age:
                      return (dataA['age'] as int? ?? 999)
                          .compareTo(dataB['age'] as int? ?? 999);
                  }
                });

                return ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participantData =
                        participants[index].data() as Map<String, dynamic>;

                    return ListTile(
                      isThreeLine: true,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                          participantData['participant_name'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(participantData['participant_email'] ??
                              'No email'),
                          Text(
                            'Team: ${participantData['team_id'] ?? 'N/A'}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.blueGrey),
                          ),
                          _buildSortContextRow(participantData),
                        ],
                      ),
                      trailing: Text(
                        formatCheckInTime(
                            (participantData['check_in_time'] as Timestamp?)
                                ?.toDate()
                                .toIso8601String()),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
