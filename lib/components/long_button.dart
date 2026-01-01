import 'package:flutter/material.dart';
import '../core/widgets/zoe_button.dart';

/// Long button component - now uses Project Zoe design system
/// Maintains backwards compatibility while using brand colors
class LongButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? borderRadius;

  const LongButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor, // Ignored - always uses brand colors
    this.textColor, // Ignored - always uses brand colors
    this.height = 50,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ZoeButton.primary(
      label: text,
      onPressed: onPressed,
      isLoading: isLoading,
      width: double.infinity,
    );
  }
}
