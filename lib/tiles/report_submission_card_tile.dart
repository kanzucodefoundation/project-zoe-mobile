import 'package:flutter/material.dart';

/// Reusable card tile for displaying report submissions
/// Similar to the ReportCard used on home screen but designed for submission data
class ReportSubmissionCardTile extends StatelessWidget {
  final Map<String, dynamic> submission;
  final Color themeColor;
  final VoidCallback? onTap;
  final String? title;
  final String? subtitle;
  final IconData? icon;

  const ReportSubmissionCardTile({
    super.key,
    required this.submission,
    required this.themeColor,
    this.onTap,
    this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data from submission
    final displayTitle = title ?? _getSubmissionTitle();
    final displaySubtitle = subtitle ?? _getSubmissionSubtitle();
    final displayIcon = icon ?? Icons.assignment_outlined;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () => _showSubmissionDetails(context),
      child: Container(
        height: 120,
        width: double.infinity,
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(displayIcon, size: 20, color: themeColor),
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                displayTitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Subtitle
              Text(
                displaySubtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSubmissionTitle() {
    // Try to get a meaningful title from the submission data
    if (submission['serviceName'] != null) {
      return submission['serviceName'].toString();
    }

    if (submission['data'] != null && submission['data'] is Map) {
      final data = submission['data'] as Map<String, dynamic>;

      // Try common field names
      for (final key in ['name', 'title', 'service', 'event']) {
        if (data[key] != null) {
          String value = data[key].toString();
          if (value.length > 15) {
            value = '${value.substring(0, 12)}...';
          }
          return value;
        }
      }

      // If no specific field, use first non-empty value
      final firstValue = data.values.firstWhere(
        (value) => value != null && value.toString().isNotEmpty,
        orElse: () => null,
      );

      if (firstValue != null) {
        String value = firstValue.toString();
        if (value.length > 15) {
          value = '${value.substring(0, 12)}...';
        }
        return value;
      }
    }

    return 'Report Submission';
  }

  String _getSubmissionSubtitle() {
    final date = _getSubmissionDate();
    final attendance = submission['totalAttendance']?.toString();

    if (date != null && attendance != null) {
      return '$date • $attendance attended';
    } else if (date != null) {
      return date;
    } else if (attendance != null) {
      return '$attendance attended';
    }

    return 'Tap to view details';
  }

  String? _getSubmissionDate() {
    // Try different date field names
    for (final field in ['date', 'serviceDate', 'submittedAt', 'createdAt']) {
      if (submission[field] != null) {
        final dateStr = submission[field].toString();
        try {
          final date = DateTime.parse(dateStr);
          return '${date.day}/${date.month}/${date.year}';
        } catch (e) {
          // If parsing fails, return the string as is if it's short
          if (dateStr.length < 20) {
            return dateStr;
          }
        }
      }
    }
    return null;
  }

  void _showSubmissionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Submission Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: _buildDetailItems(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetailItems() {
    final List<Widget> items = [];

    // Add main submission data
    submission.forEach((key, value) {
      if (key != 'data' && value != null) {
        items.add(_buildDetailItem(key, value.toString()));
      }
    });

    // Add nested data if available
    if (submission['data'] != null && submission['data'] is Map) {
      items.add(const SizedBox(height: 16));
      items.add(
        const Text(
          'Form Data',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );
      items.add(const SizedBox(height: 8));
      items.add(const Divider());
      items.add(const SizedBox(height: 8));

      final data = submission['data'] as Map<String, dynamic>;
      data.forEach((key, value) {
        if (value != null) {
          items.add(_buildDetailItem(key, value.toString()));
        }
      });
    }

    return items;
  }

  Widget _buildDetailItem(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key
                .replaceAll('_', ' ')
                .split(' ')
                .map(
                  (word) => word.isEmpty
                      ? ''
                      : word[0].toUpperCase() + word.substring(1),
                )
                .join(' '),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
