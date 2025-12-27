import 'package:flutter/material.dart';

class EditReportButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;

  const EditReportButton({super.key, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      icon: const Icon(Icons.edit, size: 18),
      label: const Text(
        'Edit Report',
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}
