import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/contacts_provider.dart';
import '../../providers/auth_provider.dart';
import '../../tiles/contact_tile.dart';
import '../details_screens/contact_details_screen.dart';
import 'add_contact_screen.dart';

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
          // Role management commented out for now - will be implemented later
          // final canManage = true; // Simplify for now

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
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                final churchName =
                    authProvider.user?.churchName ?? 'fellowship';
                await provider.refreshContacts(churchName: churchName);
              },
              child: CustomScrollView(
                slivers: [
                  // Header Section
                  SliverToBoxAdapter(
                    child: Padding(
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
                            'Manage and view church contacts',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Add Contact Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddPeopleScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.person_add_outlined,
                                size: 20,
                              ),
                              label: const Text(
                                'Add Contact',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Contacts Count
                          Text(
                            'Contacts (${provider.contacts.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Contacts List
                  provider.isLoading
                      ? const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.error != null
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error Loading Contacts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  provider.error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    final churchName =
                                        authProvider.user?.churchName ??
                                        'fellowship';
                                    provider.loadContacts(
                                      churchName: churchName,
                                    );
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : provider.contacts.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'No contacts found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final contact = provider.contacts[index];
                            

                            return ContactTile(
                              shepherdName: contact.name,
                              shepherdEmail: contact.email ?? 'No email',
                              shepherdAvatar: contact.avatar ?? '',
                              buttonText: 'View',
                              onButtonPressed: () {
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChangeNotifierProvider.value(
                                          value: provider,
                                          child: ContactDetailsScreen(
                                            contactId: contact.id,
                                          ),
                                        ),
                                  ),
                                );
                              },
                            );
                          }, childCount: provider.contacts.length),
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
