import 'package:flutter/material.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../providers/auth_provider.dart';
import '../../api/api_client.dart';
import '../../components/apply_filter_button.dart';
import '../../components/clear_filter_button.dart';
import '../../components/edit_report_button.dart';
import '../../widgets/custom_toast.dart';
import 'mc_reports_display_screen.dart';
import 'garage_reports_display_screen.dart';
import 'baptism_reports_display_screen.dart';
import 'salvation_reports_display_screen.dart';

enum DisplayScreenType {
  mcReports,
  garageReports,
  baptismReports,
  salvationReports,
}

class ReportSubmissionsListScreen extends StatefulWidget {
  final int reportId;
  final String reportName;
  final DisplayScreenType displayScreenType;
  final bool enableLocalStorage;
  final bool enablePagination;
  
  const ReportSubmissionsListScreen({
    super.key, 
    required this.reportId,
    required this.reportName,
    required this.displayScreenType,
    this.enableLocalStorage = false,
    this.enablePagination = true,
  });

  @override
  State<ReportSubmissionsListScreen> createState() => _ReportSubmissionsListScreenState();
}

class _ReportSubmissionsListScreenState extends State<ReportSubmissionsListScreen> {
  List<Map<String, dynamic>> _reportSubmissions = [];
  List<Map<String, dynamic>> _allSubmissions = [];
  bool _isLoading = true;
  String? _error;
  DateTime? _filterStart;
  DateTime? _filterEnd;
  int _itemsToShow = 2;

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

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        ApiClient().setTenant(authProvider.user!.churchName);
        debugPrint('🏛️ Set tenant header: ${authProvider.user!.churchName}');
      } else {
        debugPrint('⚠️ No authenticated user found');
        throw Exception('User not authenticated. Please login again.');
      }

      debugPrint('🔄 Loading report submissions for reportId: ${widget.reportId}');

      // Load from server
      final serverSubmissions = await ReportsService.getMcReportSubmissions(
        reportId: widget.reportId,
      );
      debugPrint('📡 Server submissions: ${serverSubmissions.submissions}');

      // Load template for field label mapping
      final templateData = await ReportsService.getReportById(widget.reportId);
      final template = {
        'id': templateData.id,
        'name': templateData.name,
        'fields': templateData.fields
                ?.map((field) => {
                      'id': field.id,
                      'name': field.name,
                      'label': field.label,
                      'type': field.type,
                    })
                .toList() ??
            [],
      };

      List<Map<String, dynamic>> finalSubmissions;

      if (widget.enableLocalStorage) {
        // Load from local storage as fallback/supplement (MC reports only)
        final localSubmissions = await _loadLocalSubmissions();
        debugPrint('💾 Local submissions: ${localSubmissions.length}');
        
        finalSubmissions = serverSubmissions.submissions
            .map((s) => {...s.toJson(), 'template': template})
            .toList();
      } else {
        // Use only server submissions
        finalSubmissions = serverSubmissions.submissions
            .map((s) => {...s.toJson(), 'template': template})
            .toList();
      }

      if (mounted) {
        setState(() {
          _allSubmissions = finalSubmissions;
          _reportSubmissions = finalSubmissions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        ToastHelper.showSmartError(
          context,
          e,
          'Failed to load ${widget.reportName.toLowerCase()} reports',
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadLocalSubmissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final submissionKeys = prefs.getKeys()
          .where((key) => key.startsWith('mc_report_submission_'))
          .toList();

      final List<Map<String, dynamic>> localSubmissions = [];

      for (final key in submissionKeys) {
        final submissionJson = prefs.getString(key);
        if (submissionJson != null) {
          final submission = json.decode(submissionJson) as Map<String, dynamic>;
          
          if (submission['reportId'] == widget.reportId) {
            submission['isLocal'] = true;
            submission['submissionKey'] = key;
            localSubmissions.add(submission);
          }
        }
      }

      return localSubmissions;
    } catch (e) {
      debugPrint('Error loading local submissions: $e');
      return [];
    }
  }

  void _applyDateFilter() {
    setState(() {
      if (_filterStart == null && _filterEnd == null) {
        _reportSubmissions = _allSubmissions;
      } else {
        _reportSubmissions = _allSubmissions.where((submission) {
          final submissionDate = DateTime.tryParse(submission['submittedAt'] ?? '');
          if (submissionDate == null) return false;

          if (_filterStart != null && submissionDate.isBefore(_filterStart!)) {
            return false;
          }
          if (_filterEnd != null && submissionDate.isAfter(_filterEnd!.add(const Duration(days: 1)))) {
            return false;
          }
          return true;
        }).toList();
      }
      
      if (widget.enablePagination) {
        _itemsToShow = 2; // Reset pagination when filters change
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _filterStart = null;
      _filterEnd = null;
      _reportSubmissions = _allSubmissions;
      if (widget.enablePagination) {
        _itemsToShow = 2;
      }
    });
  }

  Widget _getDisplayScreen(Map<String, dynamic> submission) {
    switch (widget.displayScreenType) {
      case DisplayScreenType.mcReports:
        return McReportsScreen(reportId: widget.reportId, editingSubmission: submission);
      case DisplayScreenType.garageReports:
        return GarageReportsScreen(reportId: widget.reportId, editingSubmission: submission);
      case DisplayScreenType.baptismReports:
        return BaptismReportsScreen(reportId: widget.reportId, editingSubmission: submission);
      case DisplayScreenType.salvationReports:
        return SalvationReportsScreen(reportId: widget.reportId, editingSubmission: submission);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.reportName} Submissions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // Remove edit button from submissions list - users view individual submissions, not edit the template
      ),
      body: Column(
        children: [
          // Filter controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(_filterStart?.toString().split(' ')[0] ?? 'Start Date'),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _filterStart ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _filterStart = date);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(_filterEnd?.toString().split(' ')[0] ?? 'End Date'),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _filterEnd ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _filterEnd = date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ApplyFilterButton(onPressed: _applyDateFilter),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClearFilterButton(onPressed: _clearFilters),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Error loading submissions', style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text(_error!, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadReportSubmissions,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _reportSubmissions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.description, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No ${widget.reportName.toLowerCase()} submissions found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadReportSubmissions,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: widget.enablePagination && _itemsToShow < _reportSubmissions.length
                                  ? _itemsToShow + 1
                                  : _reportSubmissions.length,
                              itemBuilder: (context, index) {
                                if (widget.enablePagination && 
                                    index == _itemsToShow &&
                                    _itemsToShow < _reportSubmissions.length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _itemsToShow += 5; // Load 5 more items
                                              });
                                            },
                                            child: Text(
                                              'Load More (${_reportSubmissions.length - _itemsToShow} remaining)',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final submission = _reportSubmissions[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(_getSubmitterName(submission)),
                                    subtitle: Text(submission['submittedAt']?.toString().split(' ')[0] ?? 'No date'),
                                    trailing: Icon(
                                      submission['isLocal'] == true ? Icons.cloud_off : Icons.cloud_done,
                                      color: submission['isLocal'] == true ? Colors.orange : Colors.green,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => _getDisplayScreen(submission),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _getSubmitterName(Map<String, dynamic> submission) {
    // Try different possible field names for submitter
    if (submission['submitterName'] != null) {
      return submission['submitterName'];
    }
    
    if (submission['submittedBy'] != null) {
      final submittedBy = submission['submittedBy'];
      if (submittedBy is Map<String, dynamic> && submittedBy['name'] != null) {
        return submittedBy['name'];
      }
      if (submittedBy is String) {
        return submittedBy;
      }
    }
    
    // Fallback to other possible field names
    if (submission['submitter'] != null) {
      final submitter = submission['submitter'];
      if (submitter is Map<String, dynamic> && submitter['name'] != null) {
        return submitter['name'];
      }
      if (submitter is String) {
        return submitter;
      }
    }
    
    return 'Unknown Submitter';
  }
}