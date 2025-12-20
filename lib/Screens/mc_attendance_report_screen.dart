import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/report.dart';
import 'details_screens/mc_report_detail_screen.dart';

/// Full screen MC Attendance Report displaying all MCs and their submitted reports
class McAttendanceReportScreen extends StatefulWidget {
  const McAttendanceReportScreen({super.key});

  @override
  State<McAttendanceReportScreen> createState() =>
      _McAttendanceReportScreenState();
}

class _McAttendanceReportScreenState extends State<McAttendanceReportScreen> {
  List<Map<String, dynamic>> _availableMcs = [];
  final Map<int, List<Map<String, dynamic>>> _mcReports = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMcData();
  }

  /// Load all MC data including available MCs and their reports
  Future<void> _loadMcData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load available MCs
      print('🔄 Loading available MCs...');
      _availableMcs = await ReportService.getAvailableGroups();
      print('✅ Loaded ${_availableMcs.length} MCs');

      // Load reports for each MC
      await _loadReportsForAllMcs();
    } catch (e) {
      print('❌ Error loading MC data: $e');
      setState(() {
        _error = 'Failed to load MC data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load reports for all available MCs
  Future<void> _loadReportsForAllMcs() async {
    print('🔄 Loading reports for all MCs...');

    for (final mc in _availableMcs) {
      try {
        final mcId = mc['id'] as int;
        final reports = await _loadReportsForMc(mcId);
        _mcReports[mcId] = reports;
        print('✅ Loaded ${reports.length} reports for MC ${mc['name']}');
      } catch (e) {
        print('⚠️ Failed to load reports for MC ${mc['name']}: $e');
        _mcReports[mc['id']] = [];
      }
    }
  }

  /// Load reports for a specific MC
  Future<List<Map<String, dynamic>>> _loadReportsForMc(int mcId) async {
    try {
      // For now, we'll use the general reports endpoint
      // In the future, this might be a specific endpoint for MC reports
      final allReports = await ReportService.getAllReports();

      // Filter reports for this specific MC
      final mcReports = allReports
          .where(
            (report) =>
                report.data['smallGroupId'] == mcId ||
                report.data['mcId'] == mcId.toString(),
          )
          .map((report) => _convertReportToMap(report))
          .toList();

      return mcReports;
    } catch (e) {
      print('❌ Error loading reports for MC $mcId: $e');
      return [];
    }
  }

  /// Convert Report model to Map for easier handling
  Map<String, dynamic> _convertReportToMap(Report report) {
    return {
      'id': report.id,
      'title': report.title,
      'description': report.description,
      'status': report.status.toString().split('.').last,
      'createdAt': report.createdAt,
      'data': report.data,
    };
  }

  /// Get report count for a specific MC
  int _getReportCountForMc(int mcId) {
    return _mcReports[mcId]?.length ?? 0;
  }

  /// Get status color based on report count
  Color _getStatusColor(int reportCount) {
    if (reportCount == 0) return Colors.red;
    if (reportCount < 3) return Colors.orange;
    return Colors.green;
  }

  /// Get status text based on report count
  String _getStatusText(int reportCount) {
    if (reportCount == 0) return 'No Reports';
    if (reportCount == 1) return '1 Report';
    return '$reportCount Reports';
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
          'MC Attendance Reports',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadMcData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading MC reports...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMcData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_availableMcs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No MCs found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No Missional Communities are available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMcData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          ..._availableMcs.map((mc) => _buildMcCard(mc)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalMcs = _availableMcs.length;
    final mcsWithReports = _mcReports.values
        .where((reports) => reports.isNotEmpty)
        .length;
    final totalReports = _mcReports.values.fold(
      0,
      (sum, reports) => sum + reports.length,
    );

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MC Reports Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total MCs',
                  totalMcs.toString(),
                  Icons.groups,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Active MCs',
                  mcsWithReports.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Total Reports',
                  totalReports.toString(),
                  Icons.assignment,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMcCard(Map<String, dynamic> mc) {
    final mcId = mc['id'] as int;
    final mcName = mc['name'] as String;
    final reportCount = _getReportCountForMc(mcId);
    final statusColor = _getStatusColor(reportCount);
    final statusText = _getStatusText(reportCount);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToMcReportDetail(mc),
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
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.groups, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mcName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MC ID: $mcId',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
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

  void _navigateToMcReportDetail(Map<String, dynamic> mc) {
    final mcId = mc['id'] as int;
    final reports = _mcReports[mcId] ?? [];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => McReportDetailScreen(mc: mc, reports: reports),
      ),
    );
  }
}
