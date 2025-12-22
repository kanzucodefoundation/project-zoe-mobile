import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/long_button.dart';
import '../providers/shepherds_provider.dart';
import '../providers/auth_provider.dart';
import '../tiles/shepherds_tile.dart';
import 'add_shepherds_screen.dart';
import 'details_screens/shepherd_details_screen.dart';

class ShepherdsScreen extends StatelessWidget {
  const ShepherdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShepherdsProvider(),
      child: Consumer2<ShepherdsProvider, AuthProvider>(
        builder: (context, provider, authProvider, _) {
          final canManage = provider.canManageShepherds(authProvider);
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Shepherds',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              // leading: IconButton(
              //   icon: const Icon(Icons.arrow_back, color: Colors.black),
              //   onPressed: () => Navigator.pop(context),
              // ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await provider.loadShepherds();
              },
              child: Column(
                children: [
                  // Header Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Church Shepherds',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage and view all church shepherds information',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Add Shepherd Button
                        if (canManage)
                          LongButton(
                            text: 'Add New Shepherd',
                            onPressed: () {
                              // Clear provider state to ensure add mode
                              provider.clear();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider.value(
                                        value: provider,
                                        child: const AddShepherdsScreen(),
                                      ),
                                ),
                              ).then((_) {
                                // Refresh the list when returning from add screen
                                provider.loadShepherds();
                              });
                            },
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.grey.shade600),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Only administrators can add new shepherds',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Shepherds Count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.group,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${provider.shepherds.length} Shepherds',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shepherds List
                  Expanded(
                    child: provider.isLoadingShepherds
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          )
                        : provider.shepherds.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.group_off,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Shepherds Found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add shepherds to get started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: provider.shepherds.length,
                            itemBuilder: (context, index) {
                              final shepherd = provider.shepherds[index];
                              return ShepherdsTile(
                                shepherdAvatar: shepherd.avatar,
                                shepherdName:
                                    '${shepherd.firstName} ${shepherd.lastName}',
                                shepherdEmail: "email",
                                buttonText: 'View',
                                onButtonPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider.value(
                                            value: provider,
                                            child: ShepherdDetailsScreen(
                                              shepherdId: shepherd.id,
                                            ),
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
