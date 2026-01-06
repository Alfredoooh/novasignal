import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show HttpOverrides, HttpClient, SecurityContext, X509Certificate;
import 'core/app_state.dart';
import 'screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: appState.temaEscuro ? Brightness.light : Brightness.dark,
            statusBarBrightness: appState.temaEscuro ? Brightness.dark : Brightness.light,
          ),
          child: MaterialApp(
            title: 'Football Live',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(appState.corDinamica),
            darkTheme: appState.temaAmoled 
                ? _buildPureBlackTheme(appState.corDinamica) 
                : (appState.temaEscuroProfundo 
                    ? _buildDarkElevatedTheme(appState.corDinamica)
                    : _buildDarkTheme(appState.corDinamica)),
            themeMode: appState.temaEscuro ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          ),
        );
      },
    );
  }

  // ==================== TEMA CLARO ====================
  ThemeData _buildLightTheme(bool usarCorDinamica) {
    const pureWhite = Color(0xFFFFFFFF);
    const appleBlue = Color(0xFF007AFF);
    const lightBackground = Color(0xFFF2F2F7); // iOS System Background
    const lightSecondary = Color(0xFFFFFFFF); // iOS Secondary Background
    const lightTertiary = Color(0xFFFFFFFF); // iOS Tertiary Background
    const separator = Color(0xFFC6C6C8);
    const labelPrimary = Color(0xFF000000);
    const labelSecondary = Color(0xFF3C3C43);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appleBlue,
          brightness: Brightness.light,
          surface: lightBackground,
          surfaceContainerLowest: pureWhite,
          surfaceContainerLow: lightSecondary,
          surfaceContainer: lightSecondary,
          surfaceContainerHigh: lightTertiary,
          surfaceContainerHighest: lightTertiary,
          onSurface: labelPrimary,
          onSurfaceVariant: labelSecondary,
          outline: separator,
        ),
        scaffoldBackgroundColor: lightBackground,
        dividerColor: separator,
        cardColor: lightSecondary,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: lightBackground,
          surfaceTintColor: Colors.transparent,
          foregroundColor: labelPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: CardThemeData(
          color: lightSecondary,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: separator.withOpacity(0.3), width: 0.5),
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightSecondary,
      dividerColor: separator,
      colorScheme: ColorScheme.light(
        primary: appleBlue,
        onPrimary: pureWhite,
        secondary: appleBlue,
        surface: lightBackground,
        surfaceContainerLowest: pureWhite,
        surfaceContainerLow: lightSecondary,
        surfaceContainer: lightSecondary,
        surfaceContainerHigh: lightTertiary,
        surfaceContainerHighest: lightTertiary,
        onSurface: labelPrimary,
        onSurfaceVariant: labelSecondary,
        outline: separator,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: lightBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: labelPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: lightSecondary,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: separator.withOpacity(0.3), width: 0.5),
        ),
      ),
    );
  }

  // ==================== TEMA ESCURO (NORMAL - iOS Dark Mode) ====================
  ThemeData _buildDarkTheme(bool usarCorDinamica) {
    const appleBlue = Color(0xFF0A84FF);
    
    // iOS Dark Mode Colors
    const darkBackground = Color(0xFF000000); // System Background
    const darkSecondary = Color(0xFF1C1C1E); // Secondary Background
    const darkTertiary = Color(0xFF2C2C2E); // Tertiary Background
    const darkQuaternary = Color(0xFF3A3A3C); // Quaternary (cards, etc)
    const darkSeparator = Color(0xFF38383A); // Separator
    const darkLabel = Color(0xFFFFFFFF); // Primary Label
    const darkLabelSecondary = Color(0xFFEBEBF5); // Secondary Label
    const darkLabelTertiary = Color(0xFFAEAEB2); // Tertiary Label

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appleBlue,
          brightness: Brightness.dark,
          surface: darkBackground,
          surfaceContainerLowest: darkBackground,
          surfaceContainerLow: darkSecondary,
          surfaceContainer: darkTertiary,
          surfaceContainerHigh: darkQuaternary,
          surfaceContainerHighest: darkQuaternary,
          onSurface: darkLabel,
          onSurfaceVariant: darkLabelTertiary,
          outline: darkSeparator,
        ),
        scaffoldBackgroundColor: darkBackground,
        dividerColor: darkSeparator,
        cardColor: darkSecondary,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: darkBackground,
          surfaceTintColor: Colors.transparent,
          foregroundColor: darkLabel,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardThemeData(
          color: darkSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: darkSeparator.withOpacity(0.5), width: 0.5),
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSecondary,
      dividerColor: darkSeparator,
      colorScheme: ColorScheme.dark(
        primary: appleBlue,
        onPrimary: Colors.white,
        secondary: appleBlue,
        surface: darkBackground,
        surfaceContainerLowest: darkBackground,
        surfaceContainerLow: darkSecondary,
        surfaceContainer: darkTertiary,
        surfaceContainerHigh: darkQuaternary,
        surfaceContainerHighest: darkQuaternary,
        onSurface: darkLabel,
        onSurfaceVariant: darkLabelTertiary,
        outline: darkSeparator,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: darkLabel,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: darkSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: darkSeparator.withOpacity(0.5), width: 0.5),
        ),
      ),
    );
  }

  // ==================== TEMA ESCURO ELEVADO (Dark Elevated) ====================
  ThemeData _buildDarkElevatedTheme(bool usarCorDinamica) {
    const appleBlue = Color(0xFF0A84FF);
    
    // iOS Dark Elevated Colors (mais claro que o normal)
    const elevatedBackground = Color(0xFF1C1C1E); // Base Level
    const elevatedSecondary = Color(0xFF2C2C2E); // Elevated
    const elevatedTertiary = Color(0xFF3A3A3C); // More Elevated
    const elevatedQuaternary = Color(0xFF48484A); // Most Elevated
    const elevatedSeparator = Color(0xFF545456); // Separator (mais claro)
    const elevatedLabel = Color(0xFFFFFFFF);
    const elevatedLabelSecondary = Color(0xFFEBEBF5);
    const elevatedLabelTertiary = Color(0xFFAEAEB2);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appleBlue,
          brightness: Brightness.dark,
          surface: elevatedBackground,
          surfaceContainerLowest: elevatedBackground,
          surfaceContainerLow: elevatedSecondary,
          surfaceContainer: elevatedTertiary,
          surfaceContainerHigh: elevatedQuaternary,
          surfaceContainerHighest: elevatedQuaternary,
          onSurface: elevatedLabel,
          onSurfaceVariant: elevatedLabelTertiary,
          outline: elevatedSeparator,
        ),
        scaffoldBackgroundColor: elevatedBackground,
        dividerColor: elevatedSeparator,
        cardColor: elevatedSecondary,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: elevatedBackground,
          surfaceTintColor: Colors.transparent,
          foregroundColor: elevatedLabel,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardThemeData(
          color: elevatedSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: elevatedSeparator.withOpacity(0.5), width: 0.5),
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: elevatedBackground,
      cardColor: elevatedSecondary,
      dividerColor: elevatedSeparator,
      colorScheme: ColorScheme.dark(
        primary: appleBlue,
        onPrimary: Colors.white,
        secondary: appleBlue,
        surface: elevatedBackground,
        surfaceContainerLowest: elevatedBackground,
        surfaceContainerLow: elevatedSecondary,
        surfaceContainer: elevatedTertiary,
        surfaceContainerHigh: elevatedQuaternary,
        surfaceContainerHighest: elevatedQuaternary,
        onSurface: elevatedLabel,
        onSurfaceVariant: elevatedLabelTertiary,
        outline: elevatedSeparator,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: elevatedBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: elevatedLabel,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: elevatedSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: elevatedSeparator.withOpacity(0.5), width: 0.5),
        ),
      ),
    );
  }

  // ==================== TEMA PURE BLACK (AMOLED) ====================
  ThemeData _buildPureBlackTheme(bool usarCorDinamica) {
    const appleBlue = Color(0xFF0A84FF);
    
    // Pure Black Theme (para telas AMOLED)
    const pureBlack = Color(0xFF000000); // Background absoluto
    const almostBlack = Color(0xFF0A0A0A); // Cards/Elementos
    const darkGray = Color(0xFF1C1C1C); // Separadores/Bordas
    const mediumGray = Color(0xFF2C2C2E); // Elementos elevados
    const blackSeparator = Color(0xFF1C1C1C); // Separator bem sutil
    const whiteLabel = Color(0xFFFFFFFF);
    const grayLabel = Color(0xFFAEAEB2);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appleBlue,
          brightness: Brightness.dark,
          surface: pureBlack,
          surfaceContainerLowest: pureBlack,
          surfaceContainerLow: almostBlack,
          surfaceContainer: darkGray,
          surfaceContainerHigh: mediumGray,
          surfaceContainerHighest: mediumGray,
          onSurface: whiteLabel,
          onSurfaceVariant: grayLabel,
          outline: blackSeparator,
        ),
        scaffoldBackgroundColor: pureBlack,
        dividerColor: blackSeparator,
        cardColor: almostBlack,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: pureBlack,
          surfaceTintColor: Colors.transparent,
          foregroundColor: whiteLabel,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardThemeData(
          color: almostBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: blackSeparator.withOpacity(0.5), width: 0.5),
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: pureBlack,
      cardColor: almostBlack,
      dividerColor: blackSeparator,
      colorScheme: ColorScheme.dark(
        primary: appleBlue,
        onPrimary: Colors.white,
        secondary: appleBlue,
        surface: pureBlack,
        surfaceContainerLowest: pureBlack,
        surfaceContainerLow: almostBlack,
        surfaceContainer: darkGray,
        surfaceContainerHigh: mediumGray,
        surfaceContainerHighest: mediumGray,
        onSurface: whiteLabel,
        onSurfaceVariant: grayLabel,
        outline: blackSeparator,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: pureBlack,
        surfaceTintColor: Colors.transparent,
        foregroundColor: whiteLabel,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: almostBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: blackSeparator.withOpacity(0.5), width: 0.5),
        ),
      ),
    );
  }
}