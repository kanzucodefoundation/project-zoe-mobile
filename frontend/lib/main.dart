import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/auth/auth_screen.dart';
import 'package:frontend/Screens/home_sceen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Project Zoe',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            switch (authProvider.status) {
              case AuthStatus.authenticated:
                return const HomeSceen();
              case AuthStatus.unauthenticated:
              case AuthStatus.authenticating:
              case AuthStatus.failed:
                return const AuthScreen();
            }
          },
        ),
      ),
    );
  }
}
