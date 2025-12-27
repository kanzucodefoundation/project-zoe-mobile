import 'package:flutter/material.dart';

class ClearFilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ClearFilterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Clear',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }
}
