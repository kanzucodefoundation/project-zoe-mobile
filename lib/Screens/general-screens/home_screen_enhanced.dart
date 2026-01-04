import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/custom_toast.dart';
import '../reports-screens/mc_attendance_report_screen.dart';
import '../reports-screens/garage_reports_display_screen.dart';
import '../reports-screens/salvation_reports_display_screen.dart';
import '../reports-screens/baptism_reports_display_screen.dart';
import './add_contact_screen.dart';

/// Enhanced Home Screen using Project Zoe Design System
class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});
  
  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardSummary();
      context.read<ReportProvider>().refreshReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () async {
          if (!mounted) return;

          final reportProvider = context.read<ReportProvider>();
          final dashboardProvider = context.read<DashboardProvider>();

          try {
            await Future.wait([
              reportProvider.refreshReports(),
              dashboardProvider.loadDashboardSummary(),
            ]);
            
            if (mounted) {
              ToastHelper.showInfo(
                context,
                'Data refreshed successfully',
              );
            }
          } catch (e) {
            if (mounted) {
              ToastHelper.showSmartError(
                context,
                e,
                'Failed to refresh data',
              );
            }
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Welcome Section with brand colors
              _buildWelcomeSection(auth),
              
              // Key Stats Section (3 cards)
              _buildStatsSection(),
              
              // Pending Actions Section
              _buildPendingActionsSection(auth),
              
              // Bottom padding for navigation bar
              const SizedBox(height: AppSpacing.xxxl * 3),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildWelcomeSection(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm, // Reduced top margin since we now have SafeArea
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.church,
              size: AppSpacing.iconXl,
              color: AppColors.pureWhite,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_getFirstName(auth.user?.fullName ?? "Leader")}',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  auth.user?.hierarchy.fellowshipGroups.isNotEmpty == true
                      ? auth.user!.hierarchy.fellowshipGroups.first.name
                      : 'Your fellowship awaits',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pureWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < 2 ? AppSpacing.statCardSpacing : 0,
                    ),
                    height: AppSpacing.statCardHeight + 20,
                    child: const ZoeCard(
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Check if we have actual data or if backend is unavailable
        final hasData = provider.dashboardSummary != null;
        final memberCount = provider.dashboardSummary?.group.memberCount ?? 0;
        final attendance = provider.dashboardSummary?.thisWeek.attendance ?? 0;
        final newMembers = provider.dashboardSummary?.thisWeek.newMembers ?? 0;
        final salvations = provider.dashboardSummary?.thisWeek.salvations ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  'This Week\'s Stats',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              // First Row
              Row(
                children: [
                  Expanded(
                    child: ZoeStatCard(
                      value: hasData ? memberCount.toString() : '--',
                      label: 'Members',
                      icon: Icons.people,
                      valueColor: hasData ? AppColors.primaryText : AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.statCardSpacing),
                  Expanded(
                    child: ZoeStatCard(
                      value: hasData ? attendance.toString() : '--',
                      label: 'Attendance',
                      icon: Icons.event,
                      valueColor: hasData ? AppColors.primaryGreen : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Second Row
              Row(
                children: [
                  Expanded(
                    child: ZoeStatCard(
                      value: hasData ? newMembers.toString() : '--',
                      label: 'New Members',
                      icon: Icons.person_add,
                      valueColor: hasData ? AppColors.primaryText : AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.statCardSpacing),
                  Expanded(
                    child: ZoeStatCard(
                      value: hasData ? salvations.toString() : '--',
                      label: 'Salvations',
                      icon: Icons.favorite,
                      valueColor: hasData ? AppColors.harvestGold : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingActionsSection(AuthProvider auth) {
    return Consumer<ReportProvider>(
      builder: (context, provider, child) {
        // In a real implementation, we'd check for overdue reports
        // For now, we'll show a sample pending action
        
        final hasPendingReports = true; // This would come from actual data
        
        if (!hasPendingReports) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: ZoeCard(
              backgroundColor: AppColors.growthTint.withOpacity(0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: AppSpacing.iconLg,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'All caught up! No pending actions.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pending Actions',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ZoeCard(
                onTap: () {
                  // Navigate to appropriate report screen
                  final mcReportId = provider.titleAndId
                      .firstWhere(
                        (report) => report['title']?.toString().toLowerCase().contains('attendance') ?? false,
                        orElse: () => {'id': 0},
                      )['id'];
                  
                  if (mcReportId != 0 && auth.isMcShepherdPermissions) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => McAttendanceReportScreen(reportId: mcReportId),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: AppSpacing.iconMd,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fellowship Report Due',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Submit your weekly fellowship report',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.secondaryText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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