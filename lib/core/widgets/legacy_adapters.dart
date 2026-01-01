import 'package:flutter/material.dart';
import 'zoe_button.dart';
import 'zoe_input.dart';

/// Adapter components to replace legacy custom components with Project Zoe design system
/// These maintain the same API as the old components for easier migration

// Replacement for LongButton - uses ZoeButton.primary
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
    this.backgroundColor,
    this.textColor,
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

// Replacement for SubmitButton - uses ZoeButton variants
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
    this.backgroundColor,
    this.textColor,
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