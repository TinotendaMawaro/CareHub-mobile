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

    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        // First try to parse as full DateTime
        try {
          return DateTime.parse(value);
        } catch (e) {
          // If that fails, try parsing as time (HH:MM) and combine with today's date
          final timeRegex = RegExp(r'^(\d{1,2}):(\d{2})$');
          final match = timeRegex.firstMatch(value.trim());
          if (match != null) {
            final hour = int.tryParse(match.group(1)!);
            final minute = int.tryParse(match.group(2)!);
            if (hour != null && minute != null && hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
              final now = DateTime.now();
              return DateTime(now.year, now.month, now.day, hour, minute);
            }
          }
          // Try other common formats
          try {
            // Handle formats like "2023-12-25 09:52" or "12/25/2023 09:52"
            final dateTimeRegex = RegExp(r'(\d{4}-\d{2}-\d{2}|\d{2}/\d{2}/\d{4})\s+(\d{1,2}):(\d{2})');
            final dtMatch = dateTimeRegex.firstMatch(value);
            if (dtMatch != null) {
              final dateStr = dtMatch.group(1)!;
              final hour = int.parse(dtMatch.group(2)!);
              final minute = int.parse(dtMatch.group(3)!);
              DateTime date;
              if (dateStr.contains('-')) {
                date = DateTime.parse(dateStr);
              } else {
                final parts = dateStr.split('/');
                date = DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
              }
              return DateTime(date.year, date.month, date.day, hour, minute);
            }
          } catch (e2) {
            // Continue to fallback
          }
          return DateTime.now(); // fallback
        }
      } else if (value is int) {
        // Handle Unix timestamp (milliseconds)
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is Map && value.containsKey('seconds')) {
        // Handle Firestore timestamp format
        final seconds = value['seconds'] as int?;
        final nanoseconds = value['nanoseconds'] as int? ?? 0;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + (nanoseconds ~/ 1000000));
        }
      }
      return DateTime.now(); // fallback
    }

    return Shift(
      id: doc.id,
      caregiverId: data['caregiverId'] ?? '',
      clientId: data['clientId'] ?? '',
      startTime: parseTimestamp(data['startTime']),
      endTime: parseTimestamp(data['endTime']),
      status: data['status'] ?? 'pending',
      actualStartTime: data['actualStartTime'] != null ? parseTimestamp(data['actualStartTime']) : null,
      actualEndTime: data['actualEndTime'] != null ? parseTimestamp(data['actualEndTime']) : null,
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
