import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextStyle get headlineLg =>
      GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w700);

  static TextStyle get headlineMd =>
      GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700);

  static TextStyle get headlineSm =>
      GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle get bodyLg =>
      GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w400);

  static TextStyle get bodyMd =>
      GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle get bodySm =>
      GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400);

  static TextTheme get textTheme => TextTheme(
    headlineLarge: headlineLg,
    headlineMedium: headlineMd,
    headlineSmall: headlineSm,
    bodyLarge: bodyLg,
    bodyMedium: bodyMd,
    bodySmall: bodySm,
  );
}
