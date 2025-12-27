import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final String reportTitle;
  final IconData reportIcon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  // final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.reportTitle,
    required this.reportIcon,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blue).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                reportIcon,
                size: 24,
                color: iconColor ?? Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reportTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
