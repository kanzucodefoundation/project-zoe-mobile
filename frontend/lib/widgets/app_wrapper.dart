import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../auth/auth_screen.dart';
import 'main_scaffold.dart';

/// Main app wrapper that handles navigation based on auth state
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.status) {
          case AuthStatus.authenticating:
            // Show splash/loading screen while checking session or authenticating
            return const SplashScreen();

          case AuthStatus.authenticated:
            // User is logged in, show main app with navigation
            return const MainScaffold();

          case AuthStatus.unauthenticated:
          case AuthStatus.failed:
            // User is not logged in or login failed, show auth screen
            return const AuthScreen();
        }
      },
    );
  }
}
