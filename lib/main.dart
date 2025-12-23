import 'package:flutter/material.dart';
import 'package:project_zoe/providers/people_provider.dart';
import 'package:project_zoe/providers/dashboard_provider.dart';
import 'package:project_zoe/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/report_provider.dart';
import 'widgets/app_wrapper.dart';
import 'api/api_client.dart';
import 'screens/garage_attendance_screen.dart';
import 'Screens/reports_screen.dart';
import 'screens/admin_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'Screens/settings_screen.dart';

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
        ChangeNotifierProvider<PeopleProvider>(create: (_) => PeopleProvider()),
        ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider()),
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
          '/garage-attendance': (context) => const GarageAttendanceScreen(),
          // '/garage-reports-display': (context) => const GarageReportsScreen(),
          // '/shepherds-details': (context) =>
          //     const ShepherdDetailsScreen(shepherdId: 0),
          '/reports': (context) => ReportsScreen(),
          '/admin': (context) => const AdminScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
