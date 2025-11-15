import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carehub/services/auth_service.dart';
import 'package:carehub/services/database_service.dart';
import '../widgets/logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    final user = _authService.currentUser;
    if (user != null) {
      final userDoc = await _databaseService.users.doc(user.uid).get();
      if (userDoc.exists) {
        final userRole = userDoc.get('role');
        if (userRole == 'parent') {
          Get.offNamed('/parent_dashboard');
        } else if (userRole == 'caregiver') {
          Get.offNamed('/caregiver_dashboard');
        } else {
          Get.offNamed('/login');
        }
      } else {
        Get.offNamed('/login');
      }
    } else {
      Get.offNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HeartLogo(size: 120),
            const SizedBox(height: 20),
            Text(
              'CareHub',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreen[600],
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
