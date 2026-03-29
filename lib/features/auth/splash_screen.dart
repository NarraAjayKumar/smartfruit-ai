import 'package:flutter/material.dart';
import '../../core/services/custom_auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../dashboard/main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 2));
    
    final authService = CustomAuthService();
    final bool loggedIn = await authService.isLoggedIn();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => loggedIn ? const MainScreen() : const LoginScreen(),
        ),
      );
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
            Image.asset('assets/images/logo.png', height: 150),
            const SizedBox(height: 24),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }
}
