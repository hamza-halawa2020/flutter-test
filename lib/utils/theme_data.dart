import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppThemeData {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Color(AppTheme.lightBg),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(AppTheme.lightCardBg),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(AppTheme.lightTextPrimary)),
        titleTextStyle: TextStyle(
          color: Color(AppTheme.lightTextPrimary),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: Color(AppTheme.lightCardBg),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: Color(AppTheme.lightTextPrimary),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: Color(AppTheme.lightTextPrimary),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(AppTheme.lightTextSecondary),
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppTheme.accentColor),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(AppTheme.lightCardBg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(AppTheme.lightBorder)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(AppTheme.lightBorder)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(AppTheme.accentColor), width: 2),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(AppTheme.darkBg),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(AppTheme.darkCardBg),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(AppTheme.darkTextPrimary)),
        titleTextStyle: TextStyle(
          color: Color(AppTheme.darkTextPrimary),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: Color(AppTheme.darkCardBg),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: Color(AppTheme.darkTextPrimary),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: Color(AppTheme.darkTextPrimary),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(AppTheme.darkTextSecondary),
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppTheme.accentColor),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(AppTheme.darkCardBg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(AppTheme.darkBorder)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(AppTheme.darkBorder)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(AppTheme.accentColor), width: 2),
        ),
      ),
    );
  }
}
