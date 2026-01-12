import 'package:flutter/material.dart';
import '../models/filter_model.dart';

class FilterScreen extends StatefulWidget {
  final FilterModel initialFilters;

  const FilterScreen({super.key, required this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterModel _currentFilters;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _affiliationTypeOptions = [
    'Student',
    'Professional',
    'Hobbyist'
  ];
  final List<String> _experienceOptions = [
    'Beginner',
    'Intermediate',
    'Advanced'
  ];

  @override
  void initState() {
    super.initState();
    _currentFilters = FilterModel(
      // changeable copy
      genders: Set.from(widget.initialFilters.genders),
      affiliationTypes: Set.from(widget.initialFilters.affiliationTypes),
      experienceLevels: Set.from(widget.initialFilters.experienceLevels),
      ageRange: widget.initialFilters.ageRange,
      previousParticipation: widget.initialFilters.previousParticipation,
      isDuo: widget.initialFilters.isDuo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Participants'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                // Reset all filters
                _currentFilters = FilterModel();
              });
            },
            child: const Text('Reset'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMultiSelectChipGroup(
            'Gender',
            _genderOptions,
            _currentFilters.genders,
            (selected, value) {
              setState(() {
                selected
                    ? _currentFilters.genders.add(value)
                    : _currentFilters.genders.remove(value);
              });
            },
          ),
          const Divider(),
          _buildMultiSelectChipGroup(
            'Affiliation Type',
            _affiliationTypeOptions,
            _currentFilters.affiliationTypes,
            (selected, value) {
              setState(() {
                selected
                    ? _currentFilters.affiliationTypes.add(value)
                    : _currentFilters.affiliationTypes.remove(value);
              });
            },
          ),
          const Divider(),
          _buildMultiSelectChipGroup(
            'Experience Level',
            _experienceOptions,
            _currentFilters.experienceLevels,
            (selected, value) {
              setState(() {
                selected
                    ? _currentFilters.experienceLevels.add(value)
                    : _currentFilters.experienceLevels.remove(value);
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FilledButton(
          child: const Text('Apply Filters'),
          onPressed: () {
            Navigator.of(context).pop(_currentFilters);
          },
        ),
      ),
    );
  }

  Widget _buildMultiSelectChipGroup(
    String title,
    List<String> options,
    Set<String> selectedValues,
    Function(bool, String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: selectedValues.contains(option),
              onSelected: (selected) => onSelected(selected, option),
            );
          }).toList(),
        ),
      ],
    );
  }
}
