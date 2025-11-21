import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shift_model.dart';

class OfflineShiftService {
  static const String _pendingUpdatesKey = 'pending_shift_updates';

  Future<void> queueShiftUpdate(String shiftId, Map<String, dynamic> updateData) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUpdates = prefs.getStringList(_pendingUpdatesKey) ?? [];

    final update = {
      'shiftId': shiftId,
      'data': updateData,
      'timestamp': DateTime.now().toIso8601String(),
    };

    pendingUpdates.add(jsonEncode(update));
    await prefs.setStringList(_pendingUpdatesKey, pendingUpdates);
  }

  Future<List<Map<String, dynamic>>> getPendingUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUpdates = prefs.getStringList(_pendingUpdatesKey) ?? [];
    return pendingUpdates.map((update) => jsonDecode(update) as Map<String, dynamic>).toList();
  }

  Future<void> syncPendingUpdates() async {
    final pendingUpdates = await getPendingUpdates();
    final firestore = FirebaseFirestore.instance;

    for (final update in pendingUpdates) {
      try {
        final shiftId = update['shiftId'];
        final data = update['data'];
        final timestamp = DateTime.parse(update['timestamp']);

        // Check for conflicts
        final shiftDoc = await firestore.collection('shifts').doc(shiftId).get();
        if (shiftDoc.exists) {
          final shiftData = shiftDoc.data()!;
          final lastUpdate = shiftData['lastUpdate'] != null
              ? (shiftData['lastUpdate'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(0);

          if (lastUpdate.isAfter(timestamp)) {
            // Conflict: server has newer update, skip this local update
            continue;
          }
        }

        // Add timestamp to prevent future conflicts
        data['lastUpdate'] = FieldValue.serverTimestamp();

        await firestore.collection('shifts').doc(shiftId).update(data);
      } catch (e) {
        print('Error syncing update for shift ${update['shiftId']}: $e');
        // Keep the update in queue for retry
        continue;
      }
    }

    // Clear synced updates
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingUpdatesKey);
  }

  Future<void> clearPendingUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingUpdatesKey);
  }
}
