import 'package:flutter/material.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../api/api_client.dart';
import '../../components/apply_filter_button.dart';
import '../../components/clear_filter_button.dart';
import '../../components/edit_report_button.dart';
import '../../widgets/custom_toast.dart';
import 'salvation_reports_display_screen.dart';

class SalvationReportsListScreen extends StatefulWidget {
  final int reportId;
  
  const SalvationReportsListScreen({super.key, required this.reportId});

  @override
  State<SalvationReportsListScreen> createState() =>
      _SalvationReportsListScreenState();
}

class _SalvationReportsListScreenState
    extends State<SalvationReportsListScreen> {
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
      } else {
        throw Exception('User not authenticated. Please login again.');
      }

      // Get salvation reports (assuming report ID 4 for salvation)
      final submissions = await ReportsService.getMcReportSubmissions(
        reportId: widget.reportId,
      );

      final templateData = await ReportsService.getReportById(widget.reportId);

      final template = {
        'id': templateData.id,
        'name': templateData.name,
        'fields':
            templateData.fields
                ?.map(
                  (field) => {
                    'id': field.id,
                    'name': field.name,
                    'label': field.label,
                    'type': field.type,
                  },
                )
                .toList() ??
            [],
      };

      if (mounted) {
        setState(() {
          _allSubmissions = submissions.submissions
              .map((e) => {...e.toJson(), 'template': template})
              .toList();
          _reportSubmissions = submissions.submissions
              .map((e) => {...e.toJson(), 'template': template})
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        // Show smart error toast with network-aware messaging
        ToastHelper.showSmartError(
          context,
          e,
          'Failed to load salvation reports',
        );
      }
    }
  }

  void _applyDateFilter() {
    setState(() {
      if (_filterStart == null && _filterEnd == null) {
        _reportSubmissions = List.from(_allSubmissions);
      } else {
        _reportSubmissions = _allSubmissions.where((submission) {
          final submissionDate = DateTime.tryParse(
            submission['date'] ?? submission['submittedAt'] ?? '',
          );
          if (submissionDate == null) return false;

          if (_filterStart != null && submissionDate.isBefore(_filterStart!)) {
            return false;
          }
          if (_filterEnd != null &&
              submissionDate.isAfter(
                _filterEnd!.add(const Duration(days: 1)),
              )) {
            return false;
          }

          return true;
        }).toList();
      }
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Filter Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select date range to filter salvation reports',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectFilterDate(context, true),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FROM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _filterStart == null
                                      ? 'Start date'
                                      : '${_filterStart!.day}/${_filterStart!.month}/${_filterStart!.year}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _filterStart == null
                                        ? Colors.grey.shade500
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectFilterDate(context, false),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _filterEnd == null
                                      ? 'End date'
                                      : '${_filterEnd!.day}/${_filterEnd!.month}/${_filterEnd!.year}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _filterEnd == null
                                        ? Colors.grey.shade500
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ClearFilterButton(
                      onPressed: () {
                        setState(() {
                          _filterStart = null;
                          _filterEnd = null;
                        });
                        _applyDateFilter();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ApplyFilterButton(
                      onPressed: () {
                        _applyDateFilter();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectFilterDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _filterStart : _filterEnd) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _filterStart = picked;
        } else {
          _filterEnd = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Salvation Report Submissions',
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView()
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
              'Unable to load reports',
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
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
            // const SizedBox(height: 24),
            // ElevatedButton(
            //   onPressed: _loadReportSubmissions,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.green,
            //     foregroundColor: Colors.white,
            //   ),
            //   child: const Text('Retry'),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    return RefreshIndicator(
      onRefresh: _loadReportSubmissions,
      child: _reportSubmissions.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _itemsToShow < _reportSubmissions.length
                        ? _itemsToShow + 1
                        : _reportSubmissions.length,
                    itemBuilder: (context, index) {
                      if (index == _itemsToShow &&
                          _itemsToShow < _reportSubmissions.length) {
                        return _buildLoadMoreButton();
                      }
                      return _buildReportItem(_reportSubmissions[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text(
              'No Salvation Reports Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No salvation reports have been submitted yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _itemsToShow += 5; // Load 5 more items
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: Text(
            'Load More (${_reportSubmissions.length - _itemsToShow} remaining)',
          ),
        ),
      ),
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report) {
    final reportDate =
        report['submittedAt']?.toString().split('T')[0] ?? 'No Date';
    final reportData = report['data'] ?? {};
    final salvationCount = reportData['numberOfSalvations']?.toString() ?? '0';
    final groupName = report['groupName'] ?? 'Salvation Report';
    final submittedBy = report['submittedBy']['name'] ?? 'Unknown Person';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            _showReportDetails(report);
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
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groupName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reportDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Submitted by: $submittedBy',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      'Salvations: $salvationCount',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
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

  void _showReportDetails(Map<String, dynamic> submission) {
    // Check if user can edit this submission AND has submit permissions
    final canEdit = submission['canEdit'] ?? false;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final canSubmit = authProvider.user?.canSubmitReports ?? false;
    final canEditAndSubmit = canEdit && canSubmit;

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Salvation Report Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    if (canEditAndSubmit)
                      EditReportButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _editReport(submission);
                        },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'View Only',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    () {
                      final data = submission['data'];
                      Map<String, dynamic> reportData = {};

                      if (data is Map) {
                        reportData = Map<String, dynamic>.from(data);
                      }

                      return Column(
                        children: [
                          ...reportData.entries.map((entry) {
                            if (['smallGroupId'].contains(entry.key)) {
                              return const SizedBox();
                            }

                            String fieldLabel = entry.key;
                            final template = submission['template'];
                            if (template != null &&
                                template['fields'] != null) {
                              final fields = template['fields'] as List;
                              try {
                                final fieldInfo = fields.firstWhere(
                                  (field) => field['name'] == entry.key,
                                );
                                if (fieldInfo['label'] != null) {
                                  fieldLabel = fieldInfo['label'];
                                }
                              } catch (e) {
                                // Field not found, use original key
                              }
                            }

                            return _buildDetailRow(
                              fieldLabel,
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
            label,
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

  void _editReport(Map<String, dynamic> submission) {
    // Navigate to the salvation report display screen in edit mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalvationReportsScreen(
          reportId: submission['reportId'] ?? widget.reportId, // Salvation report ID
          editingSubmission: submission, // Pass submission for editing
        ),
      ),
    ).then((_) {
      // Refresh the list when returning from edit
      _loadReportSubmissions();
    });
  }
}
