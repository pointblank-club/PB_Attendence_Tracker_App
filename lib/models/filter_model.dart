import 'package:flutter/material.dart';

class FilterModel {
  RangeValues? ageRange;
  Set<String> genders;
  Set<String> affiliationTypes;
  Set<String> experienceLevels;
  bool? previousParticipation;
  bool? isDuo; 

  FilterModel({
    this.ageRange,
    this.genders = const {},
    this.affiliationTypes = const {},
    this.experienceLevels = const {},
    this.previousParticipation,
    this.isDuo,
  });

  bool get isFilterActive =>
      ageRange != null ||
      genders.isNotEmpty ||
      affiliationTypes.isNotEmpty ||
      experienceLevels.isNotEmpty ||
      previousParticipation != null ||
      isDuo != null;
}