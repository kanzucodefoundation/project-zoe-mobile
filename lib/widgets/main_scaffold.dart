import 'package:flutter/material.dart';
import 'package:project_zoe/Screens/general-screens/members_screen_enhanced.dart';
import 'enhanced_bottom_nav.dart';
import '../Screens/general-screens/home_screen_enhanced.dart';
import '../Screens/general-screens/reports_screen_enhanced.dart';
import '../Screens/general-screens/profile_screen_enhanced.dart';
import '../core/theme/theme.dart';
import 'offline_indicator.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0; // Default to Home

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          // Global offline indicator
          const OfflineIndicator(),
          // Main app content
          Expanded(child: _getBody()),
        ],
      ),
      bottomNavigationBar: EnhancedBottomNavBar(
        selectedIndex: _currentIndex,
        onTabChange: _onNavTap,
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const EnhancedHomeScreen();
      case 1:
        return const EnhancedReportsScreen();
      case 2:
        return const EnhancedMembersScreen();
      case 3:
        return const EnhancedProfileScreen();
      default:
        return const EnhancedHomeScreen();
    }
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
  }
}
