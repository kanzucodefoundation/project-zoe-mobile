import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_guard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Show splash screen for at least 2 seconds for better UX
      await Future.delayed(const Duration(seconds: 2));

      final authProvider = context.read<AuthProvider>();

      // Check if user is logged in
      final isLoggedIn = await AuthGuard.isLoggedIn();

      if (isLoggedIn) {
        // Check if token is still valid
        final isTokenValid = await AuthGuard.isTokenValid();

        if (isTokenValid) {
          // Restore user session
          final savedUser = await AuthGuard.getSavedUser();
          final savedToken = await AuthGuard.getSavedToken();

          if (savedUser != null && savedToken != null && mounted) {
            await authProvider.restoreSession(savedUser, savedToken);
            // AppWrapper will automatically navigate based on auth state
          } else {
            if (mounted) authProvider.setUnauthenticated();
          }
        } else {
          // Token is invalid, clear data
          await AuthGuard.clearUserData();
          if (mounted) authProvider.setUnauthenticated();
        }
      } else {
        // User not logged in
        if (mounted) authProvider.setUnauthenticated();
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        authProvider.setUnauthenticated();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_image.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Project Zoe Logo/Title
              Text(
                'PROJECT ZOE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome back!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 50),
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
