class ParticipantModel {
  // Core Identifiers
  final String id;
  final String teamId;
  final String eventName;

  // Participant Info
  final String name;
  final String email;
  final int? age;
  final String? gender;
  final String? phone;

  // Background Info
  final String? experienceLevel;
  final bool? previousParticipation;
  final String? participationDetails;
  final String? affiliationType;
  final String? affiliationName;

  bool isSelected;

  ParticipantModel({
    required this.id,
    required this.teamId,
    required this.eventName,
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.phone,
    this.experienceLevel,
    this.previousParticipation,
    this.participationDetails,
    this.affiliationType,
    this.affiliationName,
    this.isSelected = true,
  });

  Map<String, dynamic> toJson() => {
        // data for the QR code/email
        'participant_id': id,
        'team_id': teamId,
        'event_name': eventName,
        'participant_name': name,
        'participant_email': email,
        'age': age,
        'gender': gender,
        'phone': phone,
        'experienceLevel': experienceLevel,
        'previousParticipation': previousParticipation,
        'participationDetails': participationDetails,
        'affiliationName': affiliationName,
        'affiliationType': affiliationType,
      };

  factory ParticipantModel.fromJson(Map<String, dynamic> json) =>
      ParticipantModel(
        id: json['participant_id'],
        teamId: json['team_id'],
        eventName: json['event_name'],
        name: json['participant_name'],
        email: json['participant_email'],
        age: json['age'],
        gender: json['gender'],
        phone: json['phone'],
        experienceLevel: json['experienceLevel'],
        previousParticipation: json['previousParticipation'],
        participationDetails: json['participationDetails'],
        affiliationType: json['affiliationType'],
        affiliationName: json['affiliationName'],
      );
}