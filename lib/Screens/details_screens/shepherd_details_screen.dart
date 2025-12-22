import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/shepherds_provider.dart';
import '../../providers/auth_provider.dart';
import '../add_shepherds_screen.dart';

class ShepherdDetailsScreen extends StatelessWidget {
  final int shepherdId;

  const ShepherdDetailsScreen({super.key, required this.shepherdId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ShepherdsProvider, AuthProvider>(
      builder: (context, provider, authProvider, _) {
        final shepherd = provider.getShepherdById(shepherdId);

        if (shepherd == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(child: Text('Shepherd not found')),
          );
        }

        final canManage = provider.canManageShepherds(authProvider);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              '${shepherd.firstName} ${shepherd.lastName}',
              style: const TextStyle(
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
              if (canManage)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider.value(
                          value: provider,
                          child: AddShepherdsScreen(shepherd: shepherd),
                        ),
                      ),
                    );
                    // Refresh data if needed
                    if (result == true) {
                      // The provider data will automatically refresh through the provider
                    }
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: NetworkImage(shepherd.avatar),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        shepherd.firstName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          shepherd.lastName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Contact Information
                _buildSection('Contact Information', [
                  _buildInfoRow(Icons.email, 'Status', shepherd.civilStatus),
                  _buildInfoRow(
                    Icons.group_remove_outlined,
                    'Gender',
                    shepherd.gender,
                  ),
                  _buildInfoRow(
                    Icons.location_on,
                    'Address',
                    shepherd.placeOfWork ?? '',
                  ),
                ]),
                const SizedBox(height: 24),

                // Church Information
                // _buildSection('Church Information', [
                //   _buildInfoRow(
                //     Icons.church,
                //     'Church Location',
                //     shepherd.churchLocation,
                //   ),
                //   _buildInfoRow(Icons.work, 'Position', shepherd.position),
                //   _buildInfoRow(
                //     Icons.group,
                //     'Department',
                //     shepherd.department.isEmpty ? 'N/A' : shepherd.department,
                //   ),
                //   _buildInfoRow(
                //     Icons.calendar_today,
                //     'Years of Service',
                //     '${shepherd.yearsOfService} years',
                //   ),
                // ]),
                const SizedBox(height: 24),

                // Emergency Contact
                _buildSection('Emergency Contact', [
                  _buildInfoRow(Icons.emergency, 'Emergency Phone', ""),
                ]),
                const SizedBox(height: 32),

                // Action Buttons
                if (canManage)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                title: const Text(
                                  'Delete Shepherd',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete ${shepherd.firstName} ${shepherd.lastName}?',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey.shade600,
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete == true) {
                              final deleted = await provider.deleteShepherd(
                                shepherd.id.toString(),
                                authProvider: authProvider,
                              );
                              if (deleted && context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Shepherd deleted successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else if (!deleted && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Permission denied'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete Shepherd'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
}
