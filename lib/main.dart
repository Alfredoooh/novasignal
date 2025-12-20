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
          theme: _buildLightTheme(appState.corDinamica),
          darkTheme: appState.temaAmoled 
              ? _buildAmoledTheme(appState.corDinamica) 
              : _buildDarkTheme(appState.corDinamica, appState.temaEscuroProfundo),
          themeMode: appState.temaEscuro ? ThemeMode.dark : ThemeMode.light,
          home: const HomePage(),
        );
      },
    );
  }

  ThemeData _buildLightTheme(bool usarCorDinamica) {
    const pureWhite = Color(0xFFFFFFFF);
    // Vermelho Deriv: #FF444F
    const derivRed = Color(0xFFFF444F);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: usarCorDinamica ? const Color(0xFF1976D2) : derivRed,
        brightness: Brightness.light,
        surface: pureWhite,
        background: pureWhite,
        surfaceContainerLowest: pureWhite,
        surfaceContainerLow: const Color(0xFFFAFAFA),
        surfaceContainer: const Color(0xFFF5F5F5),
        surfaceContainerHigh: const Color(0xFFF0F0F0),
        surfaceContainerHighest: const Color(0xFFEBEBEB),
      ),
      scaffoldBackgroundColor: pureWhite,
      cardColor: pureWhite,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: pureWhite,
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
    );
  }

  ThemeData _buildDarkTheme(bool usarCorDinamica, bool profundo) {
    // Tema normal escuro
    const surfaceColor = Color(0xFF1E1E1E);
    const backgroundColor = Color(0xFF161616);
    const surfaceContainerColor = Color(0xFF282828);
    const surfaceContainerHighColor = Color(0xFF323232);

    // Tema escuro profundo
    const surfaceColorDeep = Color(0xFF0D0D0D);
    const backgroundColorDeep = Color(0xFF000000);
    const surfaceContainerColorDeep = Color(0xFF1A1A1A);
    const surfaceContainerHighColorDeep = Color(0xFF242424);

    // Vermelho Deriv
    const derivRed = Color(0xFFFF444F);

    final surface = profundo ? surfaceColorDeep : surfaceColor;
    final background = profundo ? backgroundColorDeep : backgroundColor;
    final surfaceContainer = profundo ? surfaceContainerColorDeep : surfaceContainerColor;
    final surfaceContainerHigh = profundo ? surfaceContainerHighColorDeep : surfaceContainerHighColor;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: usarCorDinamica ? const Color(0xFF1976D2) : derivRed,
        brightness: Brightness.dark,
        surface: surface,
        background: background,
        surfaceContainerLowest: profundo ? const Color(0xFF050505) : const Color(0xFF141414),
        surfaceContainerLow: profundo ? const Color(0xFF0A0A0A) : const Color(0xFF1A1A1A),
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: profundo ? const Color(0xFF2E2E2E) : const Color(0xFF3C3C3C),
        onSurface: const Color(0xFFE4E4E4),
        onSurfaceVariant: const Color(0xFFB8B8B8),
        onBackground: const Color(0xFFE4E4E4),
        outline: profundo ? const Color(0xFF3A3A3A) : const Color(0xFF4A4A4A),
        outlineVariant: profundo ? const Color(0xFF242424) : const Color(0xFF323232),
        shadow: Colors.black.withOpacity(0.5),
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: profundo ? const Color(0xFF1A1A1A) : const Color(0xFF2A2A2A),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: surface.withOpacity(0.7),
        foregroundColor: const Color(0xFFE4E4E4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withOpacity(0.7),
        indicatorColor: (usarCorDinamica ? const Color(0xFF1976D2) : derivRed).withOpacity(0.2),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainerHigh,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceContainerHigh,
        modalBackgroundColor: surfaceContainerHigh,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  ThemeData _buildAmoledTheme(bool usarCorDinamica) {
    const pureBlack = Color(0xFF000000);
    const almostBlack = Color(0xFF0A0A0A);
    const darkGray = Color(0xFF151515);
    const mediumGray = Color(0xFF1A1A1A);
    const modalGray = Color(0xFF252525);
    const derivRed = Color(0xFFFF444F);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: usarCorDinamica ? const Color(0xFF1976D2) : derivRed,
        brightness: Brightness.dark,
        surface: almostBlack,
        background: pureBlack,
        surfaceContainerLowest: pureBlack,
        surfaceContainerLow: almostBlack,
        surfaceContainer: darkGray,
        surfaceContainerHigh: mediumGray,
        surfaceContainerHighest: const Color(0xFF202020),
        onSurface: const Color(0xFFFFFFFF),
        onSurfaceVariant: const Color(0xFFB0B0B0),
        onBackground: const Color(0xFFFFFFFF),
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
        indicatorColor: (usarCorDinamica ? const Color(0xFF1976D2) : derivRed).withOpacity(0.3),
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
      dialogTheme: DialogThemeData(
        backgroundColor: modalGray,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: modalGray,
        modalBackgroundColor: modalGray,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}