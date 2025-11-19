import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Drawer Header with User Profile
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.black),
                accountName: Text(
                  authProvider.user?.name ?? 'User Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  authProvider.user?.email ?? 'user@example.com',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    _getUserInitial(authProvider.user?.name),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),

          // Drawer Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to dashboard if not already there
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.people,
                  title: 'Manage Users',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to manage users screen
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.group,
                  title: 'Groups',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to groups screen
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.event,
                  title: 'Events',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to events screen
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to settings screen
                  },
                ),
                const Divider(color: Colors.grey),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () async {
                    Navigator.pop(context);
                    final authProvider = context.read<AuthProvider>();
                    await authProvider.logout();
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),

          // App Version Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Project Zoe v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.black,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.grey.shade100,
    );
  }

  String _getUserInitial(String? name) {
    if (name == null || name.isEmpty) return 'U';

    final parts = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }

    return 'U';
  }
}
