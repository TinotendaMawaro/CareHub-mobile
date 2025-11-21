import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';
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
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/shift_service.dart';
import 'services/incident_service.dart';
import 'services/notification_service.dart';
import 'services/biometric_service.dart';
import 'services/sync_service.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize sync service
  final syncService = SyncService();
  await syncService.initialize();

  // Put services into GetX dependency injection
  Get.put(syncService);
  Get.put(ShiftService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00C853); // A vibrant green shade
    const secondaryColor = Color(0xFF6200EE); // A purple shade

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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIconColor: Colors.grey[600],
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B0E11),
      cardColor: Colors.white.withOpacity(0.05),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black.withOpacity(.3),
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00FF99),
        secondary: Color(0xFF9C27B0),
      ),
    );

    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<ShiftService>(create: (_) => ShiftService()),
        Provider<IncidentService>(create: (_) => IncidentService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        Provider<BiometricService>(create: (_) => BiometricService()),
        Provider<SyncService>(create: (_) => SyncService()),
      ],
      child: GetMaterialApp(
        title: 'CareHub',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.dark, // Default to dark mode
        initialRoute: '/splash',
        getPages: [
          GetPage(name: '/splash', page: () => const SplashScreen()),
          GetPage(name: '/auth', page: () => AuthWrapper()),
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
      ),
    );
  }
}
