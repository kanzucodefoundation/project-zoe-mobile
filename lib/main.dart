import 'package:flutter/material.dart';
import 'package:project_zoe/Screens/General%20screens/groups.dart';
import 'package:project_zoe/providers/contacts_provider.dart';
import 'package:project_zoe/providers/dashboard_provider.dart';
import 'package:project_zoe/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/report_provider.dart';
import 'providers/salvation_reports_provider.dart';
import 'widgets/app_wrapper.dart';
import 'api/api_client.dart';
import 'Screens/Reports screens/baptism_reports_display_screen.dart';
import 'Screens/Reports screens/salvation_reports_display_screen.dart';
import 'Screens/General screens/reports_screen.dart';
import 'Screens/General screens/admin_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'Screens/General screens/settings_screen.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
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
          // '/garage-reports-display': (context) => const GarageReportsScreen(),
          '/groups': (context) => const GroupsScreen(),
          '/reports': (context) => ReportsScreen(),
          '/admin': (context) => const AdminScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
