import 'package:carehub/services/auth_service.dart';
import 'package:carehub/services/biometric_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../widgets/logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedRole = 'Parent';
  bool _biometricAvailable = false;
  bool _rememberMe = false;

  Future<void> _login() async {
    try {
      final user = await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        final userData = await _getUserData(user.uid);
        if (userData != null) {
          final role = userData['role'];
          if (role == _selectedRole.toLowerCase()) {
            // Save credentials if remember me is checked
            if (_rememberMe) {
              await context.read<BiometricService>().saveCredentials(
                _emailController.text,
                _passwordController.text,
              );
            }

            if (role == 'parent') {
              Get.offNamed('/parent_dashboard');
            } else if (role == 'caregiver') {
              Get.offNamed('/caregiver_dashboard');
            } else {
              Get.offNamed('/login');
            }
          } else {
            Get.snackbar(
              'Login Failed',
              'Selected role does not match your account role.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          Get.offNamed('/login');
        }
      } else {
        Get.snackbar(
          'Login Failed',
          'Invalid email or password.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _biometricLogin() async {
    final biometricService = context.read<BiometricService>();
    final hasCredentials = await biometricService.hasStoredCredentials();

    if (!hasCredentials) {
      Get.snackbar(
        'Biometric Login',
        'No stored credentials found. Please login manually first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final authenticated = await biometricService.authenticate();
    if (authenticated) {
      final credentials = await biometricService.getCredentials();
      if (credentials['email'] != null && credentials['password'] != null) {
        setState(() {
          _emailController.text = credentials['email']!;
          _passwordController.text = credentials['password']!;
        });
        await _login();
      }
    }
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

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final biometricService = context.read<BiometricService>();
    final available = await biometricService.isBiometricAvailable();
    setState(() {
      _biometricAvailable = available;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                HeartHandshakeLogo(size: 100),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to your CareHub account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: ['Parent', 'Caregiver'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    Text('Remember me', style: Theme.of(context).textTheme.bodyMedium),
                    const Spacer(),
                    if (_biometricAvailable)
                      IconButton(
                        onPressed: _biometricLogin,
                        icon: const Icon(Icons.fingerprint),
                        tooltip: 'Biometric Login',
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => Get.toNamed('/registration'),
                      child: const Text('Register'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/forgot_password'),
                  child: Text('Forgot Password?', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
