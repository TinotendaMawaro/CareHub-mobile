import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../models/shift_model.dart';
import 'offline_shift_service.dart';
import 'local_database_service.dart';
import 'sync_service.dart';

class ShiftService {
  final CollectionReference _shiftsCollection = FirebaseFirestore.instance.collection('shifts');
  final OfflineShiftService _offlineService = OfflineShiftService();
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final Connectivity _connectivity = Connectivity();
  final SyncService _syncService = Get.find<SyncService>();

  Future<void> addShift(Shift shift) async {
    await _shiftsCollection.add(shift.toFirestore());
  }

  Stream<List<Shift>> getShiftsForCaregiver(String caregiverId) {
    return _shiftsCollection
        .where('caregiverId', isEqualTo: caregiverId)
        .snapshots()
        .asyncMap((snapshot) async {
          final onlineShifts = snapshot.docs.map((doc) => Shift.fromFirestore(doc)).toList();

          // Cache shifts locally for offline access
          for (final shift in onlineShifts) {
            await _localDb.saveShiftLocally(shift);
          }

          // If offline, return cached shifts
          final connectivityResult = await _connectivity.checkConnectivity();
          if (connectivityResult.contains(ConnectivityResult.none)) {
            return await _localDb.getLocalShifts(caregiverId);
          }

          return onlineShifts;
        });
  }

  Stream<List<Shift>> getShiftsForClient(String clientId) {
    return _shiftsCollection
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .asyncMap((snapshot) async {
          final onlineShifts = snapshot.docs.map((doc) => Shift.fromFirestore(doc)).toList();

          // Cache shifts locally for offline access
          for (final shift in onlineShifts) {
            await _localDb.saveShiftLocally(shift);
          }

          // If offline, return cached shifts
          final connectivityResult = await _connectivity.checkConnectivity();
          if (connectivityResult.contains(ConnectivityResult.none)) {
            return await _localDb.getLocalShiftsForClient(clientId);
          }

          return onlineShifts;
        });
  }

  Future<void> updateShiftStatus(String shiftId, String status) async {
    final updateData = {'status': status, 'lastUpdate': FieldValue.serverTimestamp()};

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Offline: queue the update
      await _offlineService.queueShiftUpdate(shiftId, updateData);
    } else {
      // Online: update directly and sync any pending updates
      await _shiftsCollection.doc(shiftId).update(updateData);
      await _offlineService.syncPendingUpdates();
    }
  }

  Future<void> startShift(String shiftId) async {
    final updateData = {
      'status': 'started',
      'actualStartTime': FieldValue.serverTimestamp(),
      'lastUpdate': FieldValue.serverTimestamp(),
    };

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      await _offlineService.queueShiftUpdate(shiftId, updateData);
    } else {
      await _shiftsCollection.doc(shiftId).update(updateData);
      await _offlineService.syncPendingUpdates();
    }
  }

  Future<void> endShift(String shiftId) async {
    final updateData = {
      'status': 'completed',
      'actualEndTime': FieldValue.serverTimestamp(),
      'lastUpdate': FieldValue.serverTimestamp(),
    };

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await _offlineService.queueShiftUpdate(shiftId, updateData);
    } else {
      await _shiftsCollection.doc(shiftId).update(updateData);
      await _offlineService.syncPendingUpdates();
    }
  }

  Future<void> updateShiftNotes(String shiftId, String notes) async {
    try {
      await _shiftsCollection.doc(shiftId).update({
        'notes': notes,
        'lastUpdate': FieldValue.serverTimestamp()
      });
    } catch (e) {
      // If offline, queue the update for later sync
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        await _syncService.addToSyncQueue('shift_notes_update', {
          'shiftId': shiftId,
          'updates': {'notes': notes},
        });
        // Update local cache
        await _localDb.updateLocalShift(shiftId, {'notes': notes});
        Get.snackbar('Offline', 'Shift notes updated locally. Will sync when online.');
      } else {
        rethrow;
      }
    }
  }

  Future<void> updateShiftLocation(String shiftId, String location) async {
    final updateData = {'location': location, 'lastUpdate': FieldValue.serverTimestamp()};

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Offline: queue the update
      await _offlineService.queueShiftUpdate(shiftId, updateData);
    } else {
      // Online: update directly and sync any pending updates
      await _shiftsCollection.doc(shiftId).update(updateData);
      await _offlineService.syncPendingUpdates();
    }
  }

  Future<void> addShiftLog(String shiftId, Map<String, dynamic> log) async {
    await _shiftsCollection.doc(shiftId).collection('shiftLogs').add(log);
  }

  Future<void> syncOfflineUpdates() async {
    await _offlineService.syncPendingUpdates();
  }

  Future<List<Map<String, dynamic>>> getPendingOfflineUpdates() async {
    return await _offlineService.getPendingUpdates();
  }

  Stream<List<Shift>> getAllShifts() {
    return _shiftsCollection
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Shift.fromFirestore(doc)).toList());
  }
}
