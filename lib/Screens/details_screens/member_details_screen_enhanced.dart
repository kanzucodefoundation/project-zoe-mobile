import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/contacts.dart';
import '../../widgets/custom_toast.dart';
import '../general-screens/add_contact_screen.dart';

/// Enhanced Member Details Screen using Project Zoe Design System
class EnhancedMemberDetailsScreen extends StatefulWidget {
  final int contactId;

  const EnhancedMemberDetailsScreen({super.key, required this.contactId});

  @override
  State<EnhancedMemberDetailsScreen> createState() => _EnhancedMemberDetailsScreenState();
}

class _EnhancedMemberDetailsScreenState extends State<EnhancedMemberDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final churchName = authProvider.user?.churchName ?? 'fellowship';
      context.read<ContactsProvider>().loadContactDetails(
        widget.contactId,
        churchName: churchName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Consumer<ContactsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          final contactDetails = provider.currentContactDetails;
          if (contactDetails == null) {
            return _buildNotFoundState();
          }

          return _buildContactDetails(contactDetails);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Loading...', style: AppTextStyles.h2),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              strokeWidth: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Loading member details...',
              style: AppTextStyles.body.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ContactsProvider provider) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Error', style: AppTextStyles.h2),
      ),
      body: Center(
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
                  'Unable to load member',
                  style: AppTextStyles.h3.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  provider.error!,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ZoeButton.secondary(
                  label: 'Retry',
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final churchName = authProvider.user?.churchName ?? 'fellowship';
                    provider.loadContactDetails(
                      widget.contactId,
                      churchName: churchName,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Not Found', style: AppTextStyles.h2),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: ZoeCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_off,
                  size: AppSpacing.iconXxl,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Member not found',
                  style: AppTextStyles.h3.copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This member may have been removed or you may not have permission to view them.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactDetails(ContactDetails contactDetails) {
    final person = contactDetails.person;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Member Details', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primaryText),
            onPressed: () => _editMember(person),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(person),
            
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Personal Information
            _buildPersonalInfoSection(person),
            
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Contact Information
            _buildContactInfoSection(contactDetails),
            
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Group Information
            if (contactDetails.groupMemberships.isNotEmpty)
              _buildGroupInfoSection(contactDetails),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ContactPerson person) {
    final fullName = '${person.firstName} ${person.lastName}';
    
    return ZoeCard(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: person.avatar?.isNotEmpty == true
                ? ClipOval(
                    child: Image.network(
                      person.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: AppSpacing.iconXl + 10,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: AppSpacing.iconXl + 10,
                    color: AppColors.primaryGreen,
                  ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Name
          Text(
            fullName,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Active Member',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(ContactPerson person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppSpacing.md),
        ZoeCard(
          child: Column(
            children: [
              if (person.gender?.isNotEmpty == true)
                _buildInfoRow('Gender', person.gender!),
              
              if (person.ageGroup?.isNotEmpty == true) ...[
                if (person.gender?.isNotEmpty == true) _buildDivider(),
                _buildInfoRow('Age Group', person.ageGroup!),
              ],
              
              if (person.dateOfBirth?.isNotEmpty == true) ...[
                if (person.gender?.isNotEmpty == true || person.ageGroup?.isNotEmpty == true) 
                  _buildDivider(),
                _buildInfoRow('Date of Birth', _formatDate(person.dateOfBirth!)),
              ],
              
              if (person.civilStatus?.isNotEmpty == true) ...[
                if (person.gender?.isNotEmpty == true || 
                    person.ageGroup?.isNotEmpty == true || 
                    person.dateOfBirth?.isNotEmpty == true) 
                  _buildDivider(),
                _buildInfoRow('Civil Status', person.civilStatus!),
              ],
              
              if (person.placeOfWork?.isNotEmpty == true) ...[
                if (person.gender?.isNotEmpty == true || 
                    person.ageGroup?.isNotEmpty == true || 
                    person.dateOfBirth?.isNotEmpty == true ||
                    person.civilStatus?.isNotEmpty == true) 
                  _buildDivider(),
                _buildInfoRow('Place of Work', person.placeOfWork!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection(ContactDetails contactDetails) {
    final hasPhones = contactDetails.phones.isNotEmpty;
    final hasEmails = contactDetails.emails.isNotEmpty;
    final hasAddresses = contactDetails.addresses.isNotEmpty;
    
    if (!hasPhones && !hasEmails && !hasAddresses) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppSpacing.md),
        ZoeCard(
          child: Column(
            children: [
              if (hasPhones)
                ...contactDetails.phones.asMap().entries.map((entry) {
                  final index = entry.key;
                  final phone = entry.value;
                  return Column(
                    children: [
                      if (index > 0) _buildDivider(),
                      _buildContactRow(
                        Icons.phone,
                        'Phone',
                        phone.value,
                        AppColors.primaryGreen,
                      ),
                    ],
                  );
                }),
              
              if (hasEmails) ...[
                if (hasPhones) _buildDivider(),
                ...contactDetails.emails.asMap().entries.map((entry) {
                  final index = entry.key;
                  final email = entry.value;
                  return Column(
                    children: [
                      if (index > 0) _buildDivider(),
                      _buildContactRow(
                        Icons.email,
                        'Email',
                        email.value,
                        AppColors.primaryGreen,
                      ),
                    ],
                  );
                }),
              ],
              
              if (hasAddresses) ...[
                if (hasPhones || hasEmails) _buildDivider(),
                ...contactDetails.addresses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final address = entry.value;
                  return Column(
                    children: [
                      if (index > 0) _buildDivider(),
                      _buildContactRow(
                        Icons.location_on,
                        'Address',
                        address.freeForm ?? '${address.district ?? ''}, ${address.country ?? ''}',
                        AppColors.primaryGreen,
                      ),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupInfoSection(ContactDetails contactDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fellowship Groups',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppSpacing.md),
        ZoeCard(
          child: Column(
            children: contactDetails.groupMemberships.asMap().entries.map((entry) {
              final index = entry.key;
              final membership = entry.value;
              return Column(
                children: [
                  if (index > 0) _buildDivider(),
                  _buildContactRow(
                    Icons.groups,
                    'Fellowship',
                    '${membership.group.name} (${membership.role})',
                    AppColors.harvestGold,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          child: Icon(
            icon,
            size: AppSpacing.iconSm,
            color: iconColor,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption,
              ),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Divider(
        height: 1,
        color: AppColors.softBorders,
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _editMember(ContactPerson person) async {
    // Convert ContactPerson to Contact for editing
    final contact = Contact(
      id: person.id,
      name: '${person.firstName} ${person.lastName}',
      firstName: person.firstName,
      lastName: person.lastName,
      avatar: person.avatar,
      email: null, // Will be populated from contact details
      phone: null, // Will be populated from contact details
      ageGroup: person.ageGroup,
      gender: person.gender,
      dateOfBirth: person.dateOfBirth,
      isActive: true, // Default to active since ContactPerson doesn't have isActive
      primaryGroup: null, // Will be populated from contact details
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactScreen(editingContact: contact),
      ),
    );

    if (result == true) {
      // Refresh member details
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final churchName = authProvider.user?.churchName ?? 'fellowship';
        context.read<ContactsProvider>().loadContactDetails(
          widget.contactId,
          churchName: churchName,
        );
        ToastHelper.showInfo(context, 'Member updated successfully');
      }
    }
  }
}