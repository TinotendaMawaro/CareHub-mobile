import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../models/incident_model.dart';
import 'local_database_service.dart';
import 'sync_service.dart';

class IncidentService {
  final CollectionReference _incidentsCollection = FirebaseFirestore.instance.collection('incidents');
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final Connectivity _connectivity = Connectivity();
  final SyncService _syncService = SyncService();

  Future<void> addIncident(Incident incident) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Offline: save locally and queue for sync
      await _localDb.saveIncidentLocally(incident);
      await _syncService.addToSyncQueue('incident', incident.toFirestore());
      Get.snackbar('Offline', 'Incident saved locally. Will sync when online.');
    } else {
      // Online: save to Firestore and cache locally
      await _incidentsCollection.add(incident.toFirestore());
      await _localDb.saveIncidentLocally(incident);
    }
  }

  Stream<List<Incident>> getIncidentsForCaregiver(String caregiverId) {
    return _incidentsCollection
        .where('caregiverId', isEqualTo: caregiverId)
        .snapshots()
        .asyncMap((snapshot) async {
          final onlineIncidents = snapshot.docs.map((doc) => Incident.fromFirestore(doc)).toList();

          // Cache incidents locally for offline access
          for (final incident in onlineIncidents) {
            await _localDb.saveIncidentLocally(incident);
          }

          // If offline, return cached incidents
          final connectivityResult = await _connectivity.checkConnectivity();
          if (connectivityResult.contains(ConnectivityResult.none)) {
            return await _localDb.getLocalIncidents(caregiverId);
          }

          return onlineIncidents;
        });
  }

  Future<void> updateIncidentStatus(String incidentId, String status) async {
    await _incidentsCollection.doc(incidentId).update({'status': status});
  }

  Future<void> updateIncident(Incident incident) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Offline: update locally and queue for sync
      await _localDb.saveIncidentLocally(incident);
      await _syncService.addToSyncQueue('update_incident', incident.toFirestore());
      Get.snackbar('Offline', 'Incident updated locally. Will sync when online.');
    } else {
      // Online: update to Firestore and cache locally
      await _incidentsCollection.doc(incident.id).update(incident.toFirestore());
      await _localDb.saveIncidentLocally(incident);
    }
  }
}
