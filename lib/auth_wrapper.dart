import 'package:carehub/screens/caregiver_dashboard.dart';
import 'package:carehub/screens/login_screen.dart';
import 'package:carehub/screens/parent_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userType = userSnapshot.data!['userType'];
                if (userType == 'parent') {
                  return const ParentDashboard();
                } else {
                  return const CaregiverDashboard();
                }
              } else {
                // This case handles users that are authenticated but don't have a document in firestore
                // This can happen if the document creation fails after registration
                // You might want to navigate them back to a registration completion screen or simply the login screen
                return const LoginScreen();
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
