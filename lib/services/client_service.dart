import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/client_model.dart';
import 'local_database_service.dart';

class ClientService {
  final CollectionReference _clientsCollection = FirebaseFirestore.instance.collection('clients');
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final Connectivity _connectivity = Connectivity();

  Stream<List<Client>> getClientsForCaregiver(String caregiverId) {
    return _clientsCollection
        .where('assignedCaregivers', arrayContains: caregiverId)
        .snapshots()
        .asyncMap((snapshot) async {
          final onlineClients = snapshot.docs.map((doc) => Client.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();

          // Cache clients locally for offline access
          for (final client in onlineClients) {
            await _localDb.saveClientLocally(client);
          }

          // If offline, return cached clients
          final connectivityResult = await _connectivity.checkConnectivity();
          if (connectivityResult.contains(ConnectivityResult.none)) {
            return await _localDb.getLocalClients();
          }

          return onlineClients;
        });
  }

  Future<Client?> getClientById(String clientId) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Offline: get from local database
      final localClients = await _localDb.getLocalClients();
      return localClients.firstWhere((client) => client.id == clientId);
    } else {
      // Online: get from Firestore
      final doc = await _clientsCollection.doc(clientId).get();
      if (doc.exists) {
        final client = Client.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        // Cache locally
        await _localDb.saveClientLocally(client);
        return client;
      }
      return null;
    }
  }
}
