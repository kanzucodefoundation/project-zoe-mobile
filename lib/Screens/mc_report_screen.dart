import 'package:flutter/material.dart';
import '../Screens/mc_reports_display_screen.dart';
import '../services/report_service.dart';

class McReportScreen extends StatefulWidget {
  const McReportScreen({super.key});

  @override
  State<McReportScreen> createState() => _McReportScreenState();
}

class _McReportScreenState extends State<McReportScreen> {
  bool _isLoading = true;
  String? _mcReportTemplateId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMcReportTemplate();
  }

  Future<void> _loadMcReportTemplate() async {
    try {
      // Get the MC report template ID from the server
      final templates = await ReportService.getReportTemplates();
      final mcTemplate = templates.firstWhere(
        (template) =>
            template.name.toLowerCase().contains('mc') ||
            template.name.toLowerCase().contains('missional'),
        orElse: () => throw Exception('MC template not found'),
      );

      setState(() {
        _mcReportTemplateId = mcTemplate.id.toString();
        _isLoading = false;
      });

      // Navigate to the MC reports display screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => McReportsScreen(reportId: _mcReportTemplateId!),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Error loading MC report: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'MC Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading MC Report...'),
                ],
              )
            : _error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _loadMcReportTemplate();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}
