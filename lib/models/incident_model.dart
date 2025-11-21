import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String caregiverId;
  final String incidentType; // e.g., Medical, Behavioral, etc.
  final String description;
  final DateTime dateTime;
  final String involvedParties;
  final String actionsTaken;
  final String status; // e.g., Reported, Under Review, Resolved
  final List<String>? photoUrls;

  Incident({
    required this.id,
    required this.caregiverId,
    required this.incidentType,
    required this.description,
    required this.dateTime,
    required this.involvedParties,
    required this.actionsTaken,
    required this.status,
    this.photoUrls,
  });

  factory Incident.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Incident(
      id: doc.id,
      caregiverId: data['caregiverId'] ?? '',
      incidentType: data['incidentType'] ?? '',
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      involvedParties: data['involvedParties'] ?? '',
      actionsTaken: data['actionsTaken'] ?? '',
      status: data['status'] ?? 'Reported',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'caregiverId': caregiverId,
      'incidentType': incidentType,
      'description': description,
      'dateTime': dateTime,
      'involvedParties': involvedParties,
      'actionsTaken': actionsTaken,
      'status': status,
      'photoUrls': photoUrls,
    };
  }
}
