import 'package:flutter/material.dart';

class DripTheme {
  // Cosmic Galaxy Palette
  static const Color voidBlack = Color(0xFF02040A);
  static const Color deepSpace = Color(0xFF0A1628);
  static const Color nebulaBlue = Color(0xFF1A3A5C);
  static const Color surface = Color(0xFF0D1B2A);
  static const Color surfaceLight = Color(0xFF1B2838);

  // Accent colors from the cosmic logo
  static const Color cosmicTeal = Color(0xFF00D4AA);
  static const Color nebulaCyan = Color(0xFF4ECDC4);
  static const Color aquaGlow = Color(0xFF7FDBDA);
  static const Color chrome = Color(0xFFC0C5CE);
  static const Color starWhite = Color(0xFFE8F1F2);

  // Gradients
  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF4ECDC4), Color(0xFF7FDBDA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nebulaGradient = LinearGradient(
    colors: [Color(0xFF0A1628), Color(0xFF1A3A5C), Color(0xFF0D1B2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get theme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: voidBlack,
      primaryColor: cosmicTeal,
      colorScheme: const ColorScheme.dark(
        primary: cosmicTeal,
        secondary: nebulaCyan,
        surface: surface,
        background: voidBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
