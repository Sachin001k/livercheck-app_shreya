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

/// Turns off Android's "stretch" effect when a list is pulled past its top
/// or bottom (Android 12+), so cards and text don't stretch. Pull to
/// refresh still works.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
