import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';

class ClientService {
  final CollectionReference _clientsCollection = FirebaseFirestore.instance.collection('clients');

  Stream<List<Client>> getClientsForCaregiver(String caregiverId) {
    return _clientsCollection
        .where('caregiverId', isEqualTo: caregiverId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Client.fromFirestore(doc)).toList());
  }
}
