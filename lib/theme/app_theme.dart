import 'package:flutter/material.dart';

// Цветовая индикация оценок по ТЗ:
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

class AppTheme {
  static const _radius = 18.0;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        color: Colors.white,
      ),
      textTheme: const TextTheme(
        // крупный читабельный шрифт
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 15),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFFF6F7FB),
        foregroundColor: Color(0xFF0F172A),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF2563EB),
        unselectedItemColor: Color(0xFF94A3B8),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        color: const Color(0xFF151E32),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 15),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF0B1220),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF60A5FA),
        unselectedItemColor: Color(0xFF64748B),
      ),
    );
  }
}
