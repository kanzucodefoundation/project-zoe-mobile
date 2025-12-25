import 'package:flutter/material.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../api/api_client.dart';

class BaptismReportsListScreen extends StatefulWidget {
  const BaptismReportsListScreen({super.key});

  @override
  State<BaptismReportsListScreen> createState() =>
      _BaptismReportsListScreenState();
}

class _BaptismReportsListScreenState extends State<BaptismReportsListScreen> {
  List<Map<String, dynamic>> _reportSubmissions = [];
  List<Map<String, dynamic>> _allSubmissions = [];
  bool _isLoading = true;
  String? _error;
  DateTime? _filterStart;
  DateTime? _filterEnd;
  int _itemsToShow = 2; // Show only 2 items initially

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

      // Get baptism reports (assuming report ID 3 for baptism)
      final submissions = await ReportsService.getReportSubmissions(3);

      if (mounted) {
        setState(() {
          _allSubmissions = submissions;
          _reportSubmissions = submissions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
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

          if (_filterStart != null && submissionDate.isBefore(_filterStart!))
            return false;
          if (_filterEnd != null &&
              submissionDate.isAfter(_filterEnd!.add(const Duration(days: 1))))
            return false;

          return true;
        }).toList();
      }
      _itemsToShow = 2; // Reset pagination when filters change
    });
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
          'Baptism Report Submissions',
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
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    return RefreshIndicator(
      onRefresh: _loadReportSubmissions,
      child: Column(
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
            backgroundColor: Colors.blue,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterStart = null;
                        _filterEnd = null;
                      });
                      _applyDateFilter();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _applyDateFilter();
                      Navigator.pop(context);
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Baptism Reports Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No baptism reports have been submitted yet, or they don\'t match your current filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report) {
    final reportDate =
        report['date'] ?? report['submittedAt'] ?? 'Unknown date';
    final baptismCount =
        report['baptismCount']?.toString() ??
        report['count']?.toString() ??
        '0';
    final title = report['title'] ?? 'Baptism Report';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.water_drop, color: Colors.blue, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Date: $reportDate',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            Text(
              'Baptisms: $baptismCount',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () {
          // TODO: Navigate to detailed view
        },
      ),
    );
  }
}
