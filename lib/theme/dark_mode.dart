import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.dark,

    primary: Color(0xFF00A54B), // NITDA Dark Green
    onPrimary: Color(0xFFCCCCCC), // Soft mint (same as onTertiary)

    secondary: Color(0xFF76FFB3), // Mint green used for accents
    onSecondary: Colors.black,

    tertiary: Color(0xFF006400), // Deep green, used for contrast
    onTertiary: Color(0xFFCCCCCC), // Same as onPrimary

    inversePrimary: Color(0xFFE0FFE8), // Minty inverse for subtle contrast

    surface: Colors.grey.shade900,     // Dark background
    onSurface: Colors.white,   // Readable light text

    error: Colors.red.shade400,
    onError: Colors.black,
  ),
);
