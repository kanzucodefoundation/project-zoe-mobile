import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_provider.dart';
import '../../models/contacts.dart';

class ContactDetailsScreen extends StatefulWidget {
  final int contactId;

  const ContactDetailsScreen({super.key, required this.contactId});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Comment out debug print for production
    // print(
    //   '🚀 ContactDetailsScreen: Initializing with contactId: ${widget.contactId}',
    // );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsProvider>().loadContactDetails(widget.contactId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Contact Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
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
                    'Loading contact details...',
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
                padding: const EdgeInsets.all(16.0),
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
                      'Unable to load contact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          provider.loadContactDetails(widget.contactId),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final contact = provider.currentContactDetails;
          if (contact == null) {
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
                    'Contact not found',
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
              children: [
                // Header Section with Avatar and Basic Info
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                  child: Column(
                    children: [
                      // Avatar
                      _buildAvatar(contact),
                      const SizedBox(height: 24),

                      // Name
                      Text(
                        '${contact.person.firstName} ${contact.person.lastName}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Primary Email
                      if (contact.emails.isNotEmpty) ...[
                        Text(
                          contact.emails.first.value,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Status Tags
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (contact.person.gender != null)
                            _buildTag(
                              contact.person.gender!,
                              Icons.person,
                              Colors.blue,
                            ),
                          if (contact.person.ageGroup != null)
                            _buildTag(
                              contact.person.ageGroup!,
                              Icons.cake,
                              Colors.green,
                            ),
                          if (contact.groupMemberships.isNotEmpty)
                            _buildTag(
                              contact.groupMemberships.first.role,
                              Icons.group,
                              Colors.orange,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Contact Information
                _buildSection('Contact Information', [
                  if (contact.phones.isNotEmpty) ...[
                    for (final phone in contact.phones)
                      _buildContactItem(
                        icon: Icons.phone_rounded,
                        iconColor: Colors.green,
                        title: phone.category,
                        subtitle: phone.value,
                        isPrimary: phone.isPrimary,
                      ),
                  ],
                  if (contact.emails.isNotEmpty) ...[
                    for (final email in contact.emails)
                      _buildContactItem(
                        icon: Icons.email_rounded,
                        iconColor: Colors.blue,
                        title: email.category,
                        subtitle: email.value,
                        isPrimary: email.isPrimary,
                      ),
                  ],
                  if (contact.addresses.isNotEmpty) ...[
                    for (final address in contact.addresses)
                      _buildContactItem(
                        icon: Icons.location_on_rounded,
                        iconColor: Colors.red,
                        title: address.category,
                        subtitle:
                            address.freeForm ??
                            '${address.district ?? ''}, ${address.country ?? ''}',
                        isPrimary: address.isPrimary,
                      ),
                  ],
                ]),

                // Personal Information
                _buildSection('Personal Information', [
                  if (contact.person.dateOfBirth != null)
                    _buildInfoItem(
                      'Date of Birth',
                      contact.person.dateOfBirth!,
                      Icons.cake_rounded,
                    ),
                  if (contact.person.civilStatus != null)
                    _buildInfoItem(
                      'Civil Status',
                      contact.person.civilStatus!,
                      Icons.favorite_rounded,
                    ),
                  if (contact.person.placeOfWork != null)
                    _buildInfoItem(
                      'Place of Work',
                      contact.person.placeOfWork!,
                      Icons.work_rounded,
                    ),
                ]),

                // Group Memberships
                if (contact.groupMemberships.isNotEmpty)
                  _buildSection('Group Memberships', [
                    for (final membership in contact.groupMemberships)
                      _buildGroupItem(membership),
                  ]),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(ContactDetails contact) {
    final avatarUrl = contact.person.avatar;
    // Comment out debug print for production
    // print('🖼️ Building avatar with URL: $avatarUrl');

    // Get first letters for fallback avatar
    String getInitials() {
      final firstName = contact.person.firstName;
      final lastName = contact.person.lastName;
      if (firstName.isEmpty && lastName.isEmpty) return '?';
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '${firstName[0]}${lastName[0]}'.toUpperCase();
      }
      return (firstName.isNotEmpty ? firstName[0] : lastName[0]).toUpperCase();
    }

    // Get different colors based on name hash
    MaterialColor getAvatarColor() {
      final name = '${contact.person.firstName} ${contact.person.lastName}';
      final colors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
        Colors.red,
        Colors.indigo,
        Colors.pink,
      ];
      final hash = name.hashCode;
      return colors[hash.abs() % colors.length];
    }

    return Hero(
      tag: 'avatar_${contact.person.id}',
      child: Container(
        width: 140,
        height: 140,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: avatarUrl != null && avatarUrl.isNotEmpty
              ? Image.network(
                  avatarUrl,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    // Comment out debug prints for production
                    // print(
                    //   '🔄 Avatar loading progress: $loadingProgress for URL: $avatarUrl',
                    // );
                    if (loadingProgress == null) {
                      // Comment out debug print for production
                      return child;
                    }
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Comment out debug prints for production
                    // print('❌ Avatar failed to load: $error');
                    // print('🔗 Failed URL: $avatarUrl');
                    // print('📋 Stack trace: $stackTrace');

                    // Return first letter avatar on error
                    final avatarColor = getAvatarColor();
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: avatarColor.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          getInitials(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: avatarColor.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: getAvatarColor().shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      getInitials(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: getAvatarColor().shade700,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Text(
                          'Primary',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupItem(GroupMembership membership) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.group_rounded,
              color: Colors.blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membership.group.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        membership.role,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (membership.group.categoryName.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${membership.group.categoryName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clear contact details when leaving the screen
    context.read<ContactsProvider>().clearContactDetails();
    super.dispose();
  }
}
