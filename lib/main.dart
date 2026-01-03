import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show HttpOverrides, HttpClient, SecurityContext, X509Certificate;
import 'core/app_state.dart';
import 'screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuração global para corrigir imagens PNG - APENAS para plataformas não-web
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
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

// Classe para resolver problemas de certificado SSL - NÃO funciona na web
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
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
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
            // Configuração adicional para melhorar renderização de imagens na web
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // Garante que imagens sejam renderizadas corretamente
                  textScaleFactor: 1.0,
                ),
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
    const lightGray = Color(0xFFFAFAFA);
    const mediumGray = Color(0xFFF5F5F5);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
          surface: pureWhite,
          background: pureWhite,
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
          backgroundColor: pureWhite,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        cardTheme: CardThemeData(
          color: pureWhite,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: pureWhite,
      cardColor: pureWhite,
      dividerColor: const Color(0xFFE0E0E0),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.light(
        primary: appleBlue,
        onPrimary: pureWhite,
        secondary: appleBlue,
        onSecondary: pureWhite,
        surface: pureWhite,
        onSurface: Color(0xFF1A1A1A),
        background: pureWhite,
        onBackground: Color(0xFF1A1A1A),
        error: Color(0xFFD32F2F),
        onError: pureWhite,
        surfaceContainerLowest: pureWhite,
        surfaceContainerLow: lightGray,
        surfaceContainer: mediumGray,
        surfaceContainerHigh: Color(0xFFF0F0F0),
        surfaceContainerHighest: Color(0xFFEBEBEB),
        onSurfaceVariant: Color(0xFF666666),
        outline: Color(0xFFE0E0E0),
        outlineVariant: Color(0xFFF0F0F0),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: pureWhite,
        foregroundColor: Color(0xFF1A1A1A),
        iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: pureWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: pureWhite,
        modalBackgroundColor: pureWhite,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue;
          return const Color(0xFFBDBDBD);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue.withOpacity(0.5);
          return const Color(0xFFE0E0E0);
        }),
      ),
    );
  }

  ThemeData _buildDarkTheme(bool usarCorDinamica, bool profundo) {
    const appleBlue = Color(0xFF007AFF);

    final surfaceColor = profundo ? const Color(0xFF0D0D0D) : const Color(0xFF1D2024);
    final backgroundColor = profundo ? const Color(0xFF000000) : const Color(0xFF111318);
    final surfaceContainerColor = profundo ? const Color(0xFF1A1A1A) : const Color(0xFF282A2F);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
          surface: surfaceColor,
          background: backgroundColor,
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
          backgroundColor: surfaceColor.withOpacity(0.7),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: profundo ? const Color(0xFF1A1A1A) : const Color(0xFF444746),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.dark(
        primary: appleBlue,
        onPrimary: Colors.white,
        secondary: appleBlue,
        onSecondary: Colors.white,
        surface: surfaceColor,
        onSurface: const Color(0xFFE2E2E6),
        background: backgroundColor,
        onBackground: const Color(0xFFE2E2E6),
        error: const Color(0xFFFFB4AB),
        onError: const Color(0xFF690005),
        surfaceContainerLowest: profundo ? const Color(0xFF050505) : const Color(0xFF0D0D0D),
        surfaceContainerLow: profundo ? const Color(0xFF0A0A0A) : const Color(0xFF111318),
        surfaceContainer: surfaceContainerColor,
        surfaceContainerHigh: profundo ? const Color(0xFF242424) : const Color(0xFF323439),
        surfaceContainerHighest: profundo ? const Color(0xFF2E2E2E) : const Color(0xFF3D3F44),
        onSurfaceVariant: const Color(0xFFC4C7C5),
        outline: const Color(0xFF8E918F),
        outlineVariant: const Color(0xFF444746),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: surfaceColor.withOpacity(0.7),
        foregroundColor: const Color(0xFFE2E2E6),
        iconTheme: const IconThemeData(color: Color(0xFFE2E2E6)),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor.withOpacity(0.7),
        indicatorColor: appleBlue.withOpacity(0.2),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainerColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceContainerColor,
        modalBackgroundColor: surfaceContainerColor,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue;
          return const Color(0xFF616161);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue.withOpacity(0.5);
          return const Color(0xFF424242);
        }),
      ),
    );
  }

  ThemeData _buildAmoledTheme(bool usarCorDinamica) {
    const pureBlack = Color(0xFF000000);
    const almostBlack = Color(0xFF0A0A0A);
    const appleBlue = Color(0xFF007AFF);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
          surface: almostBlack,
          background: pureBlack,
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
          backgroundColor: pureBlack,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
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
      dividerColor: const Color(0xFF1A1A1A),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.dark(
        primary: appleBlue,
        onPrimary: Colors.white,
        secondary: appleBlue,
        onSecondary: Colors.white,
        surface: almostBlack,
        onSurface: Color(0xFFFFFFFF),
        background: pureBlack,
        onBackground: Color(0xFFFFFFFF),
        error: Color(0xFFEF5350),
        onError: Colors.white,
        surfaceContainerLowest: pureBlack,
        surfaceContainerLow: almostBlack,
        surfaceContainer: Color(0xFF151515),
        surfaceContainerHigh: Color(0xFF1A1A1A),
        surfaceContainerHighest: Color(0xFF202020),
        onSurfaceVariant: Color(0xFFB0B0B0),
        outline: Color(0xFF2A2A2A),
        outlineVariant: Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: pureBlack,
        foregroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: almostBlack,
        indicatorColor: appleBlue.withOpacity(0.3),
      ),
      cardTheme: CardThemeData(
        color: almostBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF1A1A1A),
            width: 0.5,
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF252525),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF252525),
        modalBackgroundColor: Color(0xFF252525),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue;
          return const Color(0xFF424242);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue.withOpacity(0.5);
          return const Color(0xFF2A2A2A);
        }),
      ),
    );
  }
}