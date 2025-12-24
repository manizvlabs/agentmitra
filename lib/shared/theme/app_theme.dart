/// Application Theme Configuration
/// Unified VyaptIX Theme - Matching VyaptIX Logo Colors
import 'package:flutter/material.dart';

class AppTheme {
  // VyaptIX Primary Colors (Blue Gradient Theme)
  static const Color vyaptixBlue = Color(0xFF0083B0); // Primary blue
  static const Color vyaptixBlueLight = Color(0xFF00B4DB); // Light cyan-blue
  static const Color vyaptixBlueDark = Color(0xFF005C8A); // Darker blue
  
  // VyaptIX Gradient Colors (from logo)
  static const Color vyaptixGreen = Color(0xFF00D4AA); // Green accent
  static const Color vyaptixYellow = Color(0xFFFFD700); // Yellow
  static const Color vyaptixOrange = Color(0xFFFF8C00); // Orange
  static const Color vyaptixRed = Color(0xFFFF4500); // Red

  // Legacy Red Colors (for backward compatibility with existing screens)
  static const Color primaryRed = Color(0xFFC62828);
  static const Color primaryRedDark = Color(0xFF8E0000);
  static const Color primaryRedLight = Color(0xFFEF5350);

  // Secondary Colors (VyaptIX Branding)
  static const Color secondaryBlue = vyaptixBlue;
  static const Color secondaryGreen = vyaptixGreen;

  // Neutral Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Error & Status Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Light Theme (VyaptIX Blue Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: vyaptixBlue,
      colorScheme: const ColorScheme.light(
        primary: vyaptixBlue,
        secondary: vyaptixGreen,
        tertiary: vyaptixBlueLight,
        error: error,
        surface: surfaceLight,
        background: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: vyaptixBlue,
        foregroundColor: textOnPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: textOnPrimary),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vyaptixBlue,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: vyaptixBlue,
        foregroundColor: textOnPrimary,
      ),
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: vyaptixBlue,
        selectedItemColor: textOnPrimary,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: surfaceLight,
      ),
    );
  }

  // Dark Theme (VyaptIX Blue Dark Theme)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: vyaptixBlueLight,
      colorScheme: const ColorScheme.dark(
        primary: vyaptixBlueLight,
        secondary: vyaptixGreen,
        tertiary: vyaptixBlue,
        error: error,
        surface: surfaceDark,
        background: backgroundDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: vyaptixBlueDark,
        foregroundColor: textOnPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: textOnPrimary),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vyaptixBlueLight,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: vyaptixBlueLight,
        foregroundColor: textOnPrimary,
      ),
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: vyaptixBlueDark,
        selectedItemColor: textOnPrimary,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: surfaceDark,
      ),
    );
  }
}

