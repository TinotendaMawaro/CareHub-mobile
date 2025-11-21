import 'dart:io';
import 'package:carehub/models/client_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/caregiver_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addCaregiver(Caregiver caregiver) {
    return _db.collection('caregivers').doc(caregiver.id).set({
      'name': caregiver.name,
      'email': caregiver.email,
      'phone': caregiver.phone,
      'certifications': caregiver.certifications,
      'qualifications': caregiver.qualifications,
      'experience': caregiver.experience,
      'profilePictureUrl': caregiver.profilePictureUrl,
      'fcmToken': caregiver.fcmToken,
      'lastTokenUpdate': caregiver.lastTokenUpdate,
      'availabilityStatus': caregiver.availabilityStatus,
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
        certifications: data['certifications'] ?? '',
        qualifications: data['qualifications'] ?? '',
        experience: (data['experience'] as num?)?.toInt() ?? 0,
        profilePictureUrl: data['profilePictureUrl'] ?? '',
        fcmToken: data['fcmToken'],
        lastTokenUpdate: data['lastTokenUpdate'] != null ? (data['lastTokenUpdate'] as Timestamp).toDate() : null,
        availabilityStatus: data['availabilityStatus'] ?? 'Available',
      );
    }).toList());
  }

  Future<Caregiver?> getCaregiver(String caregiverId) async {
    final doc = await _db.collection('caregivers').doc(caregiverId).get();
    if (doc.exists) {
      final data = doc.data()!;
      return Caregiver(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        certifications: data['certifications'] ?? '',
        qualifications: data['qualifications'] ?? '',
        experience: (data['experience'] as num?)?.toInt() ?? 0,
        profilePictureUrl: data['profilePictureUrl'] ?? '',
        fcmToken: data['fcmToken'],
        lastTokenUpdate: data['lastTokenUpdate'] != null ? (data['lastTokenUpdate'] as Timestamp).toDate() : null,
        availabilityStatus: data['availabilityStatus'] ?? 'Available',
      );
    }
    return null;
  }

  Future<void> updateCaregiver(Caregiver caregiver) {
    return _db.collection('caregivers').doc(caregiver.id).update({
      'name': caregiver.name,
      'email': caregiver.email,
      'phone': caregiver.phone,
      'certifications': caregiver.certifications,
      'qualifications': caregiver.qualifications,
      'experience': caregiver.experience,
      'profilePictureUrl': caregiver.profilePictureUrl,
      'fcmToken': caregiver.fcmToken,
      'lastTokenUpdate': caregiver.lastTokenUpdate,
      'availabilityStatus': caregiver.availabilityStatus,
    });
  }

  Future<void> deleteCaregiver(String caregiverId) {
    return _db.collection('caregivers').doc(caregiverId).delete();
  }

  Future<String> uploadProfilePicture(String userId, File image) async {
    final storageRef = _storage.ref().child('profile_pictures/$userId');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  Stream<List<Client>> getAssignedClients(String caregiverId) {
    return _db
        .collection('clients')
        .where('assignedCaregiver', isEqualTo: caregiverId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Client.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<String> uploadFile(File file, String path) async {
    final storageRef = _storage.ref().child(path);
    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }
}
