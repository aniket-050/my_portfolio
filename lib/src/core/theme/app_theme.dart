import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final bodyTheme = GoogleFonts.manropeTextTheme(base.textTheme);
    final headingTheme = GoogleFonts.spaceGroteskTextTheme(bodyTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppPalette.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppPalette.cobalt,
        secondary: AppPalette.coral,
        surface: AppPalette.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppPalette.ink,
      ),
      textTheme: headingTheme.copyWith(
        displayLarge: headingTheme.displayLarge?.copyWith(
          color: AppPalette.ink,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.8,
        ),
        displayMedium: headingTheme.displayMedium?.copyWith(
          color: AppPalette.ink,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.4,
        ),
        headlineLarge: headingTheme.headlineLarge?.copyWith(
          color: AppPalette.ink,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
        headlineMedium: headingTheme.headlineMedium?.copyWith(
          color: AppPalette.ink,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        titleLarge: bodyTheme.titleLarge?.copyWith(
          color: AppPalette.ink,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: bodyTheme.titleMedium?.copyWith(
          color: AppPalette.ink,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: bodyTheme.bodyLarge?.copyWith(
          color: AppPalette.ink.withValues(alpha: 0.86),
          height: 1.6,
        ),
        bodyMedium: bodyTheme.bodyMedium?.copyWith(
          color: AppPalette.ink.withValues(alpha: 0.74),
          height: 1.6,
        ),
        labelLarge: bodyTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppPalette.line),
        ),
      ),
    );
  }
}
