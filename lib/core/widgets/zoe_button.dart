import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Project Zoe branded button widget with three variants:
/// - Primary: Filled with Living Emerald background
/// - Secondary: Outlined with Living Emerald border
/// - Text: No background, green text only
class ZoeButton extends StatelessWidget {
  const ZoeButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.width,
  }) : _variant = _ButtonVariant.primary;

  const ZoeButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.width,
  }) : _variant = _ButtonVariant.secondary;

  const ZoeButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.width,
  }) : _variant = _ButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final _ButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || isLoading || onPressed == null;

    return SizedBox(
      width: width,
      height: AppSpacing.buttonHeight,
      child: _buildButton(context, isDisabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    switch (_variant) {
      case _ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          child: _buildButtonContent(),
        );
      case _ButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          child: _buildButtonContent(),
        );
      case _ButtonVariant.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          child: _buildButtonContent(),
        );
    }
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _variant == _ButtonVariant.primary
                    ? AppColors.pureWhite
                    : AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}

enum _ButtonVariant { primary, secondary, text }