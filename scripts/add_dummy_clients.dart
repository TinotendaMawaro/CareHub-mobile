import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference clientsCollection = db.collection('clients');

  // Add dummy clients
  clientsCollection.add({
    'name': 'John Doe',
    'diagnosis': 'Alzheimer\'s Disease',
    'address': '123 Main St, Anytown, USA',
    'emergencyContact': 'Jane Doe - 555-1234',
    'caregiverId': 'YOUR_CAREGIVER_ID' // Replace with a valid caregiver ID
  });

  clientsCollection.add({
    'name': 'Jane Smith',
    'diagnosis': 'Parkinson\'s Disease',
    'address': '456 Oak Ave, Anytown, USA',
    'emergencyContact': 'John Smith - 555-5678',
    'caregiverId': 'YOUR_CAREGIVER_ID' // Replace with a valid caregiver ID
  });
}
