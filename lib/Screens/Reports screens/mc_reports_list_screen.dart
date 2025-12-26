import 'package:flutter/material.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../api/api_client.dart';

class McReportsListScreen extends StatefulWidget {
  const McReportsListScreen({super.key});

  @override
  State<McReportsListScreen> createState() => _McReportsListScreenState();
}

class _McReportsListScreenState extends State<McReportsListScreen> {
  List<Map<String, dynamic>> _reportSubmissions = [];
  // Master copy of submissions (server + local) used for filtering
  List<Map<String, dynamic>> _allSubmissions = [];
  bool _isLoading = true;
  String? _error;
  DateTime? _filterStart;
  DateTime? _filterEnd;

  @override
  void initState() {
    super.initState();
    _loadReportSubmissions();
  }

  Future<void> _loadReportSubmissions() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // Ensure authentication context is set before making API calls
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        // Set tenant header for API requests
        ApiClient().setTenant(authProvider.user!.churchName);
        debugPrint('🏛️ Set tenant header: ${authProvider.user!.churchName}');
      } else {
        debugPrint('⚠️ No authenticated user found');
        throw Exception('User not authenticated. Please login again.');
      }

      debugPrint(
        '🔄 Loading report submissions from server and local storage...',
      );

      // Try to load from server first (primary data source)
      final serverSubmissions = await ReportsService.getMcReportSubmissions(
        reportId: 1,
      );
      debugPrint('📡 Server submissions: ${serverSubmissions.submissions}');

      // Also try the general submitted reports endpoint
      final submittedReports = await ReportsService.getAllSubmittedReports();
      debugPrint('📊 Submitted reports: ${submittedReports.length}');

      // Load from local storage as fallback/supplement
      final localSubmissions = await _loadLocalSubmissions();
      debugPrint('💾 Local submissions: ${localSubmissions.length}');

      // Combine all sources (server data takes priority)
      final allSubmissions = [
        ...serverSubmissions.submissions,
        ...submittedReports,
        ...localSubmissions,
      ];

      // Remove duplicates based on ID if any
      // final uniqueSubmissions = <String, Map<String, dynamic>>{};
      // for (final submission in allSubmissions) {
      //   final id =
      //       submission['id']?.toString() ??
      //       submission['reportId']?.toString() ??
      //       DateTime.now().millisecondsSinceEpoch.toString();
      //   uniqueSubmissions[id] = submission;
      // }

      // final finalSubmissions = uniqueSubmissions.values.toList();
      final finalSubmissions = serverSubmissions.submissions
          .map((s) => s.toJson())
          .toList(); // Use only server submissions for now

      if (mounted) {
        setState(() {
          _allSubmissions = finalSubmissions;
          _reportSubmissions = finalSubmissions;
          _isLoading = false;
        });
      }

      debugPrint(
        '📋 Total loaded: ${finalSubmissions.length} submissions (${serverSubmissions.submissions.length} from server, ${localSubmissions.length} local)',
      );
    } catch (e) {
      debugPrint('❌ Error loading submissions: $e');
      if (mounted) {
        setState(() {
          // Provide more user-friendly error message
          if (e.toString().contains('User not authenticated')) {
            _error = 'Authentication required. Please logout and login again.';
          } else if (e.toString().contains('Internal server error') ||
              e.toString().contains('500')) {
            _error = 'Server error. Please try again later or contact support.';
          } else {
            _error =
                'Failed to load reports. Please check your connection and try again.';
          }
          _isLoading = false;
        });
      }
    }
  }

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
        title: const Text(
          'MC Report Submissions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.black),
            tooltip: 'Filter by date range',
            onPressed: _openFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadReportSubmissions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView()
          : _reportSubmissions.isEmpty
          ? _buildEmptyView()
          : _buildReportsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error Loading Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReportSubmissions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Reports Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No reports have been found from the server. Submit a report or check your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadReportSubmissions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                // OutlinedButton(
                //   onPressed: () {
                //     Navigator.pop(context); // Go back to reports screen
                //   },
                //   child: const Text('Submit Report'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    return RefreshIndicator(
      onRefresh: _loadReportSubmissions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reportSubmissions.length,
        itemBuilder: (context, index) {
          final submission = _reportSubmissions[index];
          return _buildReportCard(submission);
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> submission) {
    debugPrint('\n🔎 === BUILDING REPORT CARD ===');
    debugPrint('🔎 Full submission: $submission');

    // Extract data from the correct structure: {reportId: 5, data: {...}}
    final data = submission['data'];
    Map<String, dynamic> reportData = {};

    if (data is Map) {
      reportData = Map<String, dynamic>.from(data);
    }

    debugPrint('📊 Raw submission structure:');
    debugPrint('  - ID: ${submission['id']}');
    debugPrint('  - Report ID: ${submission['reportId']}');
    debugPrint('  - Created At: ${submission['submittedAt']}');
    debugPrint('  - Data type: ${data.runtimeType}');
    debugPrint('  - Data content: $data');
    debugPrint('📋 Extracted report data: $reportData');
    debugPrint('📋 Report data keys: ${reportData.keys.toList()}');
    debugPrint('📋 Report data values: ${reportData.values.toList()}');

    // Extract MC info using exact field names (preserving camelCase)
    String mcName = reportData['smallGroupName']?.toString() ?? 'Unknown MC';
    String date =
        submission['submittedAt']?.toString().split('T')[0] ?? 'No Date';
    String host = reportData['mcHostHome']?.toString() ?? 'No Host';

    debugPrint('✅ === FINAL EXTRACTED VALUES ===');
    debugPrint('  - MC Name: "$mcName" (from key: smallGroupName)');
    debugPrint('  - Raw smallGroupName: ${reportData['smallGroupName']}');
    debugPrint('  - Date: "$date" (from key: date)');
    debugPrint('  - Raw date: ${reportData['date']}');
    debugPrint('  - Host: "$host" (from key: mcHostHome)');
    debugPrint('🔍 All available fields: ${reportData.keys.toList()}');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showReportDetails(submission);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.church,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mcName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        // Debug: Show what we're actually displaying
                        if (mcName == 'Unknown MC')
                          Text(
                            'DEBUG: No MC name found in data',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // Debug: Show what date source we're using
                        if (date == 'No Date')
                          Text(
                            'DEBUG: No date found',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip('Host: $host', Colors.green),
                  const SizedBox(width: 8),
                  _buildInfoChip('Submitted', Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  /// Open filter bottom sheet to choose start and end dates
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter reports by date range',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectFilterDate(context, true),
                      child: Text(
                        _filterStart == null
                            ? 'Start date'
                            : '${_filterStart!.day}/${_filterStart!.month}/${_filterStart!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectFilterDate(context, false),
                      child: Text(
                        _filterEnd == null
                            ? 'End date'
                            : '${_filterEnd!.day}/${_filterEnd!.month}/${_filterEnd!.year}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearDateFilter();
                    },
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyDateFilter();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Select a date for filter (isStart = true -> start date)
  Future<void> _selectFilterDate(BuildContext context, bool isStart) async {
    final DateTime initial = isStart
        ? (_filterStart ?? DateTime.now().subtract(const Duration(days: 30)))
        : (_filterEnd ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      if (mounted) {
        setState(() {
          if (isStart) {
            _filterStart = picked;
          } else {
            _filterEnd = picked;
          }
        });
      }
    }
  }

  void _clearDateFilter() {
    if (mounted) {
      setState(() {
        _filterStart = null;
        _filterEnd = null;
        _reportSubmissions = List.from(_allSubmissions);
      });
    }
  }

  void _applyDateFilter() {
    if (_filterStart == null && _filterEnd == null) {
      // nothing to do
      return;
    }

    final start = _filterStart ?? DateTime(2000);
    final end = _filterEnd ?? DateTime.now();

    final filtered = _allSubmissions.where((submission) {
      final sd = _extractSubmissionDate(submission);
      if (sd == null) return false;
      return !sd.isBefore(start) && !sd.isAfter(end);
    }).toList();

    if (mounted) {
      setState(() {
        _reportSubmissions = filtered;
      });
    }
  }

  /// Extract a DateTime from a submission record, trying common fields
  DateTime? _extractSubmissionDate(Map<String, dynamic> submission) {
    try {
      // Prefer explicit submitted date in data
      final data = submission['data'];
      if (data is Map) {
        final raw =
            data['date'] ?? data['submittedAt'] ?? submission['submittedAt'];
        if (raw != null) {
          final s = raw.toString();
          // Try ISO parse first
          final iso = DateTime.tryParse(s);
          if (iso != null) return iso;

          // Try dd/MM/yyyy
          final parts = s.split('/');
          if (parts.length == 3) {
            final d = int.tryParse(parts[0]);
            final m = int.tryParse(parts[1]);
            final y = int.tryParse(parts[2]);
            if (d != null && m != null && y != null) {
              return DateTime(y, m, d);
            }
          }

          // Try fallback numeric timestamp
          final millis = int.tryParse(s);
          if (millis != null) {
            return DateTime.fromMillisecondsSinceEpoch(millis);
          }
        }
      }

      // Try top-level submittedAt
      final top = submission['submittedAt'];
      if (top != null) {
        final t = top.toString();
        final iso = DateTime.tryParse(t);
        if (iso != null) return iso;
      }
    } catch (e) {
      debugPrint('⚠️ Error extracting date from submission: $e');
    }

    return null;
  }

  void _showReportDetails(Map<String, dynamic> submission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Report Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Safely handle the submitted form data
                    () {
                      final data = submission['data'];
                      Map<String, dynamic> reportData = {};

                      if (data is Map) {
                        reportData = Map<String, dynamic>.from(data);
                      }

                      return Column(
                        children: [
                          // Show ALL submitted fields with proper labels from template
                          ...reportData.entries.map((entry) {
                            // Skip internal fields but keep the exact key names
                            if (['smallGroupId'].contains(entry.key)) {
                              return const SizedBox();
                            }

                            // Get proper label from template if available
                            String fieldLabel = entry.key;
                            final template = submission['template'];
                            if (template != null &&
                                template['fields'] != null) {
                              final fields = template['fields'] as List;
                              final fieldInfo = fields.firstWhere(
                                (field) => field['name'] == entry.key,
                                orElse: () => null,
                              );
                              if (fieldInfo != null &&
                                  fieldInfo['label'] != null) {
                                fieldLabel = fieldInfo['label'];
                              }
                            }

                            return _buildDetailRow(
                              fieldLabel, // Use actual field label from template
                              entry.value?.toString() ?? 'N/A',
                            );
                          }),
                        ],
                      );
                    }(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, // Use label as-is since it comes from template
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadLocalSubmissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final submissionStrings =
          prefs.getStringList('mc_report_submissions') ?? [];

      final submissions = <Map<String, dynamic>>[];
      for (final submissionString in submissionStrings) {
        try {
          final submission =
              json.decode(submissionString) as Map<String, dynamic>;
          submissions.add(submission);
        } catch (e) {
          debugPrint('⚠️ Error parsing stored submission: $e');
        }
      }

      debugPrint(
        '💾 Loaded ${submissions.length} submissions from local storage',
      );
      return submissions;
    } catch (e) {
      debugPrint('❌ Error loading local submissions: $e');
      return [];
    }
  }
}
