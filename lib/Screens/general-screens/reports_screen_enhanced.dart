import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../widgets/custom_toast.dart';
import '../../services/reports_service.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../reports-screens/mc_attendance_report_screen.dart';
import '../reports-screens/garage_reports_display_screen.dart';
import '../reports-screens/mc_reports_list_screen.dart';
import '../reports-screens/garage_reports_list_screen.dart';
import '../reports-screens/baptism_reports_list_screen.dart';
import '../reports-screens/salvation_reports_list_screen.dart';
import '../reports-screens/baptism_reports_display_screen.dart';
import '../reports-screens/salvation_reports_display_screen.dart';

/// Enhanced Reports screen using Project Zoe Design System
class EnhancedReportsScreen extends StatefulWidget {
  const EnhancedReportsScreen({super.key});

  @override
  State<EnhancedReportsScreen> createState() => _EnhancedReportsScreenState();
}

class _EnhancedReportsScreenState extends State<EnhancedReportsScreen> {
  List<Map<String, dynamic>> _reportCategories = [];
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_hasInitialized) return;
    _hasInitialized = true;
    await _loadReportCategories();
  }

  Future<void> _refreshData() async {
    _hasInitialized = false;
    await _loadInitialData();
  }

  Future<void> _loadReportCategories() async {
    if (!mounted) return;

    try {
      final categories = await ReportsService.getReportCategories();
      if (mounted) {
        setState(() {
          _reportCategories = categories;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Failed to load report categories');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBackground,
            elevation: 0,
            title: Text(
              'Reports',
              style: AppTextStyles.h2,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.primaryText,
                ),
                onPressed: () async {
                  await reportProvider.refreshReports();
                  await _refreshData();
                  if (mounted) {
                    ToastHelper.showInfo(context, 'Reports refreshed');
                  }
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () async {
              await reportProvider.refreshReports();
              await _refreshData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Submit Reports Section
                  _buildSubmitReportsSection(),
                  
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // View Submissions Section
                  _buildViewSubmissionsSection(),
                  
                  const SizedBox(height: AppSpacing.xxxl * 3), // Space for bottom nav
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitReportsSection() {
    return Consumer2<ReportProvider, AuthProvider>(
      builder: (context, reportProvider, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submit Reports',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Submit your weekly reports and updates',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSubmitReportsGrid(reportProvider, authProvider),
          ],
        );
      },
    );
  }

  Widget _buildSubmitReportsGrid(
    ReportProvider reportProvider,
    AuthProvider authProvider,
  ) {
    if (reportProvider.isLoading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6, // Show 6 loading cards
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (_, index) => ZoeCard(
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
        ),
      );
    }

    final titleAndId = reportProvider.titleAndId;
    final List<_ReportItem> reportItems = [];

    // Process reports and create enhanced items
    for (final report in titleAndId) {
      final String title = report['title']?.toString() ?? '';
      final dynamic id = report['id'];
      final lowerTitle = title.toLowerCase();

      IconData icon = Icons.description;
      Color iconColor = AppColors.primaryText;
      Widget? targetScreen;
      bool hasPermission = false;
      String description = 'Tap to submit';
      ReportStatus status = ReportStatus.available;

      // Enhanced categorization with brand colors
      if (lowerTitle.contains('attendance')) {
        icon = Icons.people;
        hasPermission = authProvider.isMcShepherdPermissions;
        description = 'Fellowship attendance report';
        iconColor = AppColors.primaryGreen;
        if (hasPermission) {
          targetScreen = McAttendanceReportScreen(reportId: id);
        }
      } else if (lowerTitle.contains('sunday')) {
        icon = Icons.church;
        hasPermission = authProvider.user?.canSubmitReports ?? false;
        description = 'Sunday service report';
        iconColor = AppColors.primaryGreen;
        if (hasPermission) {
          targetScreen = GarageReportsScreen(reportId: id);
        }
      } else if (lowerTitle.contains('baptism')) {
        icon = Icons.water_drop;
        hasPermission = authProvider.user?.canSubmitReports ?? false;
        description = 'Baptism celebration';
        iconColor = AppColors.harvestGold;
        if (hasPermission) {
          targetScreen = BaptismReportsScreen(reportId: id);
        }
      } else if (lowerTitle.contains('salvation')) {
        icon = Icons.favorite;
        hasPermission = authProvider.user?.canSubmitReports ?? false;
        description = 'Salvation testimony';
        iconColor = AppColors.harvestGold;
        if (hasPermission) {
          targetScreen = SalvationReportsScreen(reportId: id);
        }
      }

      if (!hasPermission) {
        status = ReportStatus.noPermission;
        iconColor = AppColors.secondaryText;
        description = 'No permission';
      }

      reportItems.add(_ReportItem(
        title: title,
        description: description,
        icon: icon,
        iconColor: iconColor,
        status: status,
        onTap: hasPermission
            ? (targetScreen != null
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => targetScreen!),
                      )
                  : () => ToastHelper.showInfo(context, '$title coming soon'))
            : () => ToastHelper.showWarning(
                  context,
                  'You do not have permission to access this report',
                ),
      ));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reportItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, index) => _buildReportCard(reportItems[index]),
    );
  }

  Widget _buildReportCard(_ReportItem item) {
    return ZoeCard(
      onTap: item.onTap,
      backgroundColor: item.status == ReportStatus.noPermission
          ? AppColors.softBorders.withOpacity(0.3)
          : AppColors.cardBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: item.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Icon(
              item.icon,
              size: AppSpacing.iconLg,
              color: item.iconColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.title,
            style: AppTextStyles.label.copyWith(
              color: item.status == ReportStatus.noPermission
                  ? AppColors.secondaryText
                  : AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.description,
            style: AppTextStyles.caption.copyWith(
              color: item.status == ReportStatus.noPermission
                  ? AppColors.secondaryText
                  : AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.status == ReportStatus.submitted) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Text(
                'Submitted',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewSubmissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'View Submissions',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Review submitted reports from your team',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSubmissionsList(),
      ],
    );
  }

  Widget _buildSubmissionsList() {
    final List<_SubmissionItem> submissions = [
      _SubmissionItem(
        title: 'Fellowship Attendance',
        description: 'View all fellowship reports',
        icon: Icons.people,
        color: AppColors.primaryGreen,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const McReportsListScreen()),
        ),
      ),
      _SubmissionItem(
        title: 'Sunday Services',
        description: 'View all Sunday service reports',
        icon: Icons.church,
        color: AppColors.primaryGreen,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GarageReportsListScreen()),
        ),
      ),
      _SubmissionItem(
        title: 'Baptisms',
        description: 'View all baptism reports',
        icon: Icons.water_drop,
        color: AppColors.harvestGold,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BaptismReportsListScreen()),
        ),
      ),
      _SubmissionItem(
        title: 'Salvations',
        description: 'View all salvation reports',
        icon: Icons.favorite,
        color: AppColors.harvestGold,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SalvationReportsListScreen()),
        ),
      ),
    ];

    return Column(
      children: submissions
          .map((submission) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildSubmissionCard(submission),
              ))
          .toList(),
    );
  }

  Widget _buildSubmissionCard(_SubmissionItem item) {
    return ZoeCard(
      onTap: item.onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: AppSpacing.iconMd,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.description,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: AppSpacing.iconSm,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

// Helper classes for type safety
class _ReportItem {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final ReportStatus status;
  final VoidCallback onTap;

  _ReportItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.status,
    required this.onTap,
  });
}

class _SubmissionItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _SubmissionItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

enum ReportStatus {
  available,
  submitted,
  overdue,
  noPermission,
}