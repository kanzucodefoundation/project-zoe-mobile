import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_provider.dart';

class UserDetailsScreen extends StatefulWidget {
  final int userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsProvider>().loadUserDetails(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Consumer<ContactsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.black87,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading user details...',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 40,
                        color: Colors.red[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Error Loading Contact',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.error!,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.loadContactDetails(widget.userId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = provider.currentUserDetails;
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'User not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar and name
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user.avatar),
                        child: user.avatar.isEmpty
                            ? Text(
                                user.initials,
                                style: TextStyle(fontSize: 32),
                              )
                            : null,
                      ),
                      SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        user.primaryRole,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 8),
                      Chip(
                        label: Text(user.statusText),
                        backgroundColor: user.isActive
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Contact info
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(user.username),
                  subtitle: Text('Username'),
                ),

                SizedBox(height: 16),

                // Roles
                Text('Roles', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: user.roles
                      .map(
                        (role) => Chip(
                          label: Text(role),
                          backgroundColor: Colors.blue.shade100,
                        ),
                      )
                      .toList(),
                ),

                SizedBox(height: 16),

                // Permissions
                Text(
                  'Permissions (${user.permissionCount})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                ...user.permissions.map(
                  (perm) => ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(perm),
                    dense: true,
                  ),
                ),

                SizedBox(height: 16),

                // Group access
                Text(
                  'Group Access',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Can Manage'),
                  trailing: Text('${user.manageGroupIds.length} groups'),
                ),
                ListTile(
                  leading: Icon(Icons.visibility),
                  title: Text('Can View'),
                  trailing: Text('${user.viewGroupIds.length} groups'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
