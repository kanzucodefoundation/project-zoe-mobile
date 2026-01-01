import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Project Zoe typography system
/// Primary Font: Inter (UI elements, forms, buttons, data tables, body text)
/// Brand Font: DM Sans (Page headers, welcome screens, section titles)
class AppTextStyles {
  AppTextStyles._();

  // Brand Font Base (DM Sans)
  static TextStyle get _dmSansBase => GoogleFonts.dmSans(
        color: AppColors.primaryText,
      );

  // Primary Font Base (Inter)
  static TextStyle get _interBase => GoogleFonts.inter(
        color: AppColors.primaryText,
      );

  // Display - 32px / DM Sans Bold / Line: 38px
  static TextStyle get display => _dmSansBase.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 38 / 32,
        letterSpacing: -0.5,
      );

  // H1 - 28px / DM Sans Bold / Line: 34px  
  static TextStyle get h1 => _dmSansBase.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 34 / 28,
        letterSpacing: -0.5,
      );

  // H2 - 24px / DM Sans Bold / Line: 30px
  static TextStyle get h2 => _dmSansBase.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 30 / 24,
        letterSpacing: -0.25,
      );

  // H3 - 20px / DM Sans Medium / Line: 26px
  static TextStyle get h3 => _dmSansBase.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 26 / 20,
        letterSpacing: -0.25,
      );

  // Body Large - 17px / Inter Regular / Line: 26px
  static TextStyle get bodyLarge => _interBase.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 26 / 17,
        letterSpacing: 0,
      );

  // Body - 15px / Inter Regular / Line: 23px
  static TextStyle get body => _interBase.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 23 / 15,
        letterSpacing: 0,
      );

  // Label - 15px / Inter Medium / Line: 20px
  static TextStyle get label => _interBase.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 20 / 15,
        letterSpacing: 0.1,
      );

  // Caption - 13px / Inter Regular / Line: 18px
  static TextStyle get caption => _interBase.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18 / 13,
        letterSpacing: 0.1,
        color: AppColors.secondaryText,
      );

  // Small - 11px / Inter Medium / Line: 16px
  static TextStyle get small => _interBase.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 16 / 11,
        letterSpacing: 0.5,
        color: AppColors.secondaryText,
      );

  // Button Text - 15px / Inter SemiBold
  static TextStyle get button => _interBase.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 20 / 15,
        letterSpacing: 0.1,
      );

  // Stats Number - 28px / Inter SemiBold (for dashboard stats)
  static TextStyle get statsNumber => _interBase.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 34 / 28,
        letterSpacing: -0.25,
        color: AppColors.primaryText,
      );

  // TextTheme for Material Design 3
  static TextTheme get textTheme => TextTheme(
        displayLarge: display,
        displayMedium: display.copyWith(fontSize: 30),
        displaySmall: display.copyWith(fontSize: 26),
        headlineLarge: h1,
        headlineMedium: h2,
        headlineSmall: h3,
        titleLarge: h3.copyWith(fontWeight: FontWeight.w600),
        titleMedium: label.copyWith(fontSize: 16),
        titleSmall: label,
        bodyLarge: bodyLarge,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: button,
        labelMedium: label.copyWith(fontSize: 14),
        labelSmall: small,
      );

  // Themed variations
  static TextStyle get primaryButton => button.copyWith(
        color: AppColors.pureWhite,
      );

  static TextStyle get secondaryButton => button.copyWith(
        color: AppColors.primaryGreen,
      );

  static TextStyle get errorText => caption.copyWith(
        color: AppColors.error,
      );

  static TextStyle get successText => caption.copyWith(
        color: AppColors.success,
      );

  static TextStyle get warningText => caption.copyWith(
        color: AppColors.warning,
      );

  static TextStyle get sacredMomentText => label.copyWith(
        color: AppColors.harvestGold,
        fontWeight: FontWeight.w600,
      );
}