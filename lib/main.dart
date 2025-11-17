import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';
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
    const primaryColor = Color(0xFF4CAF50); // A green shade
    const secondaryColor = Color(0xFFFFC107); // An amber shade

    final lightTheme = ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: Colors.grey[50],
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).primaryTextTheme.apply(bodyColor: Colors.white, displayColor: Colors.white)),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );

    return GetMaterialApp(
      title: 'CareHub',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Or ThemeMode.light, ThemeMode.dark
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const AuthWrapper()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/registration', page: () => const RegistrationScreen()),
        GetPage(name: '/forgot_password', page: () => const ForgotPasswordScreen()),
        GetPage(name: '/caregiver_dashboard', page: () => const CaregiverDashboard()),
        GetPage(name: '/parent_dashboard', page: () => const ParentDashboard()),
        GetPage(name: '/caregivers', page: () => const CaregiversPage()),
        GetPage(
          name: '/add_edit_caregiver',
          page: () {
            final Caregiver? caregiver = Get.arguments as Caregiver?;
            return AddEditCaregiverPage(caregiver: caregiver);
          },
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
