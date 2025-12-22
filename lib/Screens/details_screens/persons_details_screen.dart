import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/people_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/people.dart';
import '../add_person_screen.dart';

class PersonsDetailsScreen extends StatefulWidget {
  final int shepherdId;

  const PersonsDetailsScreen({super.key, required this.shepherdId});

  @override
  State<PersonsDetailsScreen> createState() => _PersonsDetailsScreenState();
}

class _PersonsDetailsScreenState extends State<PersonsDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ContactDetails? _contactDetails;
  bool _isLoadingDetails = false;
  String? _errorMessage;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadContactDetails();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadContactDetails() async {
    // Double check mounted state and not disposed
    if (!mounted || _disposed) return;

    // Only set loading state if not already loading
    if (!_isLoadingDetails && mounted && !_disposed) {
      setState(() {
        _isLoadingDetails = true;
        _errorMessage = null;
      });
    }

    try {
      if (!mounted || _disposed) return;

      final provider = Provider.of<PeopleProvider>(context, listen: false);
      final details = await provider
          .loadContactDetails(widget.shepherdId)
          .timeout(const Duration(seconds: 15));

      // Check mounted and not disposed again after async operation
      if (mounted && !_disposed && details != null) {
        setState(() {
          _contactDetails = details;
          _isLoadingDetails = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      print('Error loading contact details: $e');
      // Only update state if widget is still mounted and not disposed
      if (mounted && !_disposed) {
        setState(() {
          _isLoadingDetails = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PeopleProvider, AuthProvider>(
      builder: (context, provider, authProvider, _) {
        try {
          final contact = provider.getShepherdById(widget.shepherdId);

          if (contact == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Contact not found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Person Details',
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    provider.loadShepherdForEdit(contact);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddPeopleScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: contact.avatar.isNotEmpty
                                ? NetworkImage(contact.avatar)
                                : null,
                            child: contact.avatar.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          contact.name.isNotEmpty ? contact.name : 'No Name',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Email
                        if (contact.email.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              contact.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(icon: Icon(Icons.person), text: 'Summary'),
                        Tab(icon: Icon(Icons.groups), text: 'Groups'),
                      ],
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                    ),
                  ),

                  // Tab Content
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [_buildSummaryTab(contact), _buildGroupsTab()],
                    ),
                  ),
                ],
              ),
            ),
          );
        } catch (e) {
          // Fallback UI if there's any error
          print('Error in PersonsDetailsScreen build: $e');
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Contact Details',
                style: TextStyle(color: Colors.black),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading contact details',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${e.toString()}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildSummaryTab(Contact contact) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Age Group',
                  contact.ageGroup ?? 'N/A',
                  Icons.group,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Group(s)',
                  _getGroupDisplayText(),
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Detailed Information Section
          if (_isLoadingDetails)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(height: 16),
                    Text('Loading additional details...'),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade600),
                  const SizedBox(height: 8),
                  Text(
                    'Could not load additional details',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Showing basic information only',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loadContactDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_contactDetails != null) ...[
            // Personal Details
            _buildDetailSection(
              title: 'Personal Information',
              icon: Icons.person,
              color: Colors.purple,
              children: [
                if (_contactDetails!.person.gender?.isNotEmpty ?? false)
                  _buildDetailRow(
                    'Gender',
                    _contactDetails!.person.gender!,
                    Icons.person_outline,
                  ),
                if (_contactDetails!.person.civilStatus?.isNotEmpty ?? false)
                  _buildDetailRow(
                    'Marital Status',
                    _contactDetails!.person.civilStatus!,
                    Icons.favorite,
                  ),
                if (_contactDetails!.person.dateOfBirth.isNotEmpty)
                  _buildDetailRow(
                    'Date of Birth',
                    _contactDetails!.person.dateOfBirth,
                    Icons.cake,
                  ),
                if (_contactDetails!.person.placeOfWork?.isNotEmpty ?? false)
                  _buildDetailRow(
                    'Place of Work',
                    _contactDetails!.person.placeOfWork!,
                    Icons.work,
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact Information
            _buildContactSection(),
          ] else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No additional details available'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoadingDetails)
            Container(
              padding: const EdgeInsets.all(40),
              child: const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(height: 16),
                    Text('Loading group information...'),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade600),
                    const SizedBox(height: 8),
                    Text(
                      'Could not load group information',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loadContactDetails,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_contactDetails?.groupMemberships.isNotEmpty ?? false) ...[
            Text(
              'Group Memberships (${_contactDetails!.groupMemberships.length})',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_contactDetails!.groupMemberships.map(
              (membership) => _buildGroupCard(membership),
            )),
          ] else
            Container(
              padding: const EdgeInsets.all(40),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.group_off, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No group memberships found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getGroupDisplayText() {
    if (_isLoadingDetails) {
      return 'Loading...';
    }

    if (_contactDetails?.groupMemberships.isNotEmpty ?? false) {
      final groups = _contactDetails!.groupMemberships;
      if (groups.length == 1) {
        return groups.first.group.name;
      } else {
        return '${groups.length} groups';
      }
    }

    // Fallback to contact.cellGroup if no detailed data is available
    final contact = Provider.of<PeopleProvider>(
      context,
      listen: false,
    ).getShepherdById(widget.shepherdId);
    return contact?.cellGroup ?? 'None';
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    if (_contactDetails == null) return const SizedBox.shrink();

    return _buildDetailSection(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      color: Colors.teal,
      children: [
        // Emails
        if (_contactDetails!.emails.isNotEmpty) ...[
          ...(_contactDetails!.emails.map(
            (email) => _buildContactRow(
              email.category,
              email.value,
              Icons.email,
              email.isPrimary,
            ),
          )),
          const SizedBox(height: 8),
        ],

        // Phone Numbers
        if (_contactDetails!.phones.isNotEmpty) ...[
          ...(_contactDetails!.phones.map(
            (phone) => _buildContactRow(
              phone.category,
              phone.value,
              Icons.phone,
              phone.isPrimary,
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildContactRow(
    String category,
    String value,
    IconData icon,
    bool isPrimary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Primary',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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

  Widget _buildGroupCard(GroupMembership membership) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Group Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                membership.group.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Group Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membership.group.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    membership.role,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ),
                if (membership.group.details?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(
                    membership.group.details!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
