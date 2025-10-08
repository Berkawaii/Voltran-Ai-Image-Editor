import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF8B5CF6),
      surface: Colors.white,
      background: Color(0xFFF8F9FA),
      error: Color(0xFFEF4444),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1F2937),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
      ),
      bodyLarge: TextStyle(color: Color(0xFF6B7280)),
      bodyMedium: TextStyle(color: Color(0xFF6B7280)),
    ),
  );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF818CF8),
      secondary: Color(0xFFA78BFA),
      surface: Color(0xFF1F2937),
      background: Color(0xFF111827),
      error: Color(0xFFF87171),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF111827),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F2937),
      foregroundColor: Color(0xFFF9FAFB),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1F2937),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFFF9FAFB),
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFFF9FAFB),
      ),
      bodyLarge: TextStyle(color: Color(0xFF9CA3AF)),
      bodyMedium: TextStyle(color: Color(0xFF9CA3AF)),
    ),
  );
}
