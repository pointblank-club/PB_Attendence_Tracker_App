import 'package:flutter/material.dart';
import '../screens/participant_selection_screen.dart';

class ParticipantSortControls extends StatelessWidget {
  final ParticipantSortOption currentSortOption;
  final ValueChanged<ParticipantSortOption> onSortOptionChanged;

  const ParticipantSortControls({
    super.key,
    required this.currentSortOption,
    required this.onSortOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8.0,
          children: [
            ChoiceChip(
              label: const Text('Name'),
              selected: currentSortOption == ParticipantSortOption.name,
              onSelected: (selected) => onSortOptionChanged(ParticipantSortOption.name),
            ),
            ChoiceChip(
              label: const Text('Team'),
              selected: currentSortOption == ParticipantSortOption.teamId,
              onSelected: (selected) => onSortOptionChanged(ParticipantSortOption.teamId),
            ),
            ChoiceChip(
              label: const Text('Affiliation'),
              selected: currentSortOption == ParticipantSortOption.affiliation,
              onSelected: (selected) => onSortOptionChanged(ParticipantSortOption.affiliation),
            ),
            // --- ADDED NEW CHIPS ---
            ChoiceChip(
              label: const Text('Affiliation Type'),
              selected: currentSortOption == ParticipantSortOption.affiliationType,
              onSelected: (selected) => onSortOptionChanged(ParticipantSortOption.affiliationType),
            ),
            ChoiceChip(
              label: const Text('Experience'),
              selected: currentSortOption == ParticipantSortOption.experienceLevel,
              onSelected: (selected) => onSortOptionChanged(ParticipantSortOption.experienceLevel),
            ),
            ChoiceChip(
              label: const Text('Prev. Part.'),
              selected: currentSortOption == ParticipantSortOption.previousParticipation,
              onSelected: (selected) => onSortOptionChanged(ParticipantSortOption.previousParticipation),
            ),
            ChoiceChip(
              label: const Text('Age'),
              selected: currentSortOption == ParticipantSortOption.age,
              onSelected: (selected) => onSortOptionChanged(ParticipantSortOption.age),
            ),
          ],
        ),
      ),
    );
  }
}