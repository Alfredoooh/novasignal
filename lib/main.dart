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

  // Força statusbar preto com ícones brancos SEMPRE
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
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
    return MaterialApp(
      title: 'Football Live',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      themeMode: ThemeMode.light, // SEMPRE tema claro
      home: const HomePage(),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          ),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    const pureWhite = Color(0xFFFFFFFF);
    const appleBlue = Color(0xFF007AFF);
    const lightBackground = Color(0xFFF2F2F7);
    const lightSecondary = Color(0xFFFFFFFF);
    const lightTertiary = Color(0xFFFFFFFF);
    const separator = Color(0xFFC6C6C8);
    const labelPrimary = Color(0xFF000000);
    const labelSecondary = Color(0xFF3C3C43);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightSecondary,
      dividerColor: separator,
      splashFactory: NoSplash.splashFactory, // Remove brilho de navegação
      highlightColor: Colors.transparent, // Remove highlight
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
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
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
}