import 'package:flutter/material.dart';

class ParticipantSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const ParticipantSearchBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Search by Name, Email, or Affiliation',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          // Add a clear button that appears when text is entered
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => controller.clear(),
                )
              : null,
        ),
      ),
    );
  }
}