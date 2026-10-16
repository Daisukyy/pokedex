import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const plum = Color(0xFF6B4E71);
  static const accent = Color(0xFFFF6FAE);
  static const purple = Color(0xFF8B6BB1);
  static const warmWhite = Color(0xFFFFFCFE);
  static const cream = Color(0xFFFFF8F3);
  static const sakura = Color(0xFFFFD6E8);
  static const lavender = Color(0xFFE6D9FF);
  static const mint = Color(0xFFD4F5E9);
  static const peach = Color(0xFFFFE5D0);
  static const sky = Color(0xFFD6EEFF);
  static const butter = Color(0xFFFFF4B8);

  static Color typeColor(String? type) =>
      <String, Color>{
        'Normal': peach,
        'Fuego': peach,
        'Agua': sky,
        'Planta': mint,
        'Eléctrico': butter,
        'Hielo': sky,
        'Lucha': peach,
        'Veneno': lavender,
        'Tierra': peach,
        'Volador': lavender,
        'Psíquico': sakura,
        'Bicho': mint,
        'Roca': peach,
        'Fantasma': lavender,
        'Dragón': lavender,
        'Siniestro': lavender,
        'Acero': sky,
        'Hada': sakura,
      }[type] ??
      lavender;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.fromSeed(seedColor: sakura).copyWith(
      primary: plum,
      onPrimary: Colors.white,
      surface: cream,
      onSurface: plum,
    ),
    textTheme: GoogleFonts.nunitoTextTheme().apply(
      bodyColor: plum,
      displayColor: plum,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: plum,
      elevation: 0,
      titleTextStyle: GoogleFonts.fredoka(
        color: plum,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
