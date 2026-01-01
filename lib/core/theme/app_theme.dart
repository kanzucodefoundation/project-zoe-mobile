import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

/// Project Zoe main theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.lightColorScheme,
        textTheme: AppTextStyles.textTheme,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        
        // App Bar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.scaffoldBackground,
          foregroundColor: AppColors.primaryText,
          surfaceTintColor: Colors.transparent,
          elevation: AppSpacing.elevationNone,
          centerTitle: false,
          titleTextStyle: AppTextStyles.h3,
          iconTheme: const IconThemeData(
            color: AppColors.zoeDeep,
            size: AppSpacing.appBarIconSize,
          ),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          surfaceTintColor: Colors.transparent,
          elevation: AppSpacing.elevationLow,
          margin: const EdgeInsets.all(AppSpacing.cardMargin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            side: BorderSide(
              color: AppColors.softBorders,
              width: 1,
            ),
          ),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAction,
            foregroundColor: AppColors.pureWhite,
            disabledBackgroundColor: AppColors.slateGray,
            disabledForegroundColor: AppColors.pureWhite,
            elevation: AppSpacing.elevationLow,
            shadowColor: AppColors.primaryAction.withOpacity(0.3),
            minimumSize: const Size(0, AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingHorizontal,
              vertical: AppSpacing.buttonPaddingVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            textStyle: AppTextStyles.primaryButton,
          ),
        ),

        // Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryAction,
            disabledForegroundColor: AppColors.slateGray,
            side: const BorderSide(
              color: AppColors.primaryGreen,
              width: 1,
            ),
            minimumSize: const Size(0, AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingHorizontal,
              vertical: AppSpacing.buttonPaddingVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            textStyle: AppTextStyles.secondaryButton,
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryAction,
            disabledForegroundColor: AppColors.slateGray,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            textStyle: AppTextStyles.secondaryButton,
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.inputPaddingHorizontal,
            vertical: AppSpacing.inputPaddingVertical,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.softBorders),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.softBorders),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          labelStyle: AppTextStyles.label.copyWith(
            color: AppColors.secondaryText,
          ),
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.secondaryText,
          ),
          errorStyle: AppTextStyles.errorText,
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.cardBackground,
          selectedItemColor: AppColors.primaryAction,
          unselectedItemColor: AppColors.secondaryText,
          type: BottomNavigationBarType.fixed,
          elevation: AppSpacing.elevationMedium,
          selectedLabelStyle: AppTextStyles.label.copyWith(
            fontSize: 12,
            color: AppColors.primaryAction,
          ),
          unselectedLabelStyle: AppTextStyles.caption.copyWith(
            fontSize: 12,
          ),
        ),

        // List Tile Theme
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.listItemPadding,
            vertical: AppSpacing.sm,
          ),
          titleTextStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w500,
          ),
          subtitleTextStyle: AppTextStyles.caption,
        ),

        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: AppColors.softBorders,
          thickness: 1,
          space: 1,
        ),

        // Icon Theme
        iconTheme: const IconThemeData(
          color: AppColors.slateGray,
          size: AppSpacing.iconMd,
        ),

        // Primary Icon Theme (for app bars, etc.)
        primaryIconTheme: const IconThemeData(
          color: AppColors.zoeDeep,
          size: AppSpacing.iconMd,
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.pureWhite,
          elevation: AppSpacing.elevationMedium,
        ),

        // Dialog Theme
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.cardBackground,
          surfaceTintColor: Colors.transparent,
          elevation: AppSpacing.elevationModal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          titleTextStyle: AppTextStyles.h3,
          contentTextStyle: AppTextStyles.body,
        ),

        // Snackbar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.zoeDeep,
          contentTextStyle: AppTextStyles.body.copyWith(
            color: AppColors.pureWhite,
          ),
          actionTextColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.growthTint.withOpacity(0.3),
          deleteIconColor: AppColors.secondaryText,
          disabledColor: AppColors.softBorders,
          selectedColor: AppColors.primaryGreen,
          secondarySelectedColor: AppColors.growthTint,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          labelStyle: AppTextStyles.label.copyWith(fontSize: 13),
          secondaryLabelStyle: AppTextStyles.label.copyWith(
            fontSize: 13,
            color: AppColors.pureWhite,
          ),
          brightness: Brightness.light,
        ),
      );
}