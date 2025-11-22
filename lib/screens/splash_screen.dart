import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/logo.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<Alignment> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();

    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(_gradientController);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    Timer(const Duration(seconds: 10), () {
      Get.offNamed('/auth');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0B0E11),
                  const Color(0xFF1A1D23),
                  const Color(0xFF6200EE).withOpacity(0.3),
                  const Color(0xFF9C27B0).withOpacity(0.3),
                ],
                begin: _gradientAnimation.value,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 300.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Center(child: HeartHandshakeLogo(size: 60)),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'CareHub',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF99)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
