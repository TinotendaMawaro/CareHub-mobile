import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String clientId;
  final String caregiverId;
  final DateTime timestamp;
  final String description;

  Incident({
    required this.id,
    required this.clientId,
    required this.caregiverId,
    required this.timestamp,
    required this.description,
  });

  factory Incident.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Incident(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      caregiverId: data['caregiverId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'caregiverId': caregiverId,
      'timestamp': timestamp,
      'description': description,
    };
  }
}
