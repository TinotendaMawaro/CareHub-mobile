import 'package:carehub/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/logo.dart';

enum UserType { parent, caregiver }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  UserType _userType = UserType.parent;

  Future<void> _login() async {
    try {
      final user = await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        if (_userType == UserType.parent) {
          Get.offNamed('/parent_dashboard');
        } else {
          Get.offNamed('/caregiver_dashboard');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const HeartLogo(size: 80),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to your CareHub account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<UserType>(
                      value: UserType.parent,
                      groupValue: _userType,
                      onChanged: (UserType? value) {
                        setState(() {
                          _userType = value!;
                        });
                      },
                    ),
                    const Text('Parent'),
                    Radio<UserType>(
                      value: UserType.caregiver,
                      groupValue: _userType,
                      onChanged: (UserType? value) {
                        setState(() {
                          _userType = value!;
                        });
                      },
                    ),
                    const Text('Caregiver'),
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
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Get.toNamed('/registration'),
                      child: const Text('Register'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/forgot_password'),
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
