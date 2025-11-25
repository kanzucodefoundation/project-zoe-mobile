import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../models/report.dart';
import '../components/report_tile.dart';
import '../helpers/report_helpers.dart';
import '../widgets/custom_drawer.dart';
import 'reports_detail_screen.dart';

/// Reports screen displaying all reports with filtering capabilities
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, _) {
        final reports = reportProvider.filteredReports;
        final summary = reportProvider.reportsSummary;
        final overdueReports = reportProvider.overdueReports;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          drawer: const CustomDrawer(),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
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
                icon: const Icon(Icons.filter_list, color: Colors.black),
                onPressed: () => _showFilterSheet(context, reportProvider),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black),
                onPressed: () => reportProvider.refreshReports(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => reportProvider.refreshReports(),
            child: reportProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Summary cards
                        _buildSummarySection(summary, overdueReports.length),

                        // Filter chips
                        _buildFilterChips(reportProvider),

                        // Reports list
                        reports.isEmpty
                            ? SizedBox(height: 400, child: _buildEmptyState())
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 16),
                                itemCount: reports.length,
                                itemBuilder: (context, index) {
                                  final report = reports[index];
                                  return ReportTile(
                                    report: report,
                                    showProgress: true,
                                    onTap: () =>
                                        _navigateToReportDetail(report.id),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO: Navigate to create report screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Create report functionality coming soon!'),
                ),
              );
            },
            backgroundColor: Colors.black,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(Map<String, int> summary, int overdueCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Reports',
                  summary['total']?.toString() ?? '0',
                  Icons.description,
                  Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Pending',
                  summary['pending']?.toString() ?? '0',
                  Icons.schedule,
                  Colors.orange.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Completed',
                  summary['completed']?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Overdue',
                  overdueCount.toString(),
                  Icons.warning,
                  Colors.red.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
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
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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

  Widget _buildFilterChips(ReportProvider reportProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Status filters
          if (reportProvider.statusFilter != null)
            _buildFilterChip(
              'Status: ${reportProvider.statusFilter!.name}',
              true,
              () => reportProvider.setStatusFilter(null),
            ),

          // Type filters
          if (reportProvider.typeFilter != null)
            _buildFilterChip(
              'Type: ${reportProvider.typeFilter!.name}',
              true,
              () => reportProvider.setTypeFilter(null),
            ),

          // Clear all filters
          if (reportProvider.statusFilter != null ||
              reportProvider.typeFilter != null)
            _buildFilterChip(
              'Clear All',
              false,
              () => reportProvider.clearFilters(),
            ),

          // Quick filters
          _buildFilterChip(
            'Pending',
            reportProvider.statusFilter == ReportStatus.pending,
            () => reportProvider.setStatusFilter(
              reportProvider.statusFilter == ReportStatus.pending
                  ? null
                  : ReportStatus.pending,
            ),
          ),
          _buildFilterChip(
            'In Progress',
            reportProvider.statusFilter == ReportStatus.inProgress,
            () => reportProvider.setStatusFilter(
              reportProvider.statusFilter == ReportStatus.inProgress
                  ? null
                  : ReportStatus.inProgress,
            ),
          ),
          _buildFilterChip(
            'Completed',
            reportProvider.statusFilter == ReportStatus.completed,
            () => reportProvider.setStatusFilter(
              reportProvider.statusFilter == ReportStatus.completed
                  ? null
                  : ReportStatus.completed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: Colors.black,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or create a new report',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ReportProvider reportProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Status filter
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildStatusFilterChip(context, reportProvider, null, 'All'),
                ...ReportStatus.values.map(
                  (status) => _buildStatusFilterChip(
                    context,
                    reportProvider,
                    status,
                    status.name.toUpperCase(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Type filter
            const Text(
              'Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTypeFilterChip(context, reportProvider, null, 'All'),
                ...ReportType.values.map(
                  (type) => _buildTypeFilterChip(
                    context,
                    reportProvider,
                    type,
                    type.name.toUpperCase(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      reportProvider.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(
    BuildContext context,
    ReportProvider reportProvider,
    ReportStatus? status,
    String label,
  ) {
    final isSelected = reportProvider.statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        reportProvider.setStatusFilter(status);
        Navigator.pop(context);
      },
      backgroundColor: Colors.white,
      selectedColor: status != null
          ? ReportHelpers.getStatusColor(status)
          : Colors.grey.shade600,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTypeFilterChip(
    BuildContext context,
    ReportProvider reportProvider,
    ReportType? type,
    String label,
  ) {
    final isSelected = reportProvider.typeFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        reportProvider.setTypeFilter(type);
        Navigator.pop(context);
      },
      backgroundColor: Colors.white,
      selectedColor: type != null
          ? ReportHelpers.getTypeColor(type)
          : Colors.grey.shade600,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _navigateToReportDetail(String reportId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(reportId: reportId),
      ),
    );
  }
}
