/// Project Zoe spacing constants for consistent layout
class AppSpacing {
  AppSpacing._();

  // Base spacing units
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Screen-level spacing
  static const double screenPadding = lg; // 16px
  static const double screenMargin = xl; // 20px

  // Component spacing
  static const double cardPadding = lg; // 16px
  static const double cardMargin = md; // 12px
  static const double cardRadius = md; // 12px

  // Button spacing
  static const double buttonHeight = 48.0;
  static const double buttonPaddingHorizontal = xl; // 20px
  static const double buttonPaddingVertical = md; // 12px
  static const double buttonRadius = md; // 12px

  // Input field spacing
  static const double inputPaddingHorizontal = lg; // 16px
  static const double inputPaddingVertical = md; // 12px
  static const double inputRadius = sm; // 8px

  // List item spacing
  static const double listItemPadding = lg; // 16px
  static const double listItemSpacing = sm; // 8px

  // Section spacing
  static const double sectionSpacing = xxl; // 24px
  static const double sectionTitleSpacing = lg; // 16px

  // Icon sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  // Bottom navigation
  static const double bottomNavHeight = 60.0;
  static const double bottomNavIconSize = iconLg; // 24px

  // App bar
  static const double appBarHeight = 56.0;
  static const double appBarIconSize = iconLg; // 24px

  // Stat cards
  static const double statCardHeight = 80.0;
  static const double statCardPadding = lg; // 16px
  static const double statCardSpacing = md; // 12px

  // Elevation values
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationModal = 16.0;
}