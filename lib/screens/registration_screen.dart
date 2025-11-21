import 'package:carehub/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/logo.dart';

enum UserType { parent, caregiver }

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserType _userType = UserType.parent;

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      final user = await _authService.signUp(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        final role = _userType.toString().split('.').last;
        if (_userType == UserType.caregiver) {
          await _firestore.collection('caregivers').doc(user.uid).set({
            'name': _nameController.text,
            'email': _emailController.text,
            'role': role,
            // TODO: Add more fields for the caregiver.
          });
        } else if (_userType == UserType.parent) {
          await _firestore.collection('parents').doc(user.uid).set({
            'name': _nameController.text,
            'email': _emailController.text,
            'role': role,
            // TODO: Add more fields for the parent.
          });
        }

        if (_userType == UserType.parent) {
          Get.offNamed('/parent_dashboard');
        } else {
          Get.offNamed('/caregiver_dashboard');
        }
      } else {
        Get.snackbar(
          'Registration Failed',
          'Could not create an account. Please try again.',
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
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                HeartHandshakeLogo(size: 60),
                const SizedBox(height: 20),
                Text(
                  'Join CareHub Today',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to get started.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
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
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
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
                    Text('Parent', style: Theme.of(context).textTheme.bodyMedium),
                    Radio<UserType>(
                      value: UserType.caregiver,
                      groupValue: _userType,
                      onChanged: (UserType? value) {
                        setState(() {
                          _userType = value!;
                        });
                      },
                    ),
                    Text('Caregiver', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
