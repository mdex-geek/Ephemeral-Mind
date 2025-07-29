import 'package:flutter/material.dart';

// Light Theme Colors
const Color kLightPrimary = Color(0xFF6750A4);
const Color kLightSecondary = Color(0xFF625B71);
const Color kLightBackground = Color(0xFFFFFFFF);
const Color kLightSurface = Color(0xFFFFFFFF);
const Color kLightOnPrimary = Color(0xFFFFFFFF);
const Color kLightOnBackground = Color(0xFF1C1B1F);
const Color kLightBorder = Color(0xFFCCCCCC);

// Dark Theme Colors
const Color kDarkPrimary = Color(0xFFD0BCFF);
const Color kDarkSecondary = Color(0xFFCCC2DC);
const Color kDarkBackground = Color(0xFF1C1B1F);
const Color kDarkSurface = Color(0xFF1C1B1F);
const Color kDarkOnPrimary = Color(0xFF381E72);
const Color kDarkOnBackground = Color(0xFFE6E1E5);
const Color kDarkBorder = Color(0xFF444444);

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: kLightPrimary,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: kLightPrimary,
      onPrimary: kLightOnPrimary,
      secondary: kLightSecondary,
      onSecondary: kLightOnPrimary,
      surface: kLightSurface,
      onSurface: kLightOnBackground,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: kLightBackground,
    cardColor: kLightSurface,
    dividerColor: kLightBorder,
    fontFamily: 'Poppins',

    // BUTTON THEMES
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kLightPrimary,
        foregroundColor: kLightOnPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kLightPrimary,
        foregroundColor: kLightOnPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kLightPrimary,
        side: BorderSide(color: kLightPrimary),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kLightPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: kDarkPrimary,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: kDarkPrimary,
      onPrimary: kDarkOnPrimary,
      secondary: kDarkSecondary,
      onSecondary: kDarkOnPrimary,
      surface: kDarkSurface,
      onSurface: kDarkOnBackground,
      error: Colors.red,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: kDarkBackground,
    cardColor: kDarkSurface,
    dividerColor: kDarkBorder,
    fontFamily: 'Poppins',

    // BUTTON THEMES
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kDarkPrimary,
        foregroundColor: kDarkOnPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kDarkPrimary,
        foregroundColor: kDarkOnPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kDarkPrimary,
        side: BorderSide(color: kDarkPrimary),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kDarkPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    ),
  );
} 