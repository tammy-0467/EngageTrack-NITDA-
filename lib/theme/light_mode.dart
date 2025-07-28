import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.light,

    primary: Color(0xFF00A54B), // NITDA Dark Green
    onPrimary: Colors.white,

    secondary: Color(0xFF006400),
    onSecondary: Colors.black,

    tertiary: Color(0xFF76FFB3), // Muted mint for contrast
    onTertiary: Colors.white,

    inversePrimary: Color(0xFF009100), // Darker green for contrast

    surface: Colors.grey.shade100,
    onSurface: Colors.grey.shade800,

    error: Colors.red.shade700,
    onError: Colors.white,
  ),
);
