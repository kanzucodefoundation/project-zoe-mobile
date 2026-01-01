import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BeautifulBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const BeautifulBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    // final auth = context.watch<AuthProvider>();
    // final canSeeAdmin = auth.isWebAdmin;

    final tabs = <GButton>[
      const GButton(
        icon: Icons.assessment_outlined,
        text: 'Reports',
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      const GButton(
        icon: Icons.dashboard_outlined,
        text: 'Dashboard',
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ];
    // if (canSeeAdmin) {
    tabs.add(
      const GButton(
        icon: Icons.groups_outlined,
        text: 'Members',
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
    //}
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: GNav(
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
          gap: 8,
          activeColor: Colors.white,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.black,
          color: Colors.grey.shade600,
          tabs: tabs,
        ),
      ),
    );
  }
}
