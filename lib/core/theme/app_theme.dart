import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

abstract class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? ColorTokens.primaryDark : ColorTokens.primary;
    final bg = isDark ? ColorTokens.backgroundDark : ColorTokens.background;
    final surf = isDark ? ColorTokens.surfaceDark : ColorTokens.surface;
    final surfEl = isDark ? ColorTokens.surfaceElevatedDark : ColorTokens.surfaceElevated;
    final bord = isDark ? ColorTokens.borderDark : ColorTokens.border;
    final txt = isDark ? ColorTokens.textDark : ColorTokens.text;
    final txtM = isDark ? ColorTokens.textMutedDark : ColorTokens.textMuted;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? ColorTokens.backgroundDark : Colors.white,
      primaryContainer: primary.withAlpha(38),
      onPrimaryContainer: primary,
      secondary: isDark ? ColorTokens.accentBrassDark : ColorTokens.accentBrass,
      onSecondary: Colors.white,
      secondaryContainer: (isDark ? ColorTokens.accentBrassDark : ColorTokens.accentBrass).withAlpha(38),
      onSecondaryContainer: isDark ? ColorTokens.accentBrassDark : ColorTokens.accentBrass,
      tertiary: isDark ? ColorTokens.accentGreenDark : ColorTokens.accentGreen,
      onTertiary: Colors.white,
      error: ColorTokens.danger,
      onError: Colors.white,
      surface: surf,
      onSurface: txt,
      surfaceContainerHighest: surfEl,
      onSurfaceVariant: txtM,
      outline: bord,
    );

    final base = ThemeData(brightness: brightness);
    final textTheme = GoogleFonts.instrumentSansTextTheme(base.textTheme).apply(
      bodyColor: txt,
      displayColor: txt,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: bg,
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: bord),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfEl,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: bord)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: bord)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorTokens.danger)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorTokens.danger, width: 2)),
        hintStyle: TextStyle(color: txtM),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? ColorTokens.backgroundDark : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surf,
        foregroundColor: txt,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.instrumentSans(fontSize: 20, fontWeight: FontWeight.w600, color: txt),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surf,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: primary.withAlpha(38),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return GoogleFonts.instrumentSans(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
            color: sel ? primary : txtM,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(color: sel ? primary : txtM);
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: isDark ? ColorTokens.backgroundDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: bord, space: 1, thickness: 1),
    );
  }
}
