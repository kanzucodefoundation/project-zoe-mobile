import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mc_report_provider.dart';
import '../widgets/mc_report_tiles.dart';

/// Simplified MC Reports Display Screen using Provider and Custom Tiles
class McReportsDisplayScreen extends StatefulWidget {
  final String reportId;
  const McReportsDisplayScreen({super.key, required this.reportId});

  @override
  State<McReportsDisplayScreen> createState() => _McReportsDisplayScreenState();
}

class _McReportsDisplayScreenState extends State<McReportsDisplayScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<McReportProvider>();
      provider.loadReportData(widget.reportId);
      provider.loadAvailableMcs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<McReportProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              provider.reportTemplate?.name ?? 'MC Report',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: provider.isLoading
              ? _buildLoadingView()
              : provider.error != null
                  ? _buildErrorView(provider.error!)
                  : _buildFormView(provider),
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading MC Report Template...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(McReportProvider provider) {
    final reportTemplate = provider.reportTemplate!;
    final visibleFields = reportTemplate.fields.where((field) => !field.hidden).toList();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Header
            ReportHeaderTile(reportTemplate: reportTemplate),

            // Form Instructions
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Complete the form below to submit your MC report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // MC Selection Dropdown
            McSelectionTile(
              availableMcs: provider.availableMcs,
              selectedMcId: provider.selectedMcId,
              isLoading: provider.isLoadingMcs,
              onMcSelected: (mcId, mcName) {
                provider.setSelectedMc(mcId, mcName);
              },
            ),

            // Date Selection
            DateSelectionTile(
              selectedDate: provider.selectedDate,
              onDateSelected: (date) {
                provider.setSelectedDate(date);
              },
            ),

            // Form Fields
            ...visibleFields.map((field) {
              return FormFieldTile(
                field: field,
                value: provider.fieldValues[field.id] ?? '',
                onChanged: (value) {
                  provider.updateFieldValue(field.id, value);
                },
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}