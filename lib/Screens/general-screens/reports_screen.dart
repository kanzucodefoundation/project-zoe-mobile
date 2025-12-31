import 'package:flutter/material.dart';
import '../../widgets/custom_toast.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../components/report_card.dart';
import '../reports-screens/mc_attendance_report_screen.dart';
import '../reports-screens/garage_reports_display_screen.dart';
import '../reports-screens/mc_reports_list_screen.dart';
import '../reports-screens/garage_reports_list_screen.dart';
import '../reports-screens/baptism_reports_list_screen.dart';
import '../reports-screens/salvation_reports_list_screen.dart';
import '../reports-screens/baptism_reports_display_screen.dart';
import '../reports-screens/salvation_reports_display_screen.dart';

/// Reports screen displaying all reports with server data
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> _reportCategories = [];
  bool _showAllReportTypes = false;
  bool _hasInitialized = false; // 🔥 ADD INITIALIZATION FLAG

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_hasInitialized) return; // 🔥 PREVENT MULTIPLE CALLS
    _hasInitialized = true;

    await _loadReportCategories();
  }

  // 🔥 ADD MANUAL REFRESH METHOD
  Future<void> _refreshData() async {
    _hasInitialized = false;
    await _loadInitialData();
  }

  Future<void> _loadReportCategories() async {
    if (!mounted) return; // 🔥 CHECK MOUNTED

    try {
      debugPrint('🔄 Starting to load report categories...');
      final categories = await ReportsService.getReportCategories();
      debugPrint('✅ Categories loaded successfully: $categories');

      if (mounted) {
        setState(() {
          _reportCategories = categories;
        });
        debugPrint(
          '🎯 State updated - categories count: ${_reportCategories.length}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading categories: $e');
      if (mounted) {
        // Error occurred while loading categories
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
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
                onPressed: () async {
                  await reportProvider.refreshReports();
                  await _refreshData(); // 🔥 USE NEW REFRESH METHOD
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await reportProvider.refreshReports();
              await _refreshData(); // 🔥 USE NEW REFRESH METHOD
            },
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // 🔥 ENSURE SCROLLABLE
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter Dropdown (commented out)
                  // _buildCategoryDropdown(),
                  // const SizedBox(height: 16),

                  // Report Types Section
                  _buildReportTypesSection(),

                  const SizedBox(height: 24),

                  // Submit Reports Section
                  _buildSubmitReportsSection(),

                  // const SizedBox(height: 16),

                  // Submitted Reports List (commented out)
                  // _buildSubmittedReportsSection(),
                  // const SizedBox(height: 16),

                  // MC Report Submissions Status (commented out)
                  // _buildMcSubmissionsSection(reportProvider),
                  // const SizedBox(height: 24),

                  // Small Groups Section
                  // _buildSmallGroupsSection(),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        );
      },
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
          // Show first 3 report types or all if _showAllReportTypes is true
          ...(_showAllReportTypes
              ? reportTypeWidgets
              : reportTypeWidgets.take(3).toList()),
          if (!_showAllReportTypes && reportTypeWidgets.length > 3) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _showAllReportTypes = true;
                    });
                  }
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
                  if (mounted) {
                    setState(() {
                      _showAllReportTypes = false;
                    });
                  }
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

    // Process all reports from server
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
          key: ValueKey('report_card_$id'), // 🔥 ADD KEY
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
                  ToastHelper.showWarning(
                    context,
                    'You do not have permission to access this report',
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
        childAspectRatio: 0.85,
      ),
      itemBuilder: (_, index) =>
          Padding(padding: const EdgeInsets.all(4), child: cards[index]),
    );
  }
}
