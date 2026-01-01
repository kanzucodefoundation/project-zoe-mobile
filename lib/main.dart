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
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Project Zoe Design System
import 'core/theme/theme.dart';
import 'core/screens/design_system_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client
  ApiClient().initialize();
  //Initialize Notification Service
  await notificationService.initNotification();
  // Load the .env file
  await dotenv.load(fileName: ".env");
  
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
        theme: AppTheme.lightTheme,
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
          '/design-system-demo': (context) => const DesignSystemDemo(),
        },
      ),
    );
  }
}
