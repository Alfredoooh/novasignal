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
                ? _buildAmoledTheme(appState.corDinamica) 
                : _buildDarkTheme(appState.corDinamica, appState.temaEscuroProfundo),
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

  ThemeData _buildLightTheme(bool usarCorDinamica) {
    const pureWhite = Color(0xFFFFFFFF);
    const appleBlue = Color(0xFF007AFF);
    const lightGray = Color(0xFFF8F8F8);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appleBlue,
          brightness: Brightness.light,
        ).copyWith(
          surface: pureWhite,
          onSurface: const Color(0xFF000000),
        ),
        scaffoldBackgroundColor: pureWhite,
        cardColor: pureWhite,
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
          backgroundColor: pureWhite,
          foregroundColor: Color(0xFF000000),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: pureWhite,
      cardColor: pureWhite,
      dividerColor: const Color(0xFFE5E5E5),
      colorScheme: const ColorScheme.light(
        primary: appleBlue,
        onPrimary: pureWhite,
        secondary: appleBlue,
        surface: pureWhite,
        onSurface: Color(0xFF000000),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: pureWhite,
        foregroundColor: Color(0xFF000000),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.03),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  ThemeData _buildDarkTheme(bool usarCorDinamica, bool profundo) {
    // Cores base Apple-style
    const appleBlue = Color(0xFF0A84FF);
    
    // Profundo: Preto absoluto com sutis variações
    // Normal: Cinza escuro Apple-style
    final backgroundColor = profundo ? const Color(0xFF000000) : const Color(0xFF1C1C1E);
    final surfaceColor = profundo ? const Color(0xFF0A0A0A) : const Color(0xFF2C2C2E);
    final surfaceVariant = profundo ? const Color(0xFF141414) : const Color(0xFF3A3A3C);
    final surfaceHighest = profundo ? const Color(0xFF1C1C1C) : const Color(0xFF48484A);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appleBlue,
          brightness: Brightness.dark,
        ).copyWith(
          surface: surfaceColor,
          onSurface: const Color(0xFFFFFFFF),
          surfaceContainerLowest: backgroundColor,
          surfaceContainerLow: surfaceColor,
          surfaceContainer: surfaceVariant,
          surfaceContainerHigh: surfaceHighest,
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardColor: surfaceColor,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: const Color(0xFFFFFFFF),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: profundo ? const Color(0xFF1C1C1C) : const Color(0xFF38383A),
      colorScheme: ColorScheme.dark(
        primary: appleBlue,
        onPrimary: Colors.white,
        secondary: appleBlue,
        surface: surfaceColor,
        onSurface: const Color(0xFFFFFFFF),
        surfaceContainerLowest: backgroundColor,
        surfaceContainerLow: surfaceColor,
        surfaceContainer: surfaceVariant,
        surfaceContainerHigh: surfaceHighest,
        onSurfaceVariant: const Color(0xFFAEAEB2),
        outline: profundo ? const Color(0xFF1C1C1C) : const Color(0xFF38383A),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: const Color(0xFFFFFFFF),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: appleBlue.withOpacity(0.15),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: profundo ? const Color(0xFF1C1C1C) : const Color(0xFF38383A),
            width: 0.5,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceVariant,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceVariant,
        modalBackgroundColor: surfaceVariant,
        elevation: 24,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
      ),
    );
  }

  ThemeData _buildAmoledTheme(bool usarCorDinamica) {
    const pureBlack = Color(0xFF000000);
    const almostBlack = Color(0xFF0A0A0A);
    const appleBlue = Color(0xFF0A84FF);
    const darkGray = Color(0xFF1C1C1C);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appleBlue,
          brightness: Brightness.dark,
        ).copyWith(
          surface: almostBlack,
          onSurface: const Color(0xFFFFFFFF),
          surfaceContainerLowest: pureBlack,
          surfaceContainerLow: almostBlack,
          surfaceContainer: Color(0xFF141414),
          surfaceContainerHigh: darkGray,
        ),
        scaffoldBackgroundColor: pureBlack,
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
          foregroundColor: Color(0xFFFFFFFF),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: pureBlack,
      cardColor: almostBlack,
      dividerColor: darkGray,
      colorScheme: const ColorScheme.dark(
        primary: appleBlue,
        onPrimary: Colors.white,
        secondary: appleBlue,
        surface: almostBlack,
        onSurface: Color(0xFFFFFFFF),
        surfaceContainerLowest: pureBlack,
        surfaceContainerLow: almostBlack,
        surfaceContainer: Color(0xFF141414),
        surfaceContainerHigh: darkGray,
        onSurfaceVariant: Color(0xFFAEAEB2),
        outline: darkGray,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: pureBlack,
        foregroundColor: Color(0xFFFFFFFF),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: almostBlack,
        indicatorColor: appleBlue.withOpacity(0.15),
      ),
      cardTheme: CardThemeData(
        color: almostBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkGray, width: 0.5),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1C1C1C),
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1C1C1C),
        modalBackgroundColor: Color(0xFF1C1C1C),
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
      ),
    );
  }
}