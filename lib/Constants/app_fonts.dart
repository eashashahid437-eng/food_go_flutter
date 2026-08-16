import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static TextStyle lobster({
    double fontSize = 60,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.lobster(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.0,
      letterSpacing: 0,
    );
  }

  static TextStyle poppinsMedium({
    double fontSize = 18,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: 1.0,
      letterSpacing: 0,
    );
  }
}