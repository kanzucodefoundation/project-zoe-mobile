import 'package:flutter/material.dart';
import 'package:project_zoe/Screens/general-screens/groups.dart';
import 'package:project_zoe/Screens/general-screens/users.dart';
import 'package:project_zoe/providers/contacts_provider.dart';
import 'package:project_zoe/providers/dashboard_provider.dart';
import 'package:project_zoe/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/report_provider.dart';
import 'providers/salvation_reports_provider.dart';
import 'widgets/app_wrapper.dart';
import 'api/api_client.dart';
import 'Screens/reports-screens/baptism_reports_display_screen.dart';
import 'Screens/reports-screens/salvation_reports_display_screen.dart';
import 'Screens/general-screens/reports_screen.dart';
import 'Screens/general-screens/admin_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'Screens/general-screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client
  ApiClient().initialize();
  //Initialize Notification Service
  await notificationService.initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ReportProvider>(create: (_) => ReportProvider()),
        ChangeNotifierProvider<SalvationReportsProvider>(
          create: (_) => SalvationReportsProvider(),
        ),
        ChangeNotifierProvider<ContactsProvider>(
          create: (_) => ContactsProvider(),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Project Zoe',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            surface: const Color(0xFFFFFFFF), // Pure white
            // ignore: deprecated_member_use
            background: const Color(0xFFFFFFFF), // Pure white
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Pure white
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFFFFF), // Pure white
            surfaceTintColor: Colors.transparent, // Remove Material 3 tint
            elevation: 0,
          ),
        ),
        home: const AppWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),

          // '/mc-report': (context) => const McReportScreen(),
          // '/mc-reports-display': (context) => const McReportsScreen(),
          '/baptism-reports': (context) =>
              const BaptismReportsScreen(reportId: 0),
          '/salvation-reports': (context) =>
              const SalvationReportsScreen(reportId: 0),
          '/users': (context) => const UsersScreen(),
          '/groups': (context) => const GroupsScreen(),
          '/reports': (context) => ReportsScreen(),
          '/admin': (context) => const AdminScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
