import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & Accent Colors (Pastel & Modern)
  static const Color primary = Color(0xFF6366F1); // Soft Indigo
  static const Color primaryLight = Color(0xFF818CF8); // Pastel Indigo
  static const Color primaryDark = Color(0xFF4F46E5);

  static const Color accent = Color(0xFF14B8A6); // Pastel Teal
  static const Color accentLight = Color(0xFF2DD4BF); // Mint Cyan
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentPink = Color(0xFFEC4899);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Pastel Emerald
  static const Color successLight = Color(0xFF34D399);
  static const Color error = Color(0xFFF43F5E); // Pastel Rose/Coral
  static const Color errorLight = Color(0xFFFB7185);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);

  // Light Mode Surfaces (Pure White)
  static const Color lightBg = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSecondary = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightText = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500

  // Dark Mode Surfaces (Pure Black)
  static const Color darkBg = Color(0xFF000000); // Pure Black
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1A1A2E);
  static const Color darkCardSecondary = Color(0xFF1E293B); // Slate 800
  static const Color darkBorder = Color(0xFF2A374D);
  static const Color darkText = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400

  // Border Radius Tokens (Consistent 18px cards)
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 18.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 100.0;

  // Soft Ambient Shadows
  static const List<BoxShadow> lightCardShadow = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA855F7), Color(0xFFC084FC)],
  );

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: lightSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightText,
      ),
      cardColor: lightCard,
      dividerColor: lightBorder,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: lightText,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: lightText,
        ),
        iconTheme: const IconThemeData(color: lightText),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: lightBorder),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: lightText,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: lightText,
          letterSpacing: -0.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: lightTextSecondary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: lightText,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: lightTextSecondary,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          color: lightTextSecondary,
        ),
      ),
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: accentLight,
        surface: darkSurface,
        error: errorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
      ),
      cardColor: darkCard,
      dividerColor: darkBorder,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkText,
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: const BorderSide(color: darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: darkText,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: darkText,
          letterSpacing: -0.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkTextSecondary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: darkText,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: darkTextSecondary,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          color: darkTextSecondary,
        ),
      ),
    );
  }
}

/// Dynamic Theme Extensions on BuildContext for clean and robust theme-aware widgets
extension ThemeContextExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg => isDark ? AppTheme.darkBg : AppTheme.lightBg;
  Color get surface => isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
  Color get cardBg => isDark ? AppTheme.darkCard : AppTheme.lightCard;
  Color get cardSecondary => isDark ? AppTheme.darkCardSecondary : AppTheme.lightCardSecondary;
  Color get border => isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
  Color get textPrimary => isDark ? AppTheme.darkText : AppTheme.lightText;
  Color get textSecondary => isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

  List<BoxShadow> get cardShadow => isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow;
}
