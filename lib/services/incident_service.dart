import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';

class IncidentService {
  final CollectionReference _incidentsCollection = FirebaseFirestore.instance.collection('incidents');

  Future<void> addIncident(Incident incident) async {
    await _incidentsCollection.add(incident.toFirestore());
  }
}
