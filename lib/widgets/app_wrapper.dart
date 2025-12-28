import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../Screens/General screens/splash_screen.dart';
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
  void initState() {
    super.initState();
    // Trigger session check on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkExistingSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint('AppWrapper: AuthProvider status = ${authProvider.status}');
        switch (authProvider.status) {
          case AuthStatus.authenticating:
            // Show splash/loading screen while checking session or authenticating
            debugPrint('AppWrapper: Showing SplashScreen');
            return const SplashScreen();

          case AuthStatus.authenticated:
            // User is logged in, show main app with navigation
            debugPrint('AppWrapper: Showing MainScaffold (authenticated)');
            return const MainScaffold();

          case AuthStatus.unauthenticated:
          case AuthStatus.failed:
            // User is not logged in or login failed, show auth screen
            debugPrint(
              'AppWrapper: Showing AuthScreen (unauthenticated/failed)',
            );
            return const AuthScreen();
        }
      },
    );
  }
}
