import 'package:flutter/material.dart';

/// Project Zoe brand colors and design system colors
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Brand Colors
  /// Living Emerald - Primary action color
  /// Use for: Primary buttons, active states, submit actions, navigation highlights
  /// Meaning: Life, growth, action
  static const Color primaryGreen = Color(0xFF2DB464);

  /// Zoe Deep - Authority color
  /// Use for: Headers, primary text, navigation bars, data emphasis
  /// Meaning: Rooted, established, shepherding authority
  static const Color zoeDeep = Color(0xFF1B3022);

  /// Growth Tint - Support color
  /// Use for: Borders, secondary icons, hover states, light backgrounds
  /// Meaning: Gentle growth, supporting elements
  static const Color growthTint = Color(0xFFA8DAB5);

  // Warm Accent
  /// Harvest Gold - Sacred moments color
  /// Use for: Salvation indicators, baptism badges, milestone celebrations, special achievements
  /// Use sparingly - Only for spiritually significant moments
  /// Meaning: Fruitfulness, harvest, God's glory, celebration
  static const Color harvestGold = Color(0xFFD6B25E);

  // Backgrounds
  /// Soft Sage - Main background color
  /// Use for: App background (easier on eyes than white, especially in bright environments)
  static const Color softSage = Color(0xFFF1F7F3);

  /// Pure White - Cards and inputs background
  /// Use for: Cards, input fields, modals on sage background
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Neutrals
  /// Slate Gray - Secondary text color
  /// Use for: Secondary text, captions, timestamps, helper text
  static const Color slateGray = Color(0xFF6B7280);

  /// Soft Borders - Border color
  /// Use for: Dividers, card borders, input borders
  static const Color softBorders = Color(0xFFE5E7EB);

  // Status Colors
  /// Success color - uses primary green
  static const Color success = primaryGreen;

  /// Warning color
  static const Color warning = Color(0xFFF59E0B);

  /// Error color
  static const Color error = Color(0xFFEF4444);

  /// Info color
  static const Color info = Color(0xFF3B82F6);

  // Material Design 3 ColorScheme
  static ColorScheme get lightColorScheme => ColorScheme(
        brightness: Brightness.light,
        primary: primaryGreen,
        onPrimary: pureWhite,
        primaryContainer: growthTint,
        onPrimaryContainer: zoeDeep,
        secondary: growthTint,
        onSecondary: zoeDeep,
        secondaryContainer: softSage,
        onSecondaryContainer: zoeDeep,
        tertiary: harvestGold,
        onTertiary: zoeDeep,
        tertiaryContainer: harvestGold.withOpacity(0.1),
        onTertiaryContainer: zoeDeep,
        error: error,
        onError: pureWhite,
        errorContainer: error.withOpacity(0.1),
        onErrorContainer: error,
        surface: pureWhite,
        onSurface: zoeDeep,
        surfaceContainerHighest: softSage,
        onSurfaceVariant: slateGray,
        outline: softBorders,
        outlineVariant: softBorders.withOpacity(0.5),
        shadow: zoeDeep.withOpacity(0.1),
        scrim: zoeDeep.withOpacity(0.5),
        inverseSurface: zoeDeep,
        onInverseSurface: pureWhite,
        inversePrimary: growthTint,
        surfaceTint: primaryGreen,
      );

  // Helper methods for common use cases
  static Color get scaffoldBackground => softSage;
  static Color get cardBackground => pureWhite;
  static Color get primaryText => zoeDeep;
  static Color get secondaryText => slateGray;
  static Color get divider => softBorders;
  static Color get primaryAction => primaryGreen;
  static Color get sacredMoment => harvestGold;
}