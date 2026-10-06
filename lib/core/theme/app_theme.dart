import 'package:flutter/material.dart';

class AppTheme {
  static const primaryTextStyle = TextStyle(fontFamily: "Arial", color: Colors.white);
  static const secondoryTextStyle = TextStyle(fontFamily: "Arial", color: Colors.white);
  static const secondoryTextStyleMedium =
      TextStyle(fontFamily: "Arial", fontWeight: FontWeight.w700, color: Colors.white);
  static const tertiaryTextStyle = TextStyle(fontFamily: "Arial", color: Colors.white);
  static const fontAwesomeRegularFont =
      TextStyle(fontFamily: "FontAwesome-Regular");
  static const fontAwesomeSolidFont =
      TextStyle(fontFamily: "FontAwesome-Solids");

  static const themeColor = Color(0xFF000000);         // Hitam murni
  static const primaryColor1 = Color(0xFFFFFFFF);      // Putih
  static const primaryColor2 = Color(0xFFBBBBBB);      // Abu-abu terang (teks sekunder)
  static const accentColor1 = Color(0xFFAAAAAA);       // Abu-abu terang
  static const accentColor1light = Color(0xFFCCCCCC);  // Abu-abu muda
  static const accentColor2 = Color(0xFFFFFFFF);       // Putih (pengganti pink)
  static const successColor = Color(0xFF5EFF43);

  ThemeData get defaultThemeData {
    const darkScheme = ColorScheme.dark(
      primary: accentColor2,
      secondary: accentColor1,
      surface: themeColor,
      surfaceContainerHighest: Color(0xFF1A1A1A),
      onPrimary: Colors.black, // Teks hitam di atas tombol putih (primary) agar terbaca
      onSecondary: Colors.black,
      onSurface: Colors.white,  // Teks putih di atas background hitam
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: themeColor,
      dialogBackgroundColor: Color(0xFF111111),
      primaryColorDark: accentColor2,
      fontFamily: 'Arial',
      primarySwatch: MaterialColor(
        accentColor2.value,
        {
          50: accentColor2.withValues(alpha: 0.1),
          100: accentColor2.withValues(alpha: 0.2),
          200: accentColor2.withValues(alpha: 0.3),
          300: accentColor2.withValues(alpha: 0.4),
          400: accentColor2.withValues(alpha: 0.5),
          500: accentColor2.withValues(alpha: 0.6),
          600: accentColor2.withValues(alpha: 0.7),
          700: accentColor2.withValues(alpha: 0.8),
          800: accentColor2.withValues(alpha: 0.9),
          900: accentColor2,
        },
      ),
      colorScheme: darkScheme.copyWith(
        primary: accentColor2,
        secondary: accentColor1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        displayMedium: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        displaySmall: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        headlineLarge: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        headlineMedium: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        headlineSmall: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        titleLarge: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        titleMedium: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        titleSmall: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        bodyMedium: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        bodySmall: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        labelLarge: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        labelMedium: TextStyle(color: Colors.white, fontFamily: 'Arial'),
        labelSmall: TextStyle(color: Colors.white, fontFamily: 'Arial'),
      ),
      iconTheme: const IconThemeData(color: primaryColor1),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(accentColor1),
        interactive: true,
        radius: const Radius.circular(10),
        thickness: WidgetStateProperty.all(5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: themeColor,
        foregroundColor: primaryColor1,
        surfaceTintColor: themeColor,
        iconTheme: IconThemeData(color: primaryColor1),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: accentColor1),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: accentColor1,
        selectionColor: accentColor1,
        selectionHandleColor: accentColor1,
      ),
      brightness: Brightness.dark,
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(themeColor),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? primaryColor1
                : accentColor1),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? primaryColor1
                : primaryColor2.withValues(alpha: 0.5)),
      ),
      searchBarTheme: const SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(Color(0xFF111111)),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xFF111111),
        textStyle: TextStyle(color: primaryColor1),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Color(0xFF111111)),
        ),
        textStyle: TextStyle(color: primaryColor1),
      ),
      menuTheme: const MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Color(0xFF111111)),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF111111),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

typedef Default_Theme = AppTheme;