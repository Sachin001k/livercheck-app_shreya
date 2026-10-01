import 'package:flutter/material.dart';

/// Shared LivrCheck colours.
const Color tealDark = Color(0xFF1F5E55);
const Color tealLight = Color(0xFF5FA79A);
const Color mintCard = Color(0xFFE8F4F1);

const LinearGradient tealGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [tealDark, tealLight],
);

ThemeData buildAppTheme() {
  return ThemeData(
    colorSchemeSeed: const Color(0xFF2E7D6B),
    useMaterial3: true,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    ),
  );
}
