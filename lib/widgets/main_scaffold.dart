import 'package:flutter/material.dart';
import 'package:project_zoe/Screens/General%20screens/contacts.dart';
import 'custom_app_bar.dart';
import 'custom_drawer.dart';
import 'beautiful_bottom_nav.dart';
import '../Screens/General screens/home_sceen.dart';
import '../Screens/General screens/reports_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 1; // Default to Dashboard

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _currentIndex == 1 ? CustomAppBar(title: _getTitle()) : null,
      drawer: _currentIndex == 1 ? const CustomDrawer() : null,
      body: _getBody(),
      bottomNavigationBar: BeautifulBottomNavBar(
        selectedIndex: _currentIndex,
        onTabChange: _onNavTap,
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Reports';
      case 1:
        return 'Dashboard';
      case 2:
        return 'Admin';
      default:
        return 'Dashboard';
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return ReportsScreen();
      case 1:
        return const HomeScreen();
      case 2:
        return const ContactsScreen();
      default:
        return const HomeScreen();
    }
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
  }
}
