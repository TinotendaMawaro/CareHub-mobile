import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/caregiver_dashboard.dart';
import 'screens/parent_dashboard.dart';
import 'screens/caregivers_page.dart';
import 'screens/add_edit_caregiver_page.dart';
import 'screens/caregiver_details_page.dart';
import 'screens/booking_page.dart';
import 'models/caregiver_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CareHub',
      theme: ThemeData(
        primaryColor: Colors.lightGreen[400],
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightGreen[400],
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen[400],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/registration', page: () => const RegistrationScreen()),
        GetPage(name: '/forgot_password', page: () => const ForgotPasswordScreen()),
        GetPage(name: '/caregiver_dashboard', page: () => const CaregiverDashboard()),
        GetPage(name: '/parent_dashboard', page: () => const ParentDashboard()),
        GetPage(name: '/caregivers', page: () => const CaregiversPage()),
        GetPage(
          name: '/add_edit_caregiver',
          page: () => AddEditCaregiverPage(caregiver: Get.arguments as Caregiver?),
        ),
        GetPage(
          name: '/caregiver_details',
          page: () => CaregiverDetailsPage(caregiver: Get.arguments as Caregiver),
        ),
        GetPage(
          name: '/booking',
          page: () => BookingPage(caregiver: Get.arguments as Caregiver),
        ),
      ],
    );
  }
}
