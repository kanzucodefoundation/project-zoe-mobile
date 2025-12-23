import 'package:flutter/material.dart';
import '../models/report.dart';
import '../helpers/report_helpers.dart';

/// Reusable report tile component for displaying report information
// class ReportTile extends StatelessWidget {
//   final Report report;
//   final VoidCallback? onTap;
//   final bool showStatusBadge;
//   final bool showProgress;

//   const ReportTile({
//     super.key,
//     required this.report,
//     this.onTap,
//     this.showStatusBadge = true,
//     this.showProgress = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header row with type badge and priority
//               Row(
//                 children: [
//                   // Type badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: ReportHelpers.getTypeColor(report.type),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           ReportHelpers.getTypeIcon(report.type),
//                           color: Colors.white,
//                           size: 14,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           report.typeDisplayName,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Spacer(),
//                   // Priority indicator
//                   Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: ReportHelpers.getPriorityColor(report.priority),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     report.priorityDisplayName,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Title and description
//               Text(
//                 report.title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 report.description,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey.shade700,
//                   height: 1.4,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),

//               // Progress bar (if enabled)
//               if (showProgress && report.status == ReportStatus.inProgress) ...[
//                 LinearProgressIndicator(
//                   value: ReportHelpers.getCompletionPercentage(report),
//                   backgroundColor: Colors.grey.shade200,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     ReportHelpers.getStatusColor(report.status),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '${(ReportHelpers.getCompletionPercentage(report) * 100).toInt()}% Complete',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//               ],

//               // Footer with status, date, and creator
//               Row(
//                 children: [
//                   // Status badge
//                   if (showStatusBadge)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: ReportHelpers.getStatusColor(
//                           report.status,
//                         ).withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: ReportHelpers.getStatusColor(report.status),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             ReportHelpers.getStatusIcon(report.status),
//                             size: 12,
//                             color: ReportHelpers.getStatusColor(report.status),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             report.statusDisplayName,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: ReportHelpers.getStatusColor(
//                                 report.status,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   const Spacer(),

//                   // Date and creator
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         ReportHelpers.formatDate(report.createdAt),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       if (report.createdBy.isNotEmpty)
//                         Text(
//                           'by ${report.createdBy}',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),

//               // Overdue indicator
//               if (report.isOverdue) ...[
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     borderRadius: BorderRadius.circular(6),
//                     border: Border.all(color: Colors.red.shade300, width: 1),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.warning, size: 12, color: Colors.red.shade600),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Overdue by ${report.daysSinceCreated - 7} days',
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.red.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
