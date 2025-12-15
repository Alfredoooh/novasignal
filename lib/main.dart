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
          darkTheme: _buildDarkTheme(),
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
    // Cinza profundo mas não extremo - Material Design 3
    const surfaceColor = Color(0xFF1E1E1E);        // Cinza médio-escuro
    const backgroundColor = Color(0xFF161616);      // Cinza profundo suave
    const surfaceContainerColor = Color(0xFF282828); // Containers elevados
    const surfaceContainerHighColor = Color(0xFF323232); // Containers mais altos
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.dark,
        // Superfícies - Cinza profundo mas não preto puro
        surface: surfaceColor,
        background: backgroundColor,
        // Containers com elevação
        surfaceContainerLowest: const Color(0xFF141414),
        surfaceContainerLow: const Color(0xFF1A1A1A),
        surfaceContainer: surfaceContainerColor,
        surfaceContainerHigh: surfaceContainerHighColor,
        surfaceContainerHighest: const Color(0xFF3C3C3C),
        // Cores de texto otimizadas para o fundo escuro
        onSurface: const Color(0xFFE4E4E4),
        onSurfaceVariant: const Color(0xFFB8B8B8),
        onBackground: const Color(0xFFE4E4E4),
        // Outline suave
        outline: const Color(0xFF4A4A4A),
        outlineVariant: const Color(0xFF323232),
        // Shadow para profundidade
        shadow: Colors.black.withOpacity(0.5),
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: const Color(0xFF2A2A2A),
      // AppBar com material escuro
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: surfaceColor.withOpacity(0.7),
        foregroundColor: const Color(0xFFE4E4E4),
      ),
      // Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor.withOpacity(0.7),
        indicatorColor: const Color(0xFF1976D2).withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64B5F6),
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB8B8B8),
          );
        }),
      ),
      // Cards e containers
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(0xFF2A2A2A).withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      // Dialogs
      dialogTheme: DialogTheme(
        backgroundColor: surfaceContainerColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      // Bottom Sheets
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceContainerColor,
        modalBackgroundColor: surfaceContainerColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerHighColor,
        selectedColor: const Color(0xFF1976D2).withOpacity(0.3),
        labelStyle: const TextStyle(color: Color(0xFFE4E4E4)),
      ),
      // Text Theme otimizado
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFFE4E4E4)),
        displayMedium: TextStyle(color: Color(0xFFE4E4E4)),
        displaySmall: TextStyle(color: Color(0xFFE4E4E4)),
        headlineLarge: TextStyle(color: Color(0xFFE4E4E4)),
        headlineMedium: TextStyle(color: Color(0xFFE4E4E4)),
        headlineSmall: TextStyle(color: Color(0xFFE4E4E4)),
        titleLarge: TextStyle(color: Color(0xFFE4E4E4)),
        titleMedium: TextStyle(color: Color(0xFFE4E4E4)),
        titleSmall: TextStyle(color: Color(0xFFE4E4E4)),
        bodyLarge: TextStyle(color: Color(0xFFE4E4E4)),
        bodyMedium: TextStyle(color: Color(0xFFE4E4E4)),
        bodySmall: TextStyle(color: Color(0xFFB8B8B8)),
        labelLarge: TextStyle(color: Color(0xFFE4E4E4)),
        labelMedium: TextStyle(color: Color(0xFFE4E4E4)),
        labelSmall: TextStyle(color: Color(0xFFB8B8B8)),
      ),
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(0xFFB8B8B8),
      ),
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHighColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2),
        ),
      ),
    );
  }
}