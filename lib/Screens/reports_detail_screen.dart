import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../providers/report_provider.dart';
import '../helpers/report_helpers.dart';

/// Report detail screen showing comprehensive report information
class ReportDetailScreen extends StatelessWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, _) {
        final report = reportProvider.getReportById(reportId);

        if (report == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Report Not Found',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: const Center(child: Text('Report not found')),
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
              'Report Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onPressed: () =>
                    _showReportActions(context, report, reportProvider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card with basic info
                _buildHeaderCard(report),
                const SizedBox(height: 16),

                // Status and progress
                _buildStatusCard(report),
                const SizedBox(height: 16),

                // Details section
                _buildDetailsCard(report),
                const SizedBox(height: 16),

                // Data visualization
                _buildDataCard(report),
                const SizedBox(height: 16),

                // Tags
                if (report.tags.isNotEmpty) ...[
                  _buildTagsCard(report),
                  const SizedBox(height: 16),
                ],

                // Actions
                _buildActionsCard(context, report, reportProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(Report report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ReportHelpers.getTypeColor(report.type),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    ReportHelpers.getTypeIcon(report.type),
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    report.typeDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              report.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              report.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Metadata row
            Row(
              children: [
                _buildMetadataItem(
                  Icons.person,
                  'Created by',
                  report.createdBy,
                ),
                const SizedBox(width: 24),
                _buildMetadataItem(
                  Icons.calendar_today,
                  'Created',
                  ReportHelpers.formatDate(report.createdAt),
                ),
              ],
            ),
            if (report.assignedTo != null) ...[
              const SizedBox(height: 12),
              _buildMetadataItem(
                Icons.person_outline,
                'Assigned to',
                report.assignedTo!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(Report report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status & Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ReportHelpers.getStatusColor(report.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ReportHelpers.getStatusIcon(report.status),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        report.statusDisplayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Priority
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ReportHelpers.getPriorityColor(
                      report.priority,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ReportHelpers.getPriorityColor(report.priority),
                    ),
                  ),
                  child: Text(
                    '${report.priorityDisplayName} Priority',
                    style: TextStyle(
                      color: ReportHelpers.getPriorityColor(report.priority),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            if (report.status == ReportStatus.inProgress) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: ReportHelpers.getCompletionPercentage(report),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ReportHelpers.getStatusColor(report.status),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(ReportHelpers.getCompletionPercentage(report) * 100).toInt()}% Complete',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            if (report.completedAt != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Completed on ${ReportHelpers.formatDate(report.completedAt!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            if (report.isOverdue) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This report is overdue by ${report.daysSinceCreated - 7} days',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Report report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            _buildDetailRow('Report ID', report.id),
            _buildDetailRow('Type', report.typeDisplayName),
            _buildDetailRow('Status', report.statusDisplayName),
            _buildDetailRow('Priority', report.priorityDisplayName),
            _buildDetailRow(
              'Created Date',
              ReportHelpers.formatDate(report.createdAt),
            ),
            _buildDetailRow('Created By', report.createdBy),
            if (report.assignedTo != null)
              _buildDetailRow('Assigned To', report.assignedTo!),
            if (report.completedAt != null)
              _buildDetailRow(
                'Completed Date',
                ReportHelpers.formatDate(report.completedAt!),
              ),
            _buildDetailRow(
              'Days Since Created',
              '${report.daysSinceCreated} days',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(Report report) {
    if (report.data.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Display key metrics
            ...report.data.entries.map((entry) {
              if (entry.value is num) {
                return _buildMetricTile(
                  entry.key,
                  entry.value.toString(),
                  _getMetricIcon(entry.key),
                );
              } else if (entry.value is List) {
                return _buildListTile(entry.key, entry.value as List);
              }
              return _buildDetailRow(
                entry.key.toString().replaceAll('_', ' ').toUpperCase(),
                entry.value.toString(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String label, List items) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...items.take(5).map((item) {
            if (item is Map) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: item.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• $item'),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTagsCard(Report report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: report.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    Report report,
    ReportProvider reportProvider,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            if (report.status == ReportStatus.pending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateReportStatus(
                    context,
                    report,
                    ReportStatus.inProgress,
                    reportProvider,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

            if (report.status == ReportStatus.inProgress) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateReportStatus(
                    context,
                    report,
                    ReportStatus.completed,
                    reportProvider,
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Mark Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _updateReportStatus(
                    context,
                    report,
                    ReportStatus.pending,
                    reportProvider,
                  ),
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause Report'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

            if (report.status != ReportStatus.cancelled) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _updateReportStatus(
                    context,
                    report,
                    ReportStatus.cancelled,
                    reportProvider,
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Report'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getMetricIcon(String key) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('member')) return Icons.people;
    if (lowerKey.contains('attendance')) return Icons.people_outline;
    if (lowerKey.contains('income') ||
        lowerKey.contains('money') ||
        lowerKey.contains('amount')) {
      return Icons.attach_money;
    }
    if (lowerKey.contains('event')) return Icons.event;
    if (lowerKey.contains('rate') || lowerKey.contains('percentage')) {
      return Icons.trending_up;
    }
    return Icons.analytics;
  }

  void _showReportActions(
    BuildContext context,
    Report report,
    ReportProvider reportProvider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Report'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Report'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement export functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Report'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit screen
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateReportStatus(
    BuildContext context,
    Report report,
    ReportStatus newStatus,
    ReportProvider reportProvider,
  ) {
    reportProvider.updateReportStatus(report.id, newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report status updated to ${newStatus.name}'),
        backgroundColor: ReportHelpers.getStatusColor(newStatus),
      ),
    );
  }
}
