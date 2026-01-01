import 'package:flutter/material.dart';
import '../core/widgets/zoe_button.dart';

/// Submit button component - now uses Project Zoe design system
/// Maintains backwards compatibility while using brand colors
class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;

  const SubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.backgroundColor, // Ignored - always uses brand colors
    this.textColor, // Ignored - always uses brand colors
    this.width,
    this.height = 50,
    this.borderRadius = 25,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return ZoeButton.secondary(
        label: text,
        onPressed: onPressed,
        width: width ?? double.infinity,
      );
    }
    return ZoeButton.primary(
      label: text,
      onPressed: onPressed,
      width: width ?? double.infinity,
    );
  }
}
