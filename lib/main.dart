import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(appState.temaEscuroProfundo),
            themeMode: appState.temaEscuro ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(),
          ),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF3B82F6),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0xFFE0E0E0),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF3B82F6),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF3B82F6),
        onSecondary: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF202124),
        background: Color(0xFFF8F9FA),
        onBackground: Color(0xFF202124),
        error: Color(0xFFEF4444),
        onError: Color(0xFFFFFFFF),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFFAFAFA),
        surfaceContainer: Color(0xFFF5F5F5),
        surfaceContainerHigh: Color(0xFFF0F0F0),
        surfaceContainerHighest: Color(0xFFEBEBEB),
        onSurfaceVariant: Color(0xFF5F6368),
        outline: Color(0xFFE0E0E0),
        outlineVariant: Color(0xFFF0F0F0),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF202124),
        iconTheme: IconThemeData(color: Color(0xFF202124)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        modalBackgroundColor: Color(0xFFFFFFFF),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFF3B82F6);
          return const Color(0xFFBDBDBD);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFF3B82F6).withOpacity(0.5);
          return const Color(0xFFE0E0E0);
        }),
      ),
    );
  }

  ThemeData _buildDarkTheme(bool profundo) {
    final surfaceColor = profundo ? const Color(0xFF0D0D0D) : const Color(0xFF1D2024);
    final backgroundColor = profundo ? const Color(0xFF000000) : const Color(0xFF111318);
    final surfaceContainerColor = profundo ? const Color(0xFF1A1A1A) : const Color(0xFF282A2F);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFA8C7FA),
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
        primary: const Color(0xFFA8C7FA),
        onPrimary: const Color(0xFF003062),
        secondary: const Color(0xFFBFC6DC),
        onSecondary: const Color(0xFF003062),
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
        backgroundColor: surfaceColor,
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
        indicatorColor: const Color(0xFFA8C7FA).withOpacity(0.2),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerColor,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.3),
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
          if (states.contains(WidgetState.selected)) return const Color(0xFFA8C7FA);
          return const Color(0xFF616161);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFFA8C7FA).withOpacity(0.5);
          return const Color(0xFF424242);
        }),
      ),
    );
  }
}