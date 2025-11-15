import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String caregiverId;
  final String parentId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // e.g., 'pending', 'confirmed', 'cancelled'

  Booking({
    required this.id,
    required this.caregiverId,
    required this.parentId,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      caregiverId: data['caregiverId'] ?? '',
      parentId: data['parentId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'caregiverId': caregiverId,
      'parentId': parentId,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
    };
  }
}
