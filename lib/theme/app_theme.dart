import 'package:flutter/material.dart';

// Цветовая индикация оценок:
// 5 — зелёная, 4 — синяя, 3 — оранжевая, 2 — красная.
Color gradeColor(int value, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  switch (value) {
    case 5:
      return dark ? const Color(0xFF34C77B) : const Color(0xFF16A34A);
    case 4:
      return dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    case 3:
      return dark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    default:
      return dark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
  }
}

// Liquid Glass тема: полупрозрачные панели поверх градиентного фона.
class AppTheme {
  static const double radius = 24.0;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );
    return _base(scheme, false);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7BA7FF),
      brightness: Brightness.dark,
    );
    return _base(scheme, true);
  }

  static ThemeData _base(ColorScheme scheme, bool dark) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: dark ? Colors.white : const Color(0xFF0F172A),
        titleTextStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: dark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14.5),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor:
            dark ? const Color(0xFF8B93B0) : const Color(0xFF94A3B8),
      ),
    );
  }

  /// Стеклянная заливка карточки под текущую тему.
  static Color glassFill(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? Colors.white.withValues(alpha: 0.09)
        : Colors.white.withValues(alpha: 0.60);
  }

  /// Стеклянная рамка карточки.
  static Color glassBorder(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.75);
  }
}
