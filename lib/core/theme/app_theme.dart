import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wedly/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.gold,
        secondary: AppColors.black,
        surface: AppColors.white,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: AppColors.white,

      // تطبيق خط Readex Pro على كامل التطبيق
      fontFamily: GoogleFonts.readexPro().fontFamily,

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        titleTextStyle: GoogleFonts.readexPro(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        filled: true,
        fillColor: AppColors.greyLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.readexPro(
          color: AppColors.grey,
        ),
        labelStyle: GoogleFonts.readexPro(
          color: AppColors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: GoogleFonts.readexPro(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.black,
          textStyle: GoogleFonts.readexPro(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.readexPro(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        headlineMedium: GoogleFonts.readexPro(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        titleLarge: GoogleFonts.readexPro(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleMedium: GoogleFonts.readexPro(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleSmall: GoogleFonts.readexPro(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        bodyLarge: GoogleFonts.readexPro(
          fontSize: 16,
          color: AppColors.black,
        ),
        bodyMedium: GoogleFonts.readexPro(
          fontSize: 14,
          color: AppColors.black,
        ),
        bodySmall: GoogleFonts.readexPro(
          fontSize: 12,
          color: AppColors.black,
        ),
        labelLarge: GoogleFonts.readexPro(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        labelMedium: GoogleFonts.readexPro(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        labelSmall: GoogleFonts.readexPro(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.white,
        surface: Colors.grey[900]!,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: Colors.grey[900],

      // تطبيق خط Readex Pro على الوضع الليلي أيضاً
      fontFamily: GoogleFonts.readexPro().fontFamily,

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.readexPro(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        hintStyle: GoogleFonts.readexPro(),
        labelStyle: GoogleFonts.readexPro(),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.readexPro(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.readexPro(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.readexPro(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.readexPro(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.readexPro(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.readexPro(
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.readexPro(
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.readexPro(
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.readexPro(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.readexPro(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.readexPro(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
