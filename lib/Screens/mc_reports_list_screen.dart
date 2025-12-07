import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/report_service.dart';

class McReportsListScreen extends StatefulWidget {
  const McReportsListScreen({super.key});

  @override
  State<McReportsListScreen> createState() => _McReportsListScreenState();
}

class _McReportsListScreenState extends State<McReportsListScreen> {
  List<Map<String, dynamic>> _reportSubmissions = [];
  bool _isLoading = true;
  String? _error;

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

      print('🔄 Loading MC report submissions from local storage...');

      // Load from local storage first (submitted data)
      final localSubmissions = await _loadLocalSubmissions();

      // Also try to load from server as backup
      final serverSubmissions = await ReportService.getMcReportSubmissions();

      // Combine both sources (local takes priority)
      final allSubmissions = [...localSubmissions, ...serverSubmissions];

      if (mounted) {
        setState(() {
          _reportSubmissions = allSubmissions;
          _isLoading = false;
        });
      }

      print(
        '📋 Loaded ${allSubmissions.length} submissions (${localSubmissions.length} local, ${serverSubmissions.length} server)',
      );
    } catch (e) {
      print('❌ Error loading submissions: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
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
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadReportSubmissions,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _clearLocalSubmissions,
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
            Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Reports Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No MC reports have been submitted yet. Submit a report first to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to reports screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit a Report'),
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
    print('\n🔎 === BUILDING REPORT CARD ===');
    print('🔎 Full submission: $submission');

    // Extract data from the correct structure: {reportId: 5, data: {...}}
    final data = submission['data'];
    Map<String, dynamic> reportData = {};

    if (data is Map) {
      reportData = Map<String, dynamic>.from(data);
    }

    print('📊 Raw submission structure:');
    print('  - ID: ${submission['id']}');
    print('  - Report ID: ${submission['reportId']}');
    print('  - Created At: ${submission['createdAt']}');
    print('  - Data type: ${data.runtimeType}');
    print('  - Data content: $data');
    print('📋 Extracted report data: $reportData');
    print('📋 Report data keys: ${reportData.keys.toList()}');
    print('📋 Report data values: ${reportData.values.toList()}');

    // Extract MC info using exact field names (preserving camelCase)
    String mcName = reportData['smallGroupName']?.toString() ?? 'Unknown MC';
    String date =
        reportData['date']?.toString() ??
        submission['createdAt']?.toString().split('T')[0] ??
        'No Date';
    String host = reportData['mcHostHome']?.toString() ?? 'No Host';

    print('✅ === FINAL EXTRACTED VALUES ===');
    print('  - MC Name: "$mcName" (from key: smallGroupName)');
    print('  - Raw smallGroupName: ${reportData['smallGroupName']}');
    print('  - Date: "$date" (from key: date)');
    print('  - Raw date: ${reportData['date']}');
    print('  - Host: "$host" (from key: mcHostHome)');
    print('🔍 All available fields: ${reportData.keys.toList()}');

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
                      color: Colors.blue.withOpacity(0.1),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color.withOpacity(0.8),
        ),
      ),
    );
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
                          }).toList(),
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

  /// Debug: Print all stored submissions\n  Future<void> _debugPrintAllSubmissions() async {\n    try {\n      final prefs = await SharedPreferences.getInstance();\n      final submissionStrings = prefs.getStringList('mc_report_submissions') ?? [];\n      \n      print('\\n\ud83d\udcd1 === ALL STORED SUBMISSIONS DEBUG ===');\n      print('\ud83d\udcd1 Total stored: ${submissionStrings.length}');\n      \n      for (int i = 0; i < submissionStrings.length; i++) {\n        try {\n          final submission = json.decode(submissionStrings[i]) as Map<String, dynamic>;\n          print('\\n\ud83d\udcd1 --- SUBMISSION ${i + 1} ---');\n          print('\ud83d\udcd1 ID: ${submission['id']}');\n          print('\ud83d\udcd1 Report ID: ${submission['reportId']}');\n          print('\ud83d\udcd1 Created: ${submission['createdAt']}');\n          print('\ud83d\udcd1 Data: ${submission['data']}');\n          \n          final data = submission['data'] as Map<String, dynamic>?;\n          if (data != null) {\n            print('\ud83d\udcd1 Data keys: ${data.keys.toList()}');\n            print('\ud83d\udcd1 smallGroupName: ${data['smallGroupName']}');\n            print('\ud83d\udcd1 date: ${data['date']}');\n          }\n        } catch (e) {\n          print('\u26a0\ufe0f Error parsing submission ${i + 1}: $e');\n        }\n      }\n      print('\ud83d\udcd1 === END SUBMISSIONS DEBUG ===\\n');\n    } catch (e) {\n      print('\u274c Error in debug print: $e');\n    }\n  }\n\n  /// Load submissions from local storage (SharedPreferences)
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
          print('⚠️ Error parsing stored submission: $e');
        }
      }

      print('💾 Loaded ${submissions.length} submissions from local storage');
      return submissions;
    } catch (e) {
      print('❌ Error loading local submissions: $e');
      return [];
    }
  }

  /// Clear local submissions (for testing)
  Future<void> _clearLocalSubmissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mc_report_submissions');
      if (mounted) {
        setState(() {
          _reportSubmissions.clear();
        });
      }
      print('🗑️ Cleared local submissions');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local submissions cleared')),
      );
      _loadReportSubmissions(); // Reload
    } catch (e) {
      print('❌ Error clearing local submissions: $e');
    }
  }
}
