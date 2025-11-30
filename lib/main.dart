import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:frontend/widgets/app_wrapper.dart';
import 'package:frontend/api/api_client.dart';
import 'package:frontend/screens/mc_report_screen.dart';
import 'package:frontend/screens/garage_attendance_screen.dart';
import 'package:frontend/screens/details_screens/shepherd_details_screen.dart';
import 'package:frontend/Screens/reports_screen.dart';
import 'package:frontend/screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client
  ApiClient().initialize();

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
          '/mc-report': (context) => const McReportScreen(),
          '/garage-attendance': (context) => const GarageAttendanceScreen(),
          '/shepherds-details': (context) =>
              const ShepherdDetailsScreen(shepherdId: ''),
          '/reports': (context) => ReportsScreen(),
          '/admin': (context) => const AdminScreen(),
        },
      ),
    );
  }
}
