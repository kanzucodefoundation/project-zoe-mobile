import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'custom_drawer.dart';
import 'beautiful_bottom_nav.dart';
import '../Screens/home_sceen.dart';

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
      appBar: CustomAppBar(title: _getTitle()),
      drawer: const CustomDrawer(),
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
        return const Center(
          child: Text(
            'Reports Screen',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        );
      case 1:
        return const HomeSceen();
      case 2:
        return const Center(
          child: Text(
            'Admin Screen',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        );
      default:
        return const HomeSceen();
    }
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
  }
}
