import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm, gender-neutral skincare palette: cream surfaces with a sunny
/// amber-yellow accent.
///
/// Single source of truth for the app's look. Every screen reads colours from
/// `Theme.of(context).colorScheme`, so re-skinning happens here only:
///   * page background  - cream `surface` (#FDF6E8)
///   * cards/fields     - white `surfaceContainerLowest`
///   * accent/CTA       - amber `primary` (#F59E0B)
///   * nav bar          - warm `surfaceContainer` (#FEF1D6)
abstract final class AppTheme {
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _amberBright = Color(0xFFFBBF24);

  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static TextTheme _jakarta(TextTheme base) {
    TextStyle? style(TextStyle? source) =>
        GoogleFonts.plusJakartaSans(textStyle: source);

    return base.copyWith(
      displayLarge: style(base.displayLarge),
      displayMedium: style(base.displayMedium),
      displaySmall: style(base.displaySmall),
      headlineLarge: style(base.headlineLarge),
      headlineMedium: style(base.headlineMedium),
      headlineSmall: style(base.headlineSmall),
      titleLarge: style(base.titleLarge),
      titleMedium: style(base.titleMedium),
      titleSmall: style(base.titleSmall),
      bodyLarge: style(base.bodyLarge),
      bodyMedium: style(base.bodyMedium),
      bodySmall: style(base.bodySmall),
      labelLarge: style(base.labelLarge),
      labelMedium: style(base.labelMedium),
      labelSmall: style(base.labelSmall),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: _amber,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? _amberBright : _amber,
          onPrimary: isDark ? const Color(0xFF3A2703) : Colors.white,
          primaryContainer: isDark
              ? const Color(0xFF6B4A06)
              : const Color(0xFFFFF1D4),
          onPrimaryContainer: isDark
              ? const Color(0xFFFFE7B8)
              : const Color(0xFF5C3D02),
          surface: isDark ? const Color(0xFF17130C) : const Color(0xFFFDF6E8),
          onSurface: isDark ? const Color(0xFFF5F0E6) : const Color(0xFF1C1917),
          onSurfaceVariant: isDark
              ? const Color(0xFFB3A793)
              : const Color(0xFF78716C),
          surfaceContainerLowest: isDark
              ? const Color(0xFF120F09)
              : const Color(0xFFFFFFFF),
          surfaceContainerLow: isDark
              ? const Color(0xFF1E1913)
              : const Color(0xFFFFFAF0),
          surfaceContainer: isDark
              ? const Color(0xFF241E15)
              : const Color(0xFFFEF1D6),
          surfaceContainerHigh: isDark
              ? const Color(0xFF2C251A)
              : const Color(0xFFFBEFD9),
          surfaceContainerHighest: isDark
              ? const Color(0xFF352C1F)
              : const Color(0xFFF5E6C4),
          outlineVariant: isDark
              ? const Color(0xFF3A3125)
              : const Color(0xFFF2EDE2),
          outline: isDark ? const Color(0xFF8B7F6B) : const Color(0xFFE0DAD1),
        );

    // google_fonts ships TextTheme helpers typed against its own material
    // library, so apply the family style by style instead.
    final textTheme = _jakarta(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primary,
        indicatorShape: const CircleBorder(),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return (textTheme.labelMedium ?? const TextStyle()).copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: scheme.onSurface,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? scheme.onPrimary : scheme.onSurface,
          );
        }),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void setMode(ThemeMode mode) => state = mode;
}

final themeModeNotifier = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
