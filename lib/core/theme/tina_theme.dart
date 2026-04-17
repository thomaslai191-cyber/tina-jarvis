import 'package:flutter/material.dart';

/// TINA JARVIS - 钢铁侠风格主题颜色
class TinaColors {
  // 主色调 - 科技蓝
  static const Color primary = Color(0xFF00D2FF);
  static const Color primaryDark = Color(0xFF0078A0);
  static const Color primaryLight = Color(0xFF80E5FF);
  
  // 次要色调 - 深蓝
  static const Color secondary = Color(0xFF3A7BD5);
  static const Color accent = Color(0xFF00FF9D);
  
  // 背景色
  static const Color background = Color(0xFF0A1628);
  static const Color backgroundDark = Color(0xFF050D18);
  static const Color surface = Color(0xFF1E3A5F);
  static const Color surfaceLight = Color(0xFF2A5080);
  
  // 文字颜色
  static const Color textPrimary = Color(0xFFE0F7FA);
  static const Color textSecondary = Color(0xFFB0C4DE);
  static const Color textMuted = Color(0xFF6B8CAE);
  
  // 状态颜色
  static const Color listening = Color(0xFF00FFD2);
  static const Color thinking = Color(0xFFFFD700);
  static const Color speaking = Color(0xFFFF6B6B);
  static const Color idle = Color(0xFF7B8794);
  static const Color online = Color(0xFF00FF9D);
  static const Color offline = Color(0xFFFF4444);
  
  // 发光效果颜色
  static const Color glowPrimary = Color(0xFF00D2FF);
  static List<Color> get gradientPrimary => [
    primary.withOpacity(0.0),
    primary.withOpacity(0.3),
    primary.withOpacity(0.8),
  ];
  static List<Color> get gradientSurface => [
    surface.withOpacity(0.1),
    surface.withOpacity(0.5),
    surface.withOpacity(0.9),
  ];
  
  // HUD 边框颜色
  static const Color hudBorder = Color(0xFF00D2FF);
  static const Color hudBorderDim = Color(0xFF3A7BD5);
}

/// 主题数据
class TinaTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: TinaColors.primary,
      scaffoldBackgroundColor: TinaColors.background,
      colorScheme: const ColorScheme.dark(
        primary: TinaColors.primary,
        secondary: TinaColors.secondary,
        surface: TinaColors.surface,
        background: TinaColors.background,
        error: Colors.redAccent,
        onPrimary: TinaColors.background,
        onSecondary: TinaColors.textPrimary,
        onSurface: TinaColors.textPrimary,
        onBackground: TinaColors.textPrimary,
      ),
      textTheme: _textTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      cardTheme: _cardTheme,
      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
    );
  }
  
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: _buildTextStyle(48, FontWeight.w300, TinaColors.textPrimary),
      displayMedium: _buildTextStyle(36, FontWeight.w300, TinaColors.textPrimary),
      displaySmall: _buildTextStyle(24, FontWeight.w400, TinaColors.textPrimary),
      headlineLarge: _buildTextStyle(32, FontWeight.w400, TinaColors.primary),
      headlineMedium: _buildTextStyle(28, FontWeight.w400, TinaColors.primary),
      headlineSmall: _buildTextStyle(24, FontWeight.w500, TinaColors.primary),
      titleLarge: _buildTextStyle(22, FontWeight.w500, TinaColors.textPrimary),
      titleMedium: _buildTextStyle(16, FontWeight.w500, TinaColors.textPrimary),
      titleSmall: _buildTextStyle(14, FontWeight.w500, TinaColors.textSecondary),
      bodyLarge: _buildTextStyle(16, FontWeight.w400, TinaColors.textPrimary),
      bodyMedium: _buildTextStyle(14, FontWeight.w400, TinaColors.textSecondary),
      bodySmall: _buildTextStyle(12, FontWeight.w400, TinaColors.textMuted),
      labelLarge: _buildTextStyle(14, FontWeight.w500, TinaColors.primary),
      labelMedium: _buildTextStyle(12, FontWeight.w500, TinaColors.secondary),
      labelSmall: _buildTextStyle(11, FontWeight.w400, TinaColors.textMuted),
    );
  }
  
  static TextStyle _buildTextStyle(double size, FontWeight weight, Color color) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 0.5,
      fontFamily: 'Exo',
    );
  }
  
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TinaColors.primary,
        foregroundColor: TinaColors.background,
        elevation: 8,
        shadowColor: TinaColors.primary.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: TinaColors.primary.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
  
  static CardTheme get _cardTheme {
    return CardTheme(
      color: TinaColors.surface.withOpacity(0.3),
      elevation: 4,
      shadowColor: TinaColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: TinaColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
    );
  }
  
  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: TinaColors.background.withOpacity(0.9),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _buildTextStyle(20, FontWeight.w600, TinaColors.primary),
      iconTheme: const IconThemeData(color: TinaColors.primary),
    );
  }
  
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: TinaColors.surface.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: TinaColors.primary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: TinaColors.primary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TinaColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: TinaColors.textSecondary),
      hintStyle: const TextStyle(color: TinaColors.textMuted),
    );
  }
  
  static FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: TinaColors.primary,
      foregroundColor: TinaColors.background,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
  
  /// 发光效果 BoxDecoration
  static BoxDecoration get glowBoxDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: TinaColors.primary.withOpacity(0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: TinaColors.primary.withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
      gradient: LinearGradient(
        colors: [
          TinaColors.surface.withOpacity(0.1),
          TinaColors.surface.withOpacity(0.4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
