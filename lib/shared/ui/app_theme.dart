import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';

/// Eggy's complete design system — all tokens, text styles, and theme.
class AppTheme {
  // ── Text Styles ─────────────────────────────────────────────────────────────
  static TextStyle get display => GoogleFonts.playfairDisplay(
    fontSize: 34, fontWeight: FontWeight.w700,
    color: EggyColors.onyx, letterSpacing: -0.5,
  );

  static TextStyle get headline => GoogleFonts.playfairDisplay(
    fontSize: 24, fontWeight: FontWeight.w600,
    color: EggyColors.onyx,
  );

  static TextStyle get title => GoogleFonts.playfairDisplay(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: EggyColors.onyx,
  );

  static TextStyle get body => GoogleFonts.outfit(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: EggyColors.onyx,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 16, fontWeight: FontWeight.w500,
    color: EggyColors.onyx,
  );

  static TextStyle get caption => GoogleFonts.outfit(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: EggyColors.onyx.withValues(alpha: 0.5),
    letterSpacing: 0.2,
  );

  static TextStyle get timerDisplay => GoogleFonts.outfit(
    fontSize: 64, fontWeight: FontWeight.w200, // Ultra light
    color: EggyColors.onyx, letterSpacing: -3,
  );

  static TextStyle get yolkLabel => GoogleFonts.playfairDisplay(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: EggyColors.champagne,
  );

  // ── ThemeData ────────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: EggyColors.alabaster,
    colorScheme: ColorScheme.light(
      primary:    EggyColors.champagne,
      secondary:  EggyColors.slate,
      surface:    EggyColors.alabaster,
      onPrimary:  Colors.white,
      onSurface:  EggyColors.onyx,
    ),
    textTheme: GoogleFonts.outfitTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headline,
      iconTheme: const IconThemeData(color: EggyColors.onyx),
    ),
  );
}

/// Glassmorphism card decoration — refined 'Classy' look
BoxDecoration glassDecoration({
  double blur = 20,
  Color? borderColor,
  BorderRadius? borderRadius,
}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.7),
    borderRadius: borderRadius ?? BorderRadius.circular(16),
    border: Border.all(
      color: borderColor ?? Colors.black.withValues(alpha: 0.05),
      width: 0.5, // Hairline border
    ),
    boxShadow: [
      BoxShadow(
        color: EggyColors.shadowSoft,
        blurRadius: 32,
        offset: const Offset(0, 12),
        spreadRadius: -4,
      ),
    ],
  );
}
