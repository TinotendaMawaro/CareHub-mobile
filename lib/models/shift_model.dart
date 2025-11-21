import 'package:cloud_firestore/cloud_firestore.dart';

class Shift {
  final String id;
  final String caregiverId;
  final String clientId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // pending, accepted, rejected, started, ended
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  String? notes;
  String? location;

  Shift({
    required this.id,
    required this.caregiverId,
    required this.clientId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.actualStartTime,
    this.actualEndTime,
    this.notes,
    this.location,
  });

  factory Shift.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Shift(
      id: doc.id,
      caregiverId: data['caregiverId'] ?? '',
      clientId: data['clientId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      actualStartTime: data['actualStartTime'] != null ? (data['actualStartTime'] as Timestamp).toDate() : null,
      actualEndTime: data['actualEndTime'] != null ? (data['actualEndTime'] as Timestamp).toDate() : null,
      notes: data['notes'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'caregiverId': caregiverId,
      'clientId': clientId,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'actualStartTime': actualStartTime,
      'actualEndTime': actualEndTime,
      'notes': notes,
    };
  }
}
