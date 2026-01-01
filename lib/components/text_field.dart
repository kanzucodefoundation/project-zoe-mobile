import 'package:flutter/material.dart';
import '../core/widgets/zoe_input.dart';
import '../core/theme/app_colors.dart';

/// Custom text field component - now uses Project Zoe design system
/// Maintains backwards compatibility while using brand colors
class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    // For password fields with visibility toggle
    if (widget.obscureText) {
      return ZoeInput(
        label: '', // No label since hintText is used
        hint: widget.hintText,
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        obscureText: _obscure,
        maxLines: 1,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.secondaryText)
            : null,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.secondaryText,
          ),
          onPressed: () {
            setState(() => _obscure = !_obscure);
          },
        ),
      );
    }

    // For regular text fields
    return ZoeInput(
      label: '', // No label since hintText is used
      hint: widget.hintText,
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      prefixIcon: widget.prefixIcon != null
          ? Icon(widget.prefixIcon, color: AppColors.secondaryText)
          : null,
    );
  }
}
