import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePicture(String userId, File image) async {
    try {
      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile picture: $e');
      return '';
    }
  }

  Future<void> deleteProfilePicture(String userId) async {
    try {
      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      await ref.delete();
    } catch (e) {
      print('Error deleting profile picture: $e');
    }
  }
}
