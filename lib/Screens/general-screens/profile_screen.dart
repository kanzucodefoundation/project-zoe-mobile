import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: Text('Please log in to view your profile'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black),
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/auth', // Assuming you have an auth route
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // User Name
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // User Role Badge - Made more prominent
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.primaryRole),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: _getRoleColor(
                          user.primaryRole,
                        ).withValues(alpha: 0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoleIcon(user.primaryRole),
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.primaryRole.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // User Information Section
                _buildInfoSection('Personal Information', [
                  _buildInfoTile(Icons.email, 'Email', user.email),
                  _buildInfoTile(Icons.badge, 'User ID', user.id.toString()),
                  _buildInfoTile(
                    Icons.business,
                    'Department',
                    user.roles.isNotEmpty ? user.roles.first : 'Unknown',
                  ),
                ]),
                const SizedBox(height: 24),

                // Permissions Section
                _buildInfoSection('Permissions', [
                  _buildPermissionTile(
                    Icons.visibility,
                    'View Shepherds',
                    authProvider.canViewShepherds,
                  ),
                  _buildPermissionTile(
                    Icons.edit,
                    'Manage Shepherds',
                    authProvider.canManageShepherds,
                  ),
                  _buildPermissionTile(
                    Icons.admin_panel_settings,
                    'Admin Access',
                    authProvider.isAdmin,
                  ),
                ]),
                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/auth',
                            (route) => false,
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(
    IconData icon,
    String permission,
    bool hasPermission,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              permission,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Icon(
            hasPermission ? Icons.check_circle : Icons.cancel,
            color: hasPermission ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Get the color for a specific user role
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'movement leader':
        return const Color(0xFFE53E3E); // Red for movement leader
      case 'location pastor':
        return const Color(0xFF059669); // Green for location pastor
      case 'zone leader':
        return const Color(0xFF7C3AED); // Purple for zone leader
      case 'mc shepherd':
        return const Color(0xFF2563EB); // Blue for MC shepherd
      default:
        return const Color(0xFF6B7280); // Gray for unknown roles
    }
  }

  /// Get the icon for a specific user role
  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'movement leader':
        return Icons.admin_panel_settings;
      case 'location pastor':
        return Icons.church;
      case 'zone leader':
        return Icons.shield;
      case 'mc shepherd':
        return Icons.group;
      default:
        return Icons.person;
    }
  }
}
