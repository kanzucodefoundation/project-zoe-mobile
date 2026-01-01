import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Project Zoe branded card widget
/// White card with subtle border, rounded corners and optional shadow
class ZoeCard extends StatelessWidget {
  const ZoeCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.onTap,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget cardWidget = Card(
      margin: margin ?? const EdgeInsets.all(AppSpacing.cardMargin),
      color: backgroundColor ?? AppColors.cardBackground,
      elevation: elevation ?? AppSpacing.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(
          color: AppColors.softBorders,
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

/// Specialized card for displaying statistics
class ZoeStatCard extends StatelessWidget {
  const ZoeStatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ZoeCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm, // Reduced vertical padding
      ),
      child: IntrinsicHeight( // Use intrinsic height instead of fixed height
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: AppSpacing.iconSm,
                    color: valueColor ?? AppColors.primaryText,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: valueColor ?? AppColors.primaryText,
                          fontSize: 24, // Reduced font size slightly
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 12, // Slightly smaller font
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}