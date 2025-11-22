import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;
  final caregiverId = 'RvP3opbLWB50REkpNtP0';

  print('Starting to update existing clients and shifts...');

  // Update clients to assign the caregiver
  print('Updating clients...');
  final clientsSnapshot = await firestore.collection('clients').get();
  for (final doc in clientsSnapshot.docs) {
    final data = doc.data();
    String? assignedCaregiverId = data['assignedCaregiverId'];

    if (assignedCaregiverId != caregiverId) {
      await doc.reference.update({
        'assignedCaregiverId': caregiverId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Updated client: ${data['name']}');
    } else {
      print('Client ${data['name']} already has caregiver assigned');
    }
  }

  // Update shifts to assign the caregiver
  print('Updating shifts...');
  final shiftsSnapshot = await firestore.collection('shifts').get();
  for (final doc in shiftsSnapshot.docs) {
    final data = doc.data();

    if (data['caregiverId'] != caregiverId) {
      await doc.reference.update({
        'caregiverId': caregiverId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Updated shift: ${doc.id}');
    } else {
      print('Shift ${doc.id} already has correct caregiver');
    }
  }

  print('All existing clients and shifts have been updated successfully!');
  print('Caregiver ID assigned: $caregiverId');
}
