import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary      = Color(0xFF6C63FF);
  static const Color accent       = Color(0xFFFF6B6B);
  static const Color liveRed      = Color(0xFFFF4757);
  static const Color speakerGreen = Color(0xFF2ED573);
  static const Color bgDark       = Color(0xFF0A0A0F);
  static const Color surface      = Color(0xFF12121A);
  static const Color card         = Color(0xFF1A1A26);
  static const Color border       = Color(0xFF2A2A3E);
  static const Color textPri      = Color(0xFFFFFFFF);
  static const Color textSec      = Color(0xFF8888AA);
  static const Color textHint     = Color(0xFF555570);

  // Aliases
  static const Color primaryColor   = primary;
  static const Color accentColor    = accent;
  static const Color liveColor      = liveRed;
  static const Color backgroundDark = bgDark;
  static const Color surfaceColor   = surface;
  static const Color cardColor      = card;
  static const Color borderColor    = border;
  static const Color textPrimary    = textPri;
  static const Color textSecondary  = textSec;

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary, secondary: accent,
      surface: surface, background: bgDark, error: accent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark, elevation: 0, centerTitle: true,
      iconTheme: IconThemeData(color: textPri),
      titleTextStyle: TextStyle(color: textPri, fontSize: 18, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: accent)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: accent, width: 1.5)),
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
      labelStyle: const TextStyle(color: textSec),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primary),
    ),
    cardTheme: CardThemeData(
      color: card, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    dividerColor: border,
    iconTheme: const IconThemeData(color: textPri),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary, foregroundColor: Colors.white),
  );
}
