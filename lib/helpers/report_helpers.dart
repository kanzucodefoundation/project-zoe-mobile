// import 'package:flutter/material.dart';
// import '../models/report.dart';

// /// Helper functions for report-related operations
// // class ReportHelpers {
// //   /// Get color for report status
// //   static Color getStatusColor(ReportStatus status) {
// //     switch (status) {
// //       case ReportStatus.pending:
// //         return const Color(0xFFF59E0B); // Orange
// //       case ReportStatus.inProgress:
// //         return const Color(0xFF2563EB); // Blue
// //       case ReportStatus.completed:
// //         return const Color(0xFF059669); // Green
// //       case ReportStatus.cancelled:
// //         return const Color(0xFFEF4444); // Red
// //     }
// //   }

// //   /// Get color for report type
// //   static Color getTypeColor(ReportType type) {
// //     switch (type) {
// //       case ReportType.attendance:
// //         return const Color(0xFF8B5CF6); // Purple
// //       case ReportType.financial:
// //         return const Color(0xFF059669); // Green
// //       case ReportType.membership:
// //         return const Color(0xFF2563EB); // Blue
// //       case ReportType.events:
// //         return const Color(0xFFF59E0B); // Orange
// //       case ReportType.shepherds:
// //         return const Color(0xFFEF4444); // Red
// //       case ReportType.general:
// //         return const Color(0xFF6B7280); // Gray
// //     }
// //   }

// //   /// Get icon for report type
// //   static IconData getTypeIcon(ReportType type) {
// //     switch (type) {
// //       case ReportType.attendance:
// //         return Icons.people;
// //       case ReportType.financial:
// //         return Icons.attach_money;
// //       case ReportType.membership:
// //         return Icons.card_membership;
// //       case ReportType.events:
// //         return Icons.event;
// //       case ReportType.shepherds:
// //         return Icons.group;
// //       case ReportType.general:
// //         return Icons.description;
// //     }
// //   }

// //   /// Get color for priority level
// //   static Color getPriorityColor(int priority) {
// //     switch (priority) {
// //       case 1:
// //         return const Color(0xFF6B7280); // Gray - Low
// //       case 2:
// //         return const Color(0xFF2563EB); // Blue - Medium
// //       case 3:
// //         return const Color(0xFFF59E0B); // Orange - High
// //       case 4:
// //         return const Color(0xFFEF4444); // Red - Critical
// //       default:
// //         return const Color(0xFF2563EB); // Blue - Default
// //     }
// //   }

// //   /// Format date for display
// //   static String formatDate(DateTime date) {
// //     final now = DateTime.now();
// //     final difference = now.difference(date);

// //     if (difference.inDays == 0) {
// //       return 'Today';
// //     } else if (difference.inDays == 1) {
// //       return 'Yesterday';
// //     } else if (difference.inDays < 7) {
// //       return '${difference.inDays} days ago';
// //     } else {
// //       return '${date.day}/${date.month}/${date.year}';
// //     }
// //   }

// //   /// Format relative time
// //   static String formatRelativeTime(DateTime date) {
// //     final now = DateTime.now();
// //     final difference = now.difference(date);

// //     if (difference.inMinutes < 1) {
// //       return 'Just now';
// //     } else if (difference.inHours < 1) {
// //       return '${difference.inMinutes}m ago';
// //     } else if (difference.inDays < 1) {
// //       return '${difference.inHours}h ago';
// //     } else if (difference.inDays < 7) {
// //       return '${difference.inDays}d ago';
// //     } else if (difference.inDays < 30) {
// //       return '${(difference.inDays / 7).floor()}w ago';
// //     } else {
// //       return '${(difference.inDays / 30).floor()}mo ago';
// //     }
// //   }

// //   /// Get status icon
// //   static IconData getStatusIcon(ReportStatus status) {
// //     switch (status) {
// //       case ReportStatus.pending:
// //         return Icons.schedule;
// //       case ReportStatus.inProgress:
// //         return Icons.sync;
// //       case ReportStatus.completed:
// //         return Icons.check_circle;
// //       case ReportStatus.cancelled:
// //         return Icons.cancel;
// //     }
// //   }

// //   /// Calculate completion percentage (mock calculation)
// //   static double getCompletionPercentage(Report report) {
// //     switch (report.status) {
// //       case ReportStatus.pending:
// //         return 0.0;
// //       case ReportStatus.inProgress:
// //         // Mock calculation based on days since created
// //         final progress = (report.daysSinceCreated * 0.2).clamp(0.1, 0.8);
// //         return progress;
// //       case ReportStatus.completed:
// //         return 1.0;
// //       case ReportStatus.cancelled:
// //         return 0.0;
// //     }
// //   }

// //   /// Filter reports by status
// //   static List<Report> filterByStatus(
// //     List<Report> reports,
// //     ReportStatus status,
// //   ) {
// //     return reports.where((report) => report.status == status).toList();
// //   }

// //   /// Filter reports by type
// //   static List<Report> filterByType(List<Report> reports, ReportType type) {
// //     return reports.where((report) => report.type == type).toList();
// //   }

// //   /// Sort reports by priority
// //   static List<Report> sortByPriority(
// //     List<Report> reports, {
// //     bool descending = true,
// //   }) {
// //     final sortedReports = List<Report>.from(reports);
// //     sortedReports.sort((a, b) {
// //       return descending
// //           ? b.priority.compareTo(a.priority)
// //           : a.priority.compareTo(b.priority);
// //     });
// //     return sortedReports;
// //   }

// //   /// Sort reports by date
// //   static List<Report> sortByDate(
// //     List<Report> reports, {
// //     bool descending = true,
// //   }) {
// //     final sortedReports = List<Report>.from(reports);
// //     sortedReports.sort((a, b) {
// //       return descending
// //           ? b.createdAt.compareTo(a.createdAt)
// //           : a.createdAt.compareTo(b.createdAt);
// //     });
// //     return sortedReports;
// //   }

// //   /// Get overdue reports
// //   static List<Report> getOverdueReports(List<Report> reports) {
// //     return reports.where((report) => report.isOverdue).toList();
// //   }

// //   /// Get reports summary
// //   static Map<String, int> getReportsSummary(List<Report> reports) {
// //     return {
// //       'total': reports.length,
// //       'pending': reports.where((r) => r.status == ReportStatus.pending).length,
// //       'inProgress': reports
// //           .where((r) => r.status == ReportStatus.inProgress)
// //           .length,
// //       'completed': reports
// //           .where((r) => r.status == ReportStatus.completed)
// //           .length,
// //       'overdue': reports.where((r) => r.isOverdue).length,
// //     };
// //   }
// // }
