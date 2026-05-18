import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';
import '../main/main_screen.dart';

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
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    if (AuthService.isLoggedIn) {
      final profile = await AuthService.getCurrentUserProfile();
      if (!mounted) return;
      if (profile != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainScreen(user: profile)),
        );
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.home_work, size: 72, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'Emlak İlan Sistemi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Görüşme Takip Uygulaması',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
