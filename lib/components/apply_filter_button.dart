import 'package:flutter/material.dart';

class ApplyFilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ApplyFilterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: const Text(
        'Apply Filter',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
