import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Football Live',
            themeMode: appState.temaEscuro ? ThemeMode.dark : ThemeMode.light,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const HomePage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF007AFF),
        primaryContainer: Color(0xFF66AFFF),
        inversePrimary: Color(0xFF0056CC),
        onPrimary: Colors.white,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1C1B1F),
        onSurfaceVariant: Color(0xFF757575),
        outline: Color(0xFFE0E0E0),
        background: Color(0xFFF8F9FA),
        error: Color(0xFFFF3B30),
        tertiary: Color(0xFF34C759),
        secondary: Color(0xFF8E8E93),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Color(0xFF1C1B1F),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      fontFamily: 'Roboto',
      iconTheme: const IconThemeData(color: Color(0xFF1C1B1F)),
      dividerColor: const Color(0xFFE0E0E0),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF757575)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF007AFF),
        primaryContainer: Color(0xFF66AFFF),
        inversePrimary: Color(0xFF0056CC),
        onPrimary: Colors.white,
        surface: Color(0xFF1E1E1E),
        onSurface: Color(0xFFE0E0E0),
        onSurfaceVariant: Color(0xFF9E9E9E),
        outline: Color(0xFF2D2D2D),
        background: Color(0xFF121212),
        error: Color(0xFFFF3B30),
        tertiary: Color(0xFF34C759),
        secondary: Color(0xFF8E8E93),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Color(0xFFE0E0E0),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      fontFamily: 'Roboto',
      iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
      dividerColor: const Color(0xFF2D2D2D),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
      ),
    );
  }
}