import 'package:carehub/screens/caregiver_dashboard.dart';
import 'package:carehub/screens/login_screen.dart';
import 'package:carehub/screens/parent_dashboard.dart';
import 'package:carehub/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          // Update FCM token when user logs in
          context.read<NotificationService>().updateFCMToken();

          return FutureBuilder<Map<String, dynamic>?>(
            future: _getUserData(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasData && userSnapshot.data != null) {
                final role = userSnapshot.data!['role'];
                if (role == 'parent') {
                  return ParentDashboard();
                } else {
                  return CaregiverDashboard();
                }
              } else {
                return LoginScreen();
              }
            },
          );
        } else {
          // Remove FCM token when user logs out
          context.read<NotificationService>().removeFCMToken();
          return LoginScreen();
        }
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    final caregiverDoc = await _firestore.collection('caregivers').doc(uid).get();
    if (caregiverDoc.exists) {
      return {'role': 'caregiver', ...caregiverDoc.data()!};
    }
    final parentDoc = await _firestore.collection('parents').doc(uid).get();
    if (parentDoc.exists) {
      return {'role': 'parent', ...parentDoc.data()!};
    }
    return null;
  }
}
