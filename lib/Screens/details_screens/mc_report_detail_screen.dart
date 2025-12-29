import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Screen displaying detailed reports for a specific MC
class McReportDetailScreen extends StatefulWidget {
  final Map<String, dynamic> mc;
  final List<Map<String, dynamic>> reports;

  const McReportDetailScreen({
    super.key,
    required this.mc,
    required this.reports,
  });

  @override
  State<McReportDetailScreen> createState() => _McReportDetailScreenState();
}

class _McReportDetailScreenState extends State<McReportDetailScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.mc['name'],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'MC Reports',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final filteredReports = _getFilteredReports();

    return Column(
      children: [
        _buildSummaryHeader(),
        Expanded(child: _buildReportsList(filteredReports)),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    final totalReports = widget.reports.length;
    final recentReports = widget.reports.where((report) {
      final createdAt = report['createdAt'] as DateTime;
      final daysAgo = DateTime.now().difference(createdAt).inDays;
      return daysAgo <= 30;
    }).length;

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
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.groups, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mc['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'MC ID: ${widget.mc['id']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Reports',
                  totalReports.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'This Month',
                  recentReports.toString(),
                  Icons.calendar_today,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Status',
                  _getOverallStatus(),
                  Icons.trending_up,
                  _getStatusColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReportsList(List<Map<String, dynamic>> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'all'
                  ? 'No Reports Found'
                  : 'No Reports Match Filter',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'This MC hasn\'t submitted any reports yet'
                  : 'Try adjusting your filter criteria',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final createdAt = report['createdAt'] as DateTime;
    final status = report['status'] as String;
    final data = report['data'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showReportDetails(report),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy • HH:mm',
                            ).format(createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColorForReport(
                          status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColorForReport(status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (data.isNotEmpty) ...[
                  _buildReportDataPreview(data),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Attendance: ${data['attendance'] ?? data['smallGroupAttendanceCount'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.blue.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportDataPreview(Map<String, dynamic> data) {
    final hostHome = data['hostHome'] ?? data['mcHostHome'];
    final totalMembers =
        data['totalMembers'] ?? data['smallGroupNumberOfMembers'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (hostHome != null) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Host Home',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    hostHome.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (totalMembers != null) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Members',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    totalMembers.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  List<Map<String, dynamic>> _getFilteredReports() {
    switch (_selectedFilter) {
      case 'pending':
        return widget.reports.where((r) => r['status'] == 'pending').toList();
      case 'completed':
        return widget.reports.where((r) => r['status'] == 'completed').toList();
      case 'recent':
        return widget.reports.where((r) {
          final createdAt = r['createdAt'] as DateTime;
          return DateTime.now().difference(createdAt).inDays <= 7;
        }).toList();
      default:
        return widget.reports;
    }
  }

  String _getOverallStatus() {
    if (widget.reports.isEmpty) return 'No Reports';

    final recentReports = widget.reports.where((report) {
      final createdAt = report['createdAt'] as DateTime;
      return DateTime.now().difference(createdAt).inDays <= 7;
    }).length;

    if (recentReports > 0) return 'Active';
    return 'Inactive';
  }

  Color _getStatusColor() {
    final status = _getOverallStatus();
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatFieldLabel(String fieldKey) {
    // Handle common field name formats and convert them to readable labels
    final Map<String, String> fieldLabels = {
      'mcStreamPlatform': 'Stream Platform',
      'gatheringDate': 'Gathering Date',
      'smallGroupName': 'MC Name',
      'mcName': 'MC Name',
      'groupName': 'Group Name',
      'mcHostHome': 'Host Home',
      'hostHome': 'Host Home',
      'smallGroupNumberOfMembers': 'Total Members',
      'totalMembers': 'Total Members',
      'smallGroupAttendanceCount': 'Attendance Count',
      'attendance': 'Attendance',
      'attendeesNames': 'Attendees Names',
      'visitors': 'Visitors',
      'highlights': 'Highlights',
      'testimonies': 'Testimonies',
      'prayerRequests': 'Prayer Requests',
      'streamingMethod': 'Streaming Method',
    };

    // Return mapped label if exists, otherwise format the key
    if (fieldLabels.containsKey(fieldKey)) {
      return fieldLabels[fieldKey]!;
    }

    // Convert camelCase to Title Case
    return fieldKey
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ')
        .trim();
  }

  bool _isLongField(String fieldKey, dynamic value) {
    // Determine if field should be displayed as long text based on key or value length
    final longFieldKeys = [
      'attendeesNames',
      'visitors', 
      'highlights',
      'testimonies',
      'prayerRequests',
      'notes',
      'comments',
      'description',
      'summary'
    ];

    // Check if it's a known long field
    if (longFieldKeys.any((key) => fieldKey.toLowerCase().contains(key.toLowerCase()))) {
      return true;
    }

    // Check if value is long text (more than 50 characters)
    if (value is String && value.length > 50) {
      return true;
    }

    return false;
  }

  Color _getStatusColorForReport(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inprogress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Reports'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('all', 'All Reports'),
              _buildFilterOption('recent', 'Recent (7 days)'),
              _buildFilterOption('pending', 'Pending'),
              _buildFilterOption('completed', 'Completed'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedFilter,
      onChanged: (String? newValue) {
        setState(() {
          _selectedFilter = newValue ?? 'all';
        });
        Navigator.pop(context);
      },
    );
  }

  void _showReportDetails(Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildReportDetailsModal(report),
    );
  }

  Widget _buildReportDetailsModal(Map<String, dynamic> report) {
    final data = report['data'] as Map<String, dynamic>;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        report['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDetailSection('Basic Information', [
                      _buildDetailRow('Report ID', report['id']),
                      _buildDetailRow('Status', report['status']),
                      _buildDetailRow(
                        'Created At',
                        DateFormat(
                          'MMM dd, yyyy • HH:mm',
                        ).format(report['createdAt'] as DateTime),
                      ),
                      _buildDetailRow('Description', report['description']),
                    ]),
                    const SizedBox(height: 20),
                    _buildDetailSection('MC Information', [
                      if (data['mcName'] != null)
                        _buildDetailRow('MC Name', data['mcName']),
                      if (data['smallGroupName'] != null)
                        _buildDetailRow('MC Name', data['smallGroupName']),
                      if (data['mcId'] != null)
                        _buildDetailRow('MC ID', data['mcId']),
                      if (data['smallGroupId'] != null)
                        _buildDetailRow('MC ID', data['smallGroupId']),
                      if (data['hostHome'] != null)
                        _buildDetailRow('Host Home', data['hostHome']),
                      if (data['mcHostHome'] != null)
                        _buildDetailRow('Host Home', data['mcHostHome']),
                    ]),
                    const SizedBox(height: 20),
                    _buildDetailSection('Attendance Data', [
                      if (data['totalMembers'] != null)
                        _buildDetailRow('Total Members', data['totalMembers']),
                      if (data['smallGroupNumberOfMembers'] != null)
                        _buildDetailRow(
                          'Total Members',
                          data['smallGroupNumberOfMembers'],
                        ),
                      if (data['attendance'] != null)
                        _buildDetailRow('Attendance', data['attendance']),
                      if (data['smallGroupAttendanceCount'] != null)
                        _buildDetailRow(
                          'Attendance',
                          data['smallGroupAttendanceCount'],
                        ),
                      if (data['gatheringDate'] != null)
                        _buildDetailRow(
                          'Gathering Date',
                          data['gatheringDate'],
                        ),
                      if (data['date'] != null)
                        _buildDetailRow('Date', data['date']),
                    ]),
                    const SizedBox(height: 20),
                    _buildDetailSection('Form Fields', [
                      ...data.entries
                          .where((entry) => 
                              // Exclude technical/system fields but show all form fields
                              ![
                                'id',
                                'reportId', 
                                'createdAt',
                                'updatedAt',
                                'status',
                                'template'
                              ].contains(entry.key) &&
                              entry.value != null &&
                              entry.value.toString().isNotEmpty
                          )
                          .map((entry) {
                            final fieldLabel = _formatFieldLabel(entry.key);
                            final isLongField = _isLongField(entry.key, entry.value);
                            return _buildDetailRow(
                              fieldLabel, 
                              entry.value,
                              isLong: isLongField,
                            );
                          })
                          .toList(),
                    ]),
                    if (_hasAdditionalData(data)) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection('Additional Information', [
                        if (data['streamingMethod']?.isNotEmpty == true)
                          _buildDetailRow(
                            'Streaming Method',
                            data['streamingMethod'],
                          ),
                        if (data['attendeesNames']?.isNotEmpty == true)
                          _buildDetailRow(
                            'Attendees',
                            data['attendeesNames'],
                            isLong: true,
                          ),
                        if (data['visitors']?.isNotEmpty == true)
                          _buildDetailRow(
                            'Visitors',
                            data['visitors'],
                            isLong: true,
                          ),
                        if (data['highlights']?.isNotEmpty == true)
                          _buildDetailRow(
                            'Highlights',
                            data['highlights'],
                            isLong: true,
                          ),
                        if (data['testimonies']?.isNotEmpty == true)
                          _buildDetailRow(
                            'Testimonies',
                            data['testimonies'],
                            isLong: true,
                          ),
                        if (data['prayerRequests']?.isNotEmpty == true)
                          _buildDetailRow(
                            'Prayer Requests',
                            data['prayerRequests'],
                            isLong: true,
                          ),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value, {bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: isLong
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value?.toString() ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value?.toString() ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  bool _hasAdditionalData(Map<String, dynamic> data) {
    return data['streamingMethod']?.isNotEmpty == true ||
        data['attendeesNames']?.isNotEmpty == true ||
        data['visitors']?.isNotEmpty == true ||
        data['highlights']?.isNotEmpty == true ||
        data['testimonies']?.isNotEmpty == true ||
        data['prayerRequests']?.isNotEmpty == true;
  }
}
