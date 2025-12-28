import 'package:flutter/material.dart';
import 'package:project_zoe/components/report_card.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../reports-screens/mc_attendance_report_screen.dart';
import '../reports-screens/garage_reports_display_screen.dart';
import '../reports-screens/salvation_reports_display_screen.dart';
import '../reports-screens/baptism_reports_display_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ReportProvider>().refreshReports();
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
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
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.church,
                          size: 32,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome to Project Zoe!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hello, ${_getFirstName(authProvider.user?.fullName ?? "User")}! Ready to make a difference?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Quick Actions Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Consumer<ReportProvider>(
              builder: (context, reportProvider, child) {
                final titleAndId = reportProvider.titleAndId;
                final isLoading = reportProvider.isLoading;

                if (isLoading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(
                        3,
                        (index) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
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
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.8,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildQuickActionsGrid(titleAndId, auth),
                );
              },
            ),
            const SizedBox(height: 24),

            // Dashboard Summary Section
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, child) {
                return _buildDashboardSummary(dashboardProvider);
              },
            ),

            // Bottom padding for navigation bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(
    List<Map<String, dynamic>> titleAndId,
    AuthProvider auth,
  ) {
    final List<Widget> cards = [];
    final mcAttendanceReportTitle = 'attendance';
    final sundayReportTitle = 'sunday';
    final salvationReportTitle = 'salvation';
    final baptismReportTitle = 'baptism';

    // Filter to show only MC, Sunday, Salvation, and Baptism reports
    final priorityReports = titleAndId.where((report) {
      final String title = report['title']?.toString().toLowerCase() ?? '';
      return title.contains(mcAttendanceReportTitle) ||
          title.contains(sundayReportTitle) ||
          title.contains(salvationReportTitle) ||
          title.contains(baptismReportTitle);
    }).toList();

    for (final report in priorityReports) {
      final String title = report['title']?.toString() ?? '';
      final dynamic id = report['id'];

      IconData icon = Icons.description;
      Widget? targetScreen;
      bool hasPermission = false;

      final lowerTitle = title.toLowerCase();

      // ---- Report routing logic with permission checks (same as reports screen) ----
      if (lowerTitle.contains(mcAttendanceReportTitle)) {
        icon = Icons.assignment;
        hasPermission = auth.isMcShepherdPermissions;
        if (hasPermission) {
          targetScreen = McAttendanceReportScreen(reportId: id);
        }
      } else if (lowerTitle.contains(sundayReportTitle)) {
        icon = Icons.church_outlined;
        hasPermission = auth.user?.canSubmitReports ?? false;
        if (hasPermission) {
          targetScreen = GarageReportsScreen(reportId: id);
        }
      } else if (lowerTitle.contains(salvationReportTitle)) {
        icon = Icons.favorite;
        hasPermission = auth.user?.canSubmitReports ?? false;
        if (hasPermission) {
          targetScreen = SalvationReportsScreen(reportId: id);
        }
      } else if (lowerTitle.contains(baptismReportTitle)) {
        icon = Icons.water_drop;
        hasPermission = auth.user?.canSubmitReports ?? false;
        if (hasPermission) {
          targetScreen = BaptismReportsScreen(reportId: id);
        }
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

    // Add \"More Reports\" card if needed to fill 3 slots or if there are more reports
    while (cards.length < 3) {
      cards.add(
        ReportCard(
          reportTitle: 'More Reports',
          reportIcon: Icons.more_horiz,
          iconColor: Colors.black,
          onTap: () {
            ReportProvider reportProvider = context.read<ReportProvider>();
            reportProvider.refreshReports();
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (_) => const ReportsScreen()),
            // );
          },
        ),
      );
    }

    // ---- Layout selection - always use Row for exactly 3 cards ----
    return Row(
      children: cards
          .take(3)
          .map(
            (card) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  height: 120, // Fixed height for home screen cards
                  child: card,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDashboardSummary(DashboardProvider dashboardProvider) {
    if (dashboardProvider.isLoading) {
      return Container(
        margin: const EdgeInsets.all(16),
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
        child: const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    if (dashboardProvider.hasError) {
      return Container(
        margin: const EdgeInsets.all(16),
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
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 8),
            Text(
              'Failed to load dashboard data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dashboardProvider.errorMessage ?? 'Unknown error',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => dashboardProvider.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (!dashboardProvider.hasData) {
      return const SizedBox.shrink();
    }

    final summary = dashboardProvider.dashboardSummary!;
    return Container(
      margin: const EdgeInsets.all(16),
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
          // Header with group info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.group, color: Colors.blue.shade700, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.group.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${summary.group.activeMembers}/${summary.group.memberCount} Active Members',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // This Week Stats
          Text(
            'This Week\'s Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildDashboardStatCard(
                  'Attendance',
                  summary.thisWeek.attendance.toString(),
                  Icons.people,
                  Colors.blue.shade600,
                  _getTrendIcon(summary.trend.attendanceChange),
                  _getTrendColor(summary.trend.attendanceChange),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDashboardStatCard(
                  'Visitors',
                  summary.thisWeek.visitors.toString(),
                  Icons.person_add,
                  Colors.green.shade600,
                  _getTrendIcon(summary.trend.visitorsChange),
                  _getTrendColor(summary.trend.visitorsChange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (summary.thisWeek.newMembers != null ||
              summary.thisWeek.salvations != null) ...[
            Row(
              children: [
                if (summary.thisWeek.newMembers != null)
                  Expanded(
                    child: _buildDashboardStatCard(
                      'New Members',
                      summary.thisWeek.newMembers.toString(),
                      Icons.group_add,
                      Colors.purple.shade600,
                      null,
                      null,
                    ),
                  ),
                if (summary.thisWeek.newMembers != null &&
                    summary.thisWeek.salvations != null)
                  const SizedBox(width: 12),
                if (summary.thisWeek.salvations != null)
                  Expanded(
                    child: _buildDashboardStatCard(
                      'Salvations',
                      summary.thisWeek.salvations.toString(),
                      Icons.favorite,
                      Colors.red.shade600,
                      null,
                      null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Recent Activity
          if (summary.recentActivity.isNotEmpty) ...[
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    _getActivityIcon(summary.recentActivity.first.type),
                    color: Colors.grey.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.recentActivity.first.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDashboardStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    IconData? trendIcon,
    Color? trendColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              if (trendIcon != null && trendColor != null)
                Icon(trendIcon, color: trendColor, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTrendIcon(int change) {
    if (change > 0) return Icons.trending_up;
    if (change < 0) return Icons.trending_down;
    return Icons.trending_flat;
  }

  Color _getTrendColor(int change) {
    if (change > 0) return Colors.green;
    if (change < 0) return Colors.red;
    return Colors.grey;
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'report_submitted':
        return Icons.assignment_turned_in;
      case 'member_added':
        return Icons.person_add;
      case 'meeting_held':
        return Icons.event;
      default:
        return Icons.info;
    }
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';

    final parts = fullName
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.first : 'User';
  }
}
