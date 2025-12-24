import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/long_button.dart';
import '../providers/contacts_provider.dart';
import '../providers/auth_provider.dart';
import '../tiles/shepherds_tile.dart';
import 'add_person_screen.dart';
import 'details_screens/persons_details_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

// Backward compatibility alias
typedef PeopleScreen = ContactsScreen;

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = ContactsProvider();
        // Load contacts with church name from auth provider after creation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final churchName = authProvider.user?.churchName ?? 'fellowship';
          provider.loadContacts(churchName: churchName);
        });
        return provider;
      },
      child: Consumer2<ContactsProvider, AuthProvider>(
        builder: (context, provider, authProvider, _) {
          final canManage = provider.canManageShepherds(authProvider);
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Contacts',
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
                final churchName =
                    authProvider.user?.churchName ?? 'fellowship';
                await provider.loadContacts(churchName: churchName);
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
                          'Contacts',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage and view all church contacts information',
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
                            text: 'Add a contact',
                            onPressed: () {
                              // Clear provider state to ensure add mode
                              provider.clear();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider.value(
                                        value: provider,
                                        child: const AddPeopleScreen(),
                                      ),
                                ),
                              ).then((_) {
                                // Refresh the list when returning from add screen
                                final churchName =
                                    authProvider.user?.churchName ??
                                    'fellowship';
                                provider.loadContacts(churchName: churchName);
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
                                    'Only administrators can add new contacts',
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
                          '${provider.shepherds.length} Contacts',
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
                                  'No Contacts Found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add contacts to get started',
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
                              final contact = provider.shepherds[index];
                              return ShepherdsTile(
                                shepherdAvatar: contact.avatar,
                                shepherdName: contact.name,
                                shepherdEmail: contact.email,
                                buttonText: 'View',
                                onButtonPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider.value(
                                            value: provider,
                                            child: PersonsDetailsScreen(
                                              shepherdId: contact.id,
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
