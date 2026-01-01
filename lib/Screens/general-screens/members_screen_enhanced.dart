import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/contacts.dart';
import '../details_screens/contact_details_screen.dart';
import 'add_contact_screen.dart';
import '../../widgets/custom_toast.dart';

/// Enhanced Members screen using Project Zoe Design System
class EnhancedMembersScreen extends StatefulWidget {
  const EnhancedMembersScreen({super.key});

  @override
  State<EnhancedMembersScreen> createState() => _EnhancedMembersScreenState();
}

class _EnhancedMembersScreenState extends State<EnhancedMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = ContactsProvider();
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
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: _buildAppBar(provider, authProvider),
            body: _buildBody(provider, authProvider),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ContactsProvider provider,
    AuthProvider authProvider,
  ) {
    return AppBar(
      backgroundColor: AppColors.scaffoldBackground,
      elevation: 0,
      title: _isSearching
          ? ZoeSearchInput(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              hint: 'Search members...',
            )
          : Text(
              'Members',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primaryText,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: AppColors.primaryText,
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildBody(ContactsProvider provider, AuthProvider authProvider) {
    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        final churchName = authProvider.user?.churchName ?? 'fellowship';
        await provider.loadContacts(churchName: churchName);
      },
      child: Column(
        children: [
          // Header with stats and add button
          _buildHeader(provider, authProvider),
          
          // Members list
          Expanded(child: _buildMembersList(provider)),
        ],
      ),
    );
  }

  Widget _buildHeader(ContactsProvider provider, AuthProvider authProvider) {
    final contacts = _searchQuery.isEmpty 
        ? provider.contacts 
        : provider.contacts.where((contact) => 
            contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (contact.phone?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (contact.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
          ).toList();
        
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          // Stats Card
          ZoeCard(
            child: Row(
              children: [
                // Member Count Stat
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people,
                        color: AppColors.primaryGreen,
                        size: AppSpacing.iconLg,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${contacts.length}',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Total Members',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                
                // Divider
                Container(
                  height: 40,
                  width: 1,
                  color: AppColors.softBorders,
                ),
                
                // Active Members Stat (placeholder)
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: AppSpacing.iconLg,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${(contacts.length * 0.85).round()}',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Active',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                
                // Divider
                Container(
                  height: 40,
                  width: 1,
                  color: AppColors.softBorders,
                ),
                
                // New Members This Month (placeholder)
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add,
                        color: AppColors.harvestGold,
                        size: AppSpacing.iconLg,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '3',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'New',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Add Member Button
          ZoeButton.primary(
            label: 'Add Member',
            width: double.infinity,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddContactScreen(),
                ),
              );

              // Refresh members list if a member was created successfully
              if (result == true) {
                final churchName = authProvider.user?.churchName ?? 'fellowship';
                await provider.loadContacts(churchName: churchName);
                if (mounted) {
                  ToastHelper.showInfo(context, 'Member added successfully!');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(ContactsProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingList();
    }

    if (provider.error != null) {
      return _buildErrorState(provider);
    }

    final contacts = _searchQuery.isEmpty 
        ? provider.contacts 
        : provider.contacts.where((contact) => 
            contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (contact.phone?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (contact.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
          ).toList();

    if (contacts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      itemCount: contacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return _buildMemberCard(contact);
      },
    );
  }

  Widget _buildMemberCard(Contact contact) {
    return ZoeCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactDetailsScreen(contactId: contact.id),
          ),
        );
      },
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppColors.primaryGreen,
              size: AppSpacing.iconMd,
            ),
          ),
          
          const SizedBox(width: AppSpacing.lg),
          
          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (contact.phone?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: AppSpacing.iconSm,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        contact.phone!,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                if (contact.email?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: AppSpacing.iconSm,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        contact.email!,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Status indicator and arrow
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.success, // Assuming all active for now
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Icon(
                Icons.arrow_forward_ios,
                size: AppSpacing.iconSm,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => ZoeCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.softBorders,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: AppColors.softBorders,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    height: 12,
                    width: 120,
                    color: AppColors.softBorders,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ContactsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: ZoeCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: AppSpacing.iconXxl,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Unable to load members',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                provider.error ?? 'Something went wrong. Please try again.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ZoeButton.secondary(
                label: 'Retry',
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final churchName = authProvider.user?.churchName ?? 'fellowship';
                  await provider.loadContacts(churchName: churchName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: ZoeCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: AppSpacing.iconXxl,
                color: AppColors.secondaryText,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _searchQuery.isNotEmpty ? 'No members found' : 'No members yet',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try adjusting your search terms'
                    : 'Start building your fellowship by adding members',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                ZoeButton.primary(
                  label: 'Add First Member',
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddContactScreen(),
                      ),
                    );

                    if (result == true) {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final provider = Provider.of<ContactsProvider>(
                        context,
                        listen: false,
                      );
                      final churchName = authProvider.user?.churchName ?? 'fellowship';
                      await provider.loadContacts(churchName: churchName);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}