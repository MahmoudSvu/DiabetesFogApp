import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF041E76);
  static const primaryLight = Color(0xFF1A3A8F);
  static const primaryDark = Color(0xFF031452);
  static const backgroundColor = Color(0xFF041E76);
  static const surfaceColor = Color(0xFF0A2B6B);
  static const textColor = Colors.white;
  static const textSecondaryColor = Color(0xFFE0E0E0);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        primaryContainer: primaryLight,
        secondary: Colors.green,
        error: Colors.red,
        surface: surfaceColor,
        onPrimary: textColor,
        onSurface: textColor,
        onBackground: textColor,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: textSecondaryColor),
        labelLarge: TextStyle(color: textColor),
        labelMedium: TextStyle(color: textColor),
        labelSmall: TextStyle(color: textSecondaryColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textSecondaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textSecondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
        labelStyle: const TextStyle(color: textSecondaryColor),
        hintStyle: const TextStyle(color: textSecondaryColor),
      ),
      iconTheme: const IconThemeData(color: textColor),
    );
  }

  // ألوان الحالات
  static Color getStateColor(int stateIndex) {
    switch (stateIndex) {
      case 0: // Stable
        return Colors.green;
      case 1: // PreAlert
        return Colors.orange;
      case 2: // AcuteRisk
        return Colors.deepOrange;
      case 3: // CriticalEmergency
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

