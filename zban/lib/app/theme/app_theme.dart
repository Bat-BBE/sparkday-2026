import 'package:flutter/material.dart';

enum AppThemeKey {
  violet,
  teal,
  rose,
  amber,
  sky,
}

abstract class AppThemes {
  static String toWire(AppThemeKey key) => key.name;

  static AppThemeKey fromWire(String? value) {
    if (value == null) return AppThemeKey.violet;
    try {
      return AppThemeKey.values.firstWhere(
        (k) => k.name == value,
        orElse: () => AppThemeKey.violet,
      );
    } catch (_) {
      return AppThemeKey.violet;
    }
  }

  static Color seed(AppThemeKey k) => switch (k) {
        AppThemeKey.violet => const Color.fromARGB(255, 92, 105, 246),
        AppThemeKey.teal => const Color(0xFF2DD4BF),
        AppThemeKey.rose => const Color(0xFFFB7185),
        AppThemeKey.amber => const Color(0xFFFBBF24),
        AppThemeKey.sky => const Color(0xFF38BDF8),
      };

  static ThemeData light(AppThemeKey k) {
    final primary = seed(k);

    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primary.withHSLValues(alpha: 0.12),
      onPrimaryContainer: const Color(0xFF0B1220),
      secondary: primary.withHSLValues(hue: 12),
      onSecondary: Colors.white,
      secondaryContainer: primary.withHSLValues(alpha: 0.10),
      onSecondaryContainer: const Color(0xFF0B1220),
      surface: Colors.white,
      onSurface: const Color(0xFF0B1220),
      surfaceContainerHighest: const Color(0xFFF2F4F8),
      onSurfaceVariant: const Color(0xFF5B6474),
      outline: const Color(0xFFE2E6EE),
      outlineVariant: const Color(0xFFF0F2F6),
      error: const Color(0xFFEF4444),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 32,
          letterSpacing: -0.5,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 28,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        titleLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 0.2,
        ),
        titleMedium: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9AA3B2),
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          maximumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          elevation: 0,
          shadowColor: primary.withHSLValues(alpha: 0.22),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: colorScheme.outline, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return const Color(0xFF94A3B8);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withHSLValues(alpha: 0.30);
          }
          return const Color(0xFFE8ECF3);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withHSLValues(alpha: 0.18);
          }
          return Colors.transparent;
        }),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFF5B6474),
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF6F7FB),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        toolbarHeight: 64,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(color: primary, size: 24),
        unselectedIconTheme:
            const IconThemeData(color: Color(0xFF64748B), size: 24),
        selectedLabelTextStyle:
            TextStyle(color: primary, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: const TextStyle(color: Color(0xFF64748B)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF2F4F8),
        selectedColor: primary.withHSLValues(alpha: 0.14),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Color(0xFF5B6474),
          fontSize: 13,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: Color(0xFFE8ECF3),
        circularTrackColor: Color(0xFFE8ECF3),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0B1220),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: primary,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8ECF3),
        thickness: 1,
        space: 16,
      ),
      listTileTheme: ListTileThemeData(
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurfaceVariant,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(color: colorScheme.onSurface, fontSize: 14),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteTextColor: colorScheme.onSurface,
        dialBackgroundColor: const Color(0xFFF2F4F8),
        dialHandColor: primary,
        dialTextColor: colorScheme.onSurface,
        entryModeIconColor: primary,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        indicatorColor: primary.withHSLValues(alpha: 0.12),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? primary : const Color(0xFF64748B),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? primary : const Color(0xFF64748B),
          );
        }),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  // Backwards compatible (older call sites)
  static ThemeData dark(AppThemeKey k) => light(k);
}

extension ColorUtils on Color {
  Color withHSLValues(
      {double? alpha, double? hue, double? saturation, double? lightness}) {
    HSLColor hsl = HSLColor.fromColor(this);
    if (hue != null) {
      double newHue = (hsl.hue + hue).clamp(0.0, 360.0);
      hsl = hsl.withHue(newHue);
    }
    if (saturation != null) hsl = hsl.withSaturation(saturation);
    if (lightness != null) hsl = hsl.withLightness(lightness);
    if (alpha != null) return hsl.toColor().withValues(alpha: alpha);
    return hsl.toColor();
  }
}
