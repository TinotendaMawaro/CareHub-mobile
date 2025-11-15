import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/caregiver_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addCaregiver(Caregiver caregiver) {
    return _db.collection('caregivers').doc(caregiver.id).set({
      'name': caregiver.name,
      'email': caregiver.email,
      'phone': caregiver.phone,
      'qualifications': caregiver.qualifications,
      'experience': caregiver.experience,
      'profilePictureUrl': caregiver.profilePictureUrl,
    });
  }

  Stream<List<Caregiver>> getCaregivers() {
    return _db.collection('caregivers').snapshots().map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return Caregiver(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        qualifications: data['qualifications'] ?? '',
        experience: (data['experience'] as num?)?.toInt() ?? 0,
        profilePictureUrl: data['profilePictureUrl'] ?? '',
      );
    }).toList());
  }

  Future<void> updateCaregiver(Caregiver caregiver) {
    return _db.collection('caregivers').doc(caregiver.id).update({
      'name': caregiver.name,
      'email': caregiver.email,
      'phone': caregiver.phone,
      'qualifications': caregiver.qualifications,
      'experience': caregiver.experience,
      'profilePictureUrl': caregiver.profilePictureUrl,
    });
  }

  Future<void> deleteCaregiver(String caregiverId) {
    return _db.collection('caregivers').doc(caregiverId).delete();
  }
}
