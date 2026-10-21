import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF188765);
  static const Color primaryDark = Color(0xFF0D6248);
  static const Color primaryDeep = Color(0xFF073E2D);
  static const Color primaryLight = Color(0xFF45B88C);
  static const Color accent = Color(0xFFF3B943);
  static const Color success = Color(0xFF168765);
  static const Color danger = Color(0xFFD94F67);
  static const Color info = Color(0xFF4C91D9);

  static const Color background = Color(0xFFF3F7F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceTint = Color(0xFFF9FCFA);
  static const Color lightOutline = Color(0xFFE0EAE3);
  static const Color darkBackground = Color(0xFF0B1410);
  static const Color darkSurface = Color(0xFF14221B);
  static const Color darkSurfaceRaised = Color(0xFF1B2D24);
  static const Color darkOutline = Color(0xFF2A4034);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E5D43), Color(0xFF188765), Color(0xFF42B78B)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C6044), Color(0xFF188765), Color(0xFF47B88D)],
    stops: [0, 0.58, 1],
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A3023), Color(0xFF10543D), Color(0xFF197A58)],
    stops: [0, 0.58, 1],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD36A), Color(0xFFF4B233)],
  );

  static const LinearGradient alertGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB93852), Color(0xFFE05A70), Color(0xFFEF7A87)],
  );

  static const List<Color> categoryPalette = [
    Color(0xFF188765),
    Color(0xFF4C91D9),
    Color(0xFFF0B33D),
    Color(0xFFD94F67),
    Color(0xFF9365D8),
    Color(0xFF34AF9B),
    Color(0xFFE87956),
    Color(0xFF82948A),
  ];

  static const PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  static ThemeData get light => _build(dark: false);

  static ThemeData get dark => _build(dark: true);

  static ThemeData _build({required bool dark}) {
    final brightness = dark ? Brightness.dark : Brightness.light;
    final foreground = dark
        ? const Color(0xFFF1F6F2)
        : const Color(0xFF18251E);
    final secondaryText = dark
        ? const Color(0xFFA2B5A9)
        : const Color(0xFF66766C);
    final backgroundColor = dark ? darkBackground : background;
    final surfaceColor = dark ? darkSurface : lightSurface;
    final outlineColor = dark ? darkOutline : lightOutline;
    final brandColor = dark ? primaryLight : primary;
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: brandColor,
      onPrimary: dark ? primaryDeep : Colors.white,
      secondary: accent,
      onSecondary: primaryDeep,
      surface: surfaceColor,
      onSurface: foreground,
      error: danger,
      onError: Colors.white,
    ).copyWith(
      primary: brandColor,
      onPrimary: dark ? primaryDeep : Colors.white,
      secondary: accent,
      onSecondary: primaryDeep,
      surface: surfaceColor,
      onSurface: foreground,
      outline: outlineColor,
      outlineVariant: outlineColor.withValues(alpha: 0.65),
      error: danger,
      onError: Colors.white,
    );
    final baseTextTheme = ThemeData(
      brightness: brightness,
      useMaterial3: true,
    ).textTheme.apply(bodyColor: foreground, displayColor: foreground);
    final textTheme = baseTextTheme.copyWith(
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.35,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        color: secondaryText,
      ),
    );
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: outlineColor),
    );

    return ThemeData(
      useMaterial3: true,
      platform: TargetPlatform.iOS,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: surfaceColor,
      splashFactory: NoSplash.splashFactory,
      pageTransitionsTheme: _pageTransitions,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: brandColor, size: 22),
        actionsIconTheme: IconThemeData(color: brandColor, size: 22),
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        shape: Border(
          bottom: BorderSide(color: outlineColor.withValues(alpha: 0.65), width: 0.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1.5,
        shadowColor: primaryDark.withValues(alpha: dark ? 0.06 : 0.08),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outlineColor.withValues(alpha: 0.72), width: 0.65),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outlineColor.withValues(alpha: 0.75),
        thickness: 0.7,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? darkSurfaceRaised : lightSurfaceTint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: TextStyle(color: secondaryText, fontSize: 14),
        labelStyle: TextStyle(color: secondaryText),
        floatingLabelStyle: TextStyle(color: brandColor, fontWeight: FontWeight.w600),
        prefixIconColor: secondaryText,
        suffixIconColor: secondaryText,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brandColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandColor,
          foregroundColor: dark ? primaryDeep : Colors.white,
          disabledBackgroundColor: outlineColor,
          disabledForegroundColor: secondaryText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandColor,
          foregroundColor: dark ? primaryDeep : Colors.white,
          disabledBackgroundColor: outlineColor,
          disabledForegroundColor: secondaryText,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandColor,
          side: BorderSide(color: outlineColor),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: brandColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: primaryDeep,
        elevation: 3,
        highlightElevation: 4,
        shape: const CircleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: brandColor.withValues(alpha: 0.14),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          return TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? brandColor : secondaryText,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? darkSurfaceRaised : const Color(0xFFECF4EF),
        selectedColor: brandColor.withValues(alpha: 0.16),
        secondarySelectedColor: brandColor.withValues(alpha: 0.16),
        disabledColor: outlineColor,
        labelStyle: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        side: BorderSide(color: outlineColor.withValues(alpha: 0.7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: brandColor,
        textColor: foreground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        minVerticalPadding: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: TextStyle(color: foreground, fontSize: 19, fontWeight: FontWeight.w700),
        contentTextStyle: TextStyle(color: secondaryText, fontSize: 14),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceColor,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: TextStyle(color: foreground, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkSurfaceRaised,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        dismissDirection: DismissDirection.horizontal,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return dark ? const Color(0xFFBAC7BE) : const Color(0xFFFAFCFA);
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return brandColor;
          return outlineColor;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return brandColor;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: outlineColor, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return states.contains(WidgetState.selected) ? brandColor : secondaryText;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brandColor,
        linearTrackColor: brandColor.withValues(alpha: 0.12),
        circularTrackColor: brandColor.withValues(alpha: 0.12),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: brandColor,
        inactiveTrackColor: brandColor.withValues(alpha: 0.18),
        thumbColor: brandColor,
        overlayColor: brandColor.withValues(alpha: 0.12),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: brandColor,
        selectionColor: brandColor.withValues(alpha: 0.22),
        selectionHandleColor: brandColor,
      ),
    );
  }
}
