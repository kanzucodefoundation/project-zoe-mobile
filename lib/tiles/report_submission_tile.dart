import 'package:flutter/material.dart';

class ReportSubmissionTile extends StatelessWidget {
  final Map<String, dynamic> submission;
  final Color themeColor;

  const ReportSubmissionTile({
    super.key,
    required this.submission,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final submissionDate =
        submission['date'] ??
        submission['submittedAt'] ??
        DateTime.now().toString();
    final submittedBy = submission['submittedBy'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showSubmissionDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment_turned_in,
                    color: themeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(submissionDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submitted by: $submittedBy',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      if (submission['count'] != null ||
                          submission['salvationCount'] != null)
                        Text(
                          'Count: ${submission['count'] ?? submission['salvationCount'] ?? 0}',
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showSubmissionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.assignment_turned_in,
                        color: themeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Submission Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _formatDate(
                              submission['date'] ??
                                  submission['submittedAt'] ??
                                  '',
                            ),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: () {
                      // Get the data from submission
                      final data = submission['data'] ?? submission;
                      final template = submission['template'];

                      if (data is Map<String, dynamic>) {
                        return data.entries
                            .where(
                              (entry) =>
                                  ![
                                    'smallGroupId',
                                    'template',
                                    'id',
                                    'reportId',
                                    'createdAt',
                                    'updatedAt',
                                    'groupId',
                                  ].contains(entry.key) &&
                                  entry.value != null &&
                                  entry.value.toString().isNotEmpty,
                            )
                            .map((entry) {
                              final fieldLabel = _getFieldLabel(
                                entry.key,
                                template,
                              );
                              return _buildDetailRow(fieldLabel, entry.value);
                            })
                            .toList();
                      }

                      // Fallback to submission entries
                      return submission.entries
                          .where(
                            (entry) =>
                                ![
                                  'smallGroupId',
                                  'template',
                                  'data',
                                  'id',
                                  'reportId',
                                  'createdAt',
                                  'updatedAt',
                                  'groupId',
                                ].contains(entry.key) &&
                                entry.value != null &&
                                entry.value.toString().isNotEmpty,
                          )
                          .map((entry) {
                            final fieldLabel = _getFieldLabel(
                              entry.key,
                              template,
                            );
                            return _buildDetailRow(fieldLabel, entry.value);
                          })
                          .toList();
                    }(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    // Format value based on field type
    String displayValue = value.toString();

    // Format date fields
    if (label.toLowerCase().contains('date') && displayValue.contains('-')) {
      try {
        final date = DateTime.parse(displayValue);
        displayValue = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        // Keep original value if parsing fails
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              fontSize: 14,
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
              displayValue,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _getFieldLabel(String key, dynamic template) {
    // Try to get label from template fields
    if (template != null && template['fields'] != null) {
      final fields = template['fields'] as List;

      for (var field in fields) {
        if (field['name'] == key && field['label'] != null) {
          return field['label'];
        }
      }
    }

    // Fallback to formatted field name if template not available
    return _formatLabel(key);
  }

  String _formatLabel(String key) {
    // Handle specific field names for better formatting
    final specificLabels = {
      'salvationDate': 'Date',
      'numberOfSalvations': 'Number of Salvations',
      'savedNames': 'Names of Those Who Gave Their Lives to Christ',
      'salvationContext': 'Context',
      'followUpPlan': 'Follow-up Plan',
      'date': 'Date',
      'submittedAt': 'Submitted At',
      'submittedBy': 'Submitted By',
    };

    if (specificLabels.containsKey(key)) {
      return specificLabels[key]!;
    }

    // Fallback to formatted field name if not in specific labels
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ')
        .trim();
  }
}
