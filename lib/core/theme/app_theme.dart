import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BankerTrader design tokens — warm-neutral ground, soft cards, one calm
/// accent. Shared by every screen so the app reads as one system instead of
/// per-screen Material defaults.
abstract final class AppColors {
  static const background = Color(0xFFF3F1EC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFEDE7D9);
  static const border = Color(0xFFE2DAC8);

  static const textPrimary = Color(0xFF1B2430);
  static const textMuted = Color(0xFF8A7F6B);

  /// Brand accent — used for primary actions, links and the active nav item.
  static const accent = Color(0xFF1E8E5A);
  static const accentSoft = Color(0xFFDCEEE2);

  /// Secondary accent for informational badges (e.g. a connected broker).
  static const info = Color(0xFF4A5FD9);
  static const infoSoft = Color(0xFFE6E9FB);

  /// Pending / paper-mode state.
  static const warning = Color(0xFFB8862F);
  static const warningSoft = Color(0xFFF3E7D2);

  static const positive = Color(0xFF1E8E5A);
  static const positiveSoft = Color(0xFFE4F5EC);
  static const negative = Color(0xFFC4453D);
  static const negativeSoft = Color(0xFFFBE9E9);

  static const error = negative;
}

abstract final class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
}

abstract final class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const pill = 999.0;
}

/// Fraunces for numbers/headlines, IBM Plex Sans for everything else.
abstract final class AppFonts {
  static TextStyle display({
    double size = 28,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) => GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
    letterSpacing: -0.4,
  );

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) => GoogleFonts.ibmPlexSans(
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
  );

  /// Tabular-figure body style for money/quantities so columns align.
  static TextStyle number({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) => GoogleFonts.ibmPlexSans(
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

/// Indian digit grouping: ₹2,45,680 instead of ₹245680.
String inr(num value, {bool decimals = false}) {
  final isNegative = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals ? 2 : 0);
  final parts = fixed.split('.');
  var whole = parts[0];
  final frac = parts.length > 1 ? '.${parts[1]}' : '';

  String grouped;
  if (whole.length <= 3) {
    grouped = whole;
  } else {
    final last3 = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final buffer = StringBuffer();
    while (rest.length > 2) {
      buffer.write(',${rest.substring(rest.length - 2)}');
      rest = rest.substring(0, rest.length - 2);
    }
    grouped = '$rest${buffer.toString()},$last3';
  }
  return '${isNegative ? '−' : ''}₹$grouped$frac';
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
  );

  final bodyFont = GoogleFonts.ibmPlexSansTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: bodyFont.copyWith(
      headlineMedium: AppFonts.display(size: 26),
      headlineSmall: AppFonts.display(size: 21),
      titleLarge: AppFonts.body(size: 17, weight: FontWeight.w600),
      titleMedium: AppFonts.body(size: 15, weight: FontWeight.w600),
      bodyMedium: AppFonts.body(size: 14, color: AppColors.textPrimary),
      bodySmall: AppFonts.body(size: 12.5, color: AppColors.textMuted),
      labelSmall: AppFonts.body(
        size: 11,
        weight: FontWeight.w600,
        color: AppColors.textMuted,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: AppFonts.display(size: 20),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textMuted,
      textColor: AppColors.textPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.lg,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
      ),
      labelStyle: AppFonts.body(size: 14, color: AppColors.textMuted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: AppFonts.body(size: 15, weight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: AppFonts.body(size: 14, weight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      space: 1,
      thickness: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: AppColors.accentSoft,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppFonts.body(
          size: 11.5,
          weight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? AppColors.textPrimary
              : AppColors.textMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.textMuted,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      titleTextStyle: AppFonts.display(size: 19),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppFonts.body(size: 13.5, color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
  );
}
