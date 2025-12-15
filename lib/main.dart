import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'screens/home_page.dart';

void main() {
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
        return MaterialApp(
          title: 'Football Live',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: appState.temaAmoled ? _buildAmoledTheme() : _buildDarkTheme(),
          themeMode: appState.temaEscuro ? ThemeMode.dark : ThemeMode.light,
          home: const HomePage(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const surfaceColor = Color(0xFF1E1E1E);
    const backgroundColor = Color(0xFF161616);
    const surfaceContainerColor = Color(0xFF282828);
    const surfaceContainerHighColor = Color(0xFF323232);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.dark,
        surface: surfaceColor,
        background: backgroundColor,
        surfaceContainerLowest: const Color(0xFF141414),
        surfaceContainerLow: const Color(0xFF1A1A1A),
        surfaceContainer: surfaceContainerColor,
        surfaceContainerHigh: surfaceContainerHighColor,
        surfaceContainerHighest: const Color(0xFF3C3C3C),
        onSurface: const Color(0xFFE4E4E4),
        onSurfaceVariant: const Color(0xFFB8B8B8),
        onBackground: const Color(0xFFE4E4E4),
        outline: const Color(0xFF4A4A4A),
        outlineVariant: const Color(0xFF323232),
        shadow: Colors.black.withOpacity(0.5),
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: const Color(0xFF2A2A2A),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: surfaceColor.withOpacity(0.7),
        foregroundColor: const Color(0xFFE4E4E4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor.withOpacity(0.7),
        indicatorColor: const Color(0xFF1976D2).withOpacity(0.2),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // TEMA AMOLED - PRETO PURO
  ThemeData _buildAmoledTheme() {
    const pureBlack = Color(0xFF000000);
    const almostBlack = Color(0xFF0A0A0A);
    const darkGray = Color(0xFF151515);
    const mediumGray = Color(0xFF1A1A1A);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.dark,
        // PRETO PURO para AMOLED
        surface: almostBlack,
        background: pureBlack,
        surfaceContainerLowest: pureBlack,
        surfaceContainerLow: almostBlack,
        surfaceContainer: darkGray,
        surfaceContainerHigh: mediumGray,
        surfaceContainerHighest: const Color(0xFF202020),
        // Texto com alto contraste
        onSurface: const Color(0xFFFFFFFF),
        onSurfaceVariant: const Color(0xFFB0B0B0),
        onBackground: const Color(0xFFFFFFFF),
        // Bordas sutis
        outline: const Color(0xFF2A2A2A),
        outlineVariant: const Color(0xFF1A1A1A),
        shadow: pureBlack,
      ),
      scaffoldBackgroundColor: pureBlack,
      cardColor: almostBlack,
      dividerColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: pureBlack,
        foregroundColor: Color(0xFFFFFFFF),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: almostBlack,
        indicatorColor: const Color(0xFF1976D2).withOpacity(0.3),
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
        backgroundColor: darkGray,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkGray,
        modalBackgroundColor: darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}