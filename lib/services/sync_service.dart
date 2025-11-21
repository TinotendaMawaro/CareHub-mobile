import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_database_service.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final Connectivity _connectivity = Connectivity();

  static const String syncTaskName = 'background_sync';

  Future<void> initialize() async {
    // Initialize WorkManager for background sync only on Android/iOS
    if (!kIsWeb) {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

      // Register periodic sync task
      await Workmanager().registerPeriodicTask(
        syncTaskName,
        syncTaskName,
        frequency: const Duration(minutes: 15), // Sync every 15 minutes
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    }

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)) {
        // Online: trigger sync
        performSync();
      }
    });
  }

  Future<void> performSync() async {
    try {
      final pendingSync = await _localDb.getPendingSync();

      for (final syncItem in pendingSync) {
        try {
          final type = syncItem['type'];
          final data = syncItem['data'];

          switch (type) {
            case 'shift_update':
              // Handle shift updates
              await _syncShiftUpdate(data);
              break;
            case 'incident':
              // Handle incident submissions
              await _syncIncident(data);
              break;
          }

          // Remove from pending sync
          await _localDb.removePendingSync(syncItem['id']);
        } catch (e) {
          print('Error syncing item ${syncItem['id']}: $e');
          // Keep in queue for retry
        }
      }

      Get.snackbar('Sync Complete', 'All offline data synced successfully.');
    } catch (e) {
      print('Error during sync: $e');
      Get.snackbar('Sync Error', 'Failed to sync some data. Will retry later.');
    }
  }

  Future<void> _syncShiftUpdate(Map<String, dynamic> data) async {
    // Implementation depends on your shift update structure
    // This is a placeholder - adjust based on your actual data structure
    final shiftId = data['shiftId'];
    final updates = data['updates'];

    // Update Firestore
    await FirebaseFirestore.instance.collection('shifts').doc(shiftId).update(updates);
  }

  Future<void> _syncIncident(Map<String, dynamic> data) async {
    // Convert data back to Incident object and save to Firestore
    // This is a placeholder - adjust based on your actual data structure
    await FirebaseFirestore.instance.collection('incidents').add(data);
  }

  Future<void> addToSyncQueue(String type, Map<String, dynamic> data) async {
    await _localDb.addPendingSync(type, data);
  }

  Future<int> getPendingSyncCount() async {
    final pending = await _localDb.getPendingSync();
    return pending.length;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final syncService = SyncService();
      await syncService.performSync();
      return true;
    } catch (e) {
      print('Background sync failed: $e');
      return false;
    }
  });
}
