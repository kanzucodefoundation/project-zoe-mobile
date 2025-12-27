import 'package:flutter/material.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/group.dart';
import '../../components/report_card.dart';
import '../Reports screens/mc_attendance_report_screen.dart';
import '../Reports screens/garage_reports_display_screen.dart';
import '../Reports screens/mc_reports_list_screen.dart';
import '../Reports screens/garage_reports_list_screen.dart';
import '../Reports screens/baptism_reports_list_screen.dart';
import '../Reports screens/salvation_reports_list_screen.dart';
import '../details_screens/group_details_screen.dart';
import '../Reports screens/baptism_reports_display_screen.dart';
import '../Reports screens/salvation_reports_display_screen.dart';

/// Reports screen displaying all reports with server data
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> _reportCategories = [];
  GroupsResponse? _groupsResponse;
  bool _isLoadingCategories = true;
  bool _isLoadingGroups = true;
  bool _showAllGroups = false;
  bool _showAllReportTypes = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadReportCategories(), _loadSmallGroups()]);
  }

  Future<void> _loadReportCategories() async {
    try {
      debugPrint('🔄 Starting to load report categories...');
      // Let server determine church from authenticated user

      final categories = await ReportsService.getReportCategories();
      debugPrint('✅ Categories loaded successfully: $categories');
      setState(() {
        _reportCategories = categories;
        _isLoadingCategories = false;
      });
      debugPrint(
        '🎯 State updated - categories count: ${_reportCategories.length}',
      );
    } catch (e) {
      debugPrint('❌ Error loading categories: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadSmallGroups() async {
    try {
      debugPrint('🔄 Starting to load user groups...');
      // Let server determine church from authenticated user

      final groupsResponse = await ReportsService.getUserGroups();
      debugPrint(
        '✅ Groups loaded successfully: ${groupsResponse.groups.length} groups',
      );
      setState(() {
        _groupsResponse = groupsResponse;
        _isLoadingGroups = false;
      });
      debugPrint(
        '🎯 State updated - groups count: ${_groupsResponse!.groups.length}',
      );
    } catch (e) {
      debugPrint('❌ Error loading groups: $e');
      setState(() {
        _isLoadingGroups = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Reports',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black),
                onPressed: () {
                  reportProvider.refreshReports();
                  _loadInitialData();
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await reportProvider.refreshReports();
              await _loadInitialData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter Dropdown
                  _buildCategoryDropdown(),

                  const SizedBox(height: 16),

                  // Report Types Section
                  _buildReportTypesSection(),

                  const SizedBox(height: 24),

                  // Submit Reports Section
                  _buildSubmitReportsSection(),

                  const SizedBox(height: 16),

                  // Submitted Reports List
                  // _buildSubmittedReportsSection(),
                  const SizedBox(height: 16),

                  // MC Report Submissions Status
                  // _buildMcSubmissionsSection(reportProvider),
                  const SizedBox(height: 24),

                  // Small Groups Section
                  _buildSmallGroupsSection(),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoadingCategories)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Select a report category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              initialValue: _selectedCategory,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ..._reportCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text(category['name']),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSmallGroupsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Groups',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Groups you are part of',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (_groupsResponse != null && _groupsResponse!.groups.length > 5)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllGroups = !_showAllGroups;
                    });
                  },
                  child: Text(
                    _showAllGroups ? 'Show Less' : 'Show All',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoadingGroups)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_groupsResponse == null || _groupsResponse!.groups.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No groups found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else ...[
            // Display groups with limit
            ...(_showAllGroups
                    ? _groupsResponse!.groups
                    : _groupsResponse!.groups.take(5))
                .map((group) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.group,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        group.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.categoryName),
                          if (group.role != null)
                            Text(
                              'Role: ${group.role}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${group.activeMembers}/${group.memberCount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            'members',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 12),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupDetailsScreen(
                              groupId: group.id,
                              groupName: group.name,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

            // Summary info
            if (_groupsResponse!.summary.totalGroups > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${_groupsResponse!.summary.totalGroups}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text(
                          'Total Groups',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '${_groupsResponse!.summary.totalMembers}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text(
                          'Total Members',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildReportTypesSection() {
    final reportTypeWidgets = [
      _buildReportTypeCard(
        title: 'Submitted MC Reports',
        description: 'View all submitted MC report details',
        icon: Icons.assignment_turned_in,
        color: Colors.green,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const McReportsListScreen(),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      _buildReportTypeCard(
        title: 'Submitted Garage Reports',
        description: 'View all submitted garage report details',
        icon: Icons.assignment_turned_in,
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GarageReportsListScreen(),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      _buildReportTypeCard(
        title: 'Submitted Baptism Reports',
        description: 'View all submitted baptism report details',
        icon: Icons.assignment_turned_in,
        color: Colors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BaptismReportsListScreen(),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      _buildReportTypeCard(
        title: 'Submitted Salvation Reports',
        description: 'View all submitted salvation report details',
        icon: Icons.assignment_turned_in,
        color: Colors.green.shade700,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SalvationReportsListScreen(),
            ),
          );
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Submissions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Click on a report type to view submissions',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Show first 2 report types or all if _showAllReportTypes is true
          ...(_showAllReportTypes
              ? reportTypeWidgets
              : reportTypeWidgets.take(3).toList()),
          if (!_showAllReportTypes && reportTypeWidgets.length > 3) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAllReportTypes = true;
                  });
                },
                icon: const Icon(Icons.expand_more),
                label: const Text('Load More Report Types'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ] else if (_showAllReportTypes && reportTypeWidgets.length > 3) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAllReportTypes = false;
                  });
                },
                icon: const Icon(Icons.expand_less),
                label: const Text('Show Less'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportTypeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitReportsSection() {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap and submit your reports',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              _buildSubmitReportsGrid(reportProvider, authProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitReportsGrid(
    ReportProvider reportProvider,
    AuthProvider authProvider,
  ) {
    final List<Widget> cards = [];
    final titleAndId = reportProvider.titleAndId;

    final mcAttendanceReportTitle = 'attendance';
    final sundayReportTitle = 'sunday';
    final salvationReportTitle = 'salvation';
    final baptismReportTitle = 'baptism';

    // Process all reports from server (the original 5 that were on home screen)
    for (final report in titleAndId) {
      final String title = report['title']?.toString() ?? '';
      final dynamic id = report['id'];

      IconData icon = Icons.description;
      Widget? targetScreen;
      bool hasPermission = false;

      final lowerTitle = title.toLowerCase();

      // Set icons and navigation based on report type and check permissions
      if (lowerTitle.contains(mcAttendanceReportTitle)) {
        icon = Icons.assignment;
        hasPermission = authProvider.isMcShepherdPermissions;
        if (hasPermission) {
          targetScreen = McAttendanceReportScreen(reportId: id);
        }
      } else if (lowerTitle.contains(sundayReportTitle)) {
        icon = Icons.church_outlined;
        hasPermission = authProvider.user?.canSubmitReports ?? false;
        if (hasPermission) {
          targetScreen = GarageReportsScreen(reportId: id);
        }
      } else if (lowerTitle.contains(baptismReportTitle)) {
        icon = Icons.water_drop;
        hasPermission = authProvider.user?.canSubmitReports ?? false;
        if (hasPermission) {
          targetScreen = BaptismReportsScreen(reportId: id);
        }
      } else if (lowerTitle.contains(salvationReportTitle)) {
        icon = Icons.favorite;
        hasPermission = authProvider.user?.canSubmitReports ?? false;
        if (hasPermission) {
          targetScreen = SalvationReportsScreen(reportId: id);
        }
      } else if (lowerTitle.contains('prayer') ||
          lowerTitle.contains('follow')) {
        icon = Icons.pending_actions;
        hasPermission = authProvider.user?.canSubmitReports ?? false;
      }

      cards.add(
        ReportCard(
          reportTitle: title,
          reportIcon: icon,
          iconColor: hasPermission ? Colors.black : Colors.grey,
          backgroundColor: hasPermission ? Colors.white : Colors.grey.shade100,
          onTap: hasPermission
              ? (targetScreen != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => targetScreen!),
                        );
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$title coming soon'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      })
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'You do not have permission to access this report',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.85, // Taller cards to accommodate text
      ),
      itemBuilder: (_, index) =>
          Padding(padding: const EdgeInsets.all(4), child: cards[index]),
    );
  }
}
