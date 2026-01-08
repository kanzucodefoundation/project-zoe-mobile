import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../widgets/custom_toast.dart';
import '../../services/reports_service.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/connectivity_service.dart';
import '../../widgets/offline_indicator.dart';
import '../reports-screens/mc_attendance_report_screen.dart';
import '../reports-screens/garage_reports_display_screen.dart';
import '../reports-screens/baptism_reports_display_screen.dart';
import '../reports-screens/salvation_reports_display_screen.dart';
import '../reports-screens/report_submissions_list_screen.dart';

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
    _loadReportCategories();
  }

  Future<void> _refreshData() async {
    _hasInitialized = false;
    await _loadInitialData();
  }

  void _loadReportCategories() {
    if (!mounted) return;

    try {
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      final categories = ReportsService.getReportCategoriesFromReports(reportProvider.reports);
      if (mounted) {
        setState(() {
          _reportCategories = categories;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Failed to extract report categories');
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

  // Helper method to get basic UI properties for reports
  _ReportUIInfo _getReportUIInfo(String title) {
    final lowerTitle = title.toLowerCase();
    
    // Simple icon/color assignment based on keywords
    if (lowerTitle.contains('attendance') || lowerTitle.contains('mc') || lowerTitle.contains('missional')) {
      return _ReportUIInfo(
        icon: Icons.people,
        iconColor: AppColors.primaryGreen,
        description: 'Fellowship report',
        displayScreenType: DisplayScreenType.mcReports,
        enableLocalStorage: true,
      );
    } else if (lowerTitle.contains('baptism')) {
      return _ReportUIInfo(
        icon: Icons.water_drop,
        iconColor: AppColors.harvestGold,
        description: 'Baptism report',
        displayScreenType: DisplayScreenType.baptismReports,
        enableLocalStorage: false,
      );
    } else if (lowerTitle.contains('salvation')) {
      return _ReportUIInfo(
        icon: Icons.favorite,
        iconColor: AppColors.harvestGold,
        description: 'Salvation report',
        displayScreenType: DisplayScreenType.salvationReports,
        enableLocalStorage: false,
      );
    } else {
      // Default for all other reports (Sunday service, etc.)
      return _ReportUIInfo(
        icon: Icons.church,
        iconColor: AppColors.primaryGreen,
        description: 'Service report',
        displayScreenType: DisplayScreenType.garageReports,
        enableLocalStorage: false,
      );
    }
  }

  Widget _buildSubmitReportsGrid(
    ReportProvider reportProvider,
    AuthProvider authProvider,
  ) {
    // Check connectivity for submit reports
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    if (connectivityService.isOffline) {
      return const OfflineMessage(
        message: 'Reports require an internet connection. Please check your connection to submit reports.',
      );
    }

    if (reportProvider.isLoading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6, // Show 6 loading cards
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.85, // Made taller to accommodate content
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
    // Backend handles permission filtering - if report is returned, user can submit it
    for (final report in titleAndId) {
      final String title = report['title']?.toString() ?? '';
      final dynamic id = report['id'];
      
      // Get UI info for the report
      final uiInfo = _getReportUIInfo(title);
      
      Widget? targetScreen;
      
      // Route to appropriate submission screens
      switch (uiInfo.displayScreenType) {
        case DisplayScreenType.mcReports:
          targetScreen = McAttendanceReportScreen(reportId: id);
          break;
        case DisplayScreenType.garageReports:
          targetScreen = GarageReportsScreen(reportId: id);
          break;
        case DisplayScreenType.baptismReports:
          targetScreen = BaptismReportsScreen(reportId: id);
          break;
        case DisplayScreenType.salvationReports:
          targetScreen = SalvationReportsScreen(reportId: id);
          break;
      }

      reportItems.add(_ReportItem(
        title: title,
        description: uiInfo.description,
        icon: uiInfo.icon,
        iconColor: uiInfo.iconColor,
        status: ReportStatus.available,
        onTap: targetScreen != null
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => targetScreen!),
                )
            : () => ToastHelper.showInfo(context, '$title coming soon'),
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
        childAspectRatio: 0.85, // Made taller to accommodate content
      ),
      itemBuilder: (_, index) => _buildReportCard(reportItems[index]),
    );
  }

  Widget _buildReportCard(_ReportItem item) {
    return ZoeCard(
      onTap: item.onTap,
      padding: const EdgeInsets.all(AppSpacing.md), // Consistent padding
      backgroundColor: AppColors.cardBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm), // Reduced padding
            decoration: BoxDecoration(
              color: item.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(
              item.icon,
              size: AppSpacing.iconMd, // Slightly smaller icon
              color: item.iconColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm), // Reduced spacing
          Flexible(
            child: Text(
              item.title,
              style: AppTextStyles.label.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
                fontSize: 13, // Slightly smaller font
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Flexible(
            child: Text(
              item.description,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryText,
                fontSize: 11, // Smaller font for description
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Allow 2 lines for description
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.status == ReportStatus.submitted) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                'Submitted',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
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
    return Consumer3<ReportProvider, AuthProvider, ConnectivityService>(
      builder: (context, reportProvider, authProvider, connectivityService, child) {
        // Show offline message if no connection
        if (connectivityService.isOffline) {
          return const OfflineMessage(
            message: 'Unable to load submissions while offline. Please check your internet connection.',
          );
        }

        if (reportProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final titleAndId = reportProvider.titleAndId;
        final List<_SubmissionItem> submissions = [];

        // Generate submissions dynamically from the same reports used for submit
        // Backend handles permission filtering - if report is returned, user can view its submissions

        for (final report in titleAndId) {
          final String title = report['title']?.toString() ?? '';
          final dynamic id = report['id'];
          
          // Get UI info for the report
          final uiInfo = _getReportUIInfo(title);

          submissions.add(_SubmissionItem(
            title: title,
            description: 'View all ${title.toLowerCase()} submissions',
            icon: uiInfo.icon,
            color: uiInfo.iconColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportSubmissionsListScreen(
                  reportId: id,
                  reportName: title,
                  displayScreenType: uiInfo.displayScreenType,
                  enableLocalStorage: uiInfo.enableLocalStorage,
                ),
              ),
            ),
          ));
        }

        if (submissions.isEmpty) {
          return const Center(
            child: Text(
              'No submission reports available',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: submissions
              .map((submission) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildSubmissionCard(submission),
                  ))
              .toList(),
        );
      },
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
}

// Helper class for report UI info
class _ReportUIInfo {
  final IconData icon;
  final Color iconColor;
  final String description;
  final DisplayScreenType displayScreenType;
  final bool enableLocalStorage;

  _ReportUIInfo({
    required this.icon,
    required this.iconColor,
    required this.description,
    required this.displayScreenType,
    required this.enableLocalStorage,
  });
}