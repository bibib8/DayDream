import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // 1. Bodoni Moda - Editorial headlines
  static TextStyle editorial({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.deepNavy,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.bodoniModa(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
    );
  }

  // 2. Great Vibes - Cursive romantic leads
  static TextStyle script({
    double fontSize = 26,
    Color color = AppColors.denimBlue,
  }) {
    return GoogleFonts.greatVibes(
      fontSize: fontSize,
      color: color,
    );
  }

  // 3. Cormorant Garamond - Classic book serif & quotes
  static TextStyle serif({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.deepNavy,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
    );
  }

  // 4. DM Sans - Main body, buttons, and navigation
  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.deepNavy,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      decoration: decoration,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
    );
  }

  // 5. Caveat - Playful handwriting
  static TextStyle handwriting({
    double fontSize = 20,
    Color color = AppColors.deepNavy,
  }) {
    return GoogleFonts.caveat(
      fontSize: fontSize,
      color: color,
    );
  }
}
