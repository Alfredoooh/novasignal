import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar navegação nativa do Android
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  
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
        onSurface: Color(0xFF000000),
        onSurfaceVariant: Color(0xFF757575),
        outline: Color(0xFFE5E5EA),
        background: Color(0xFFF2F2F7),
        error: Color(0xFFFF3B30),
        tertiary: Color(0xFF34C759),
        secondary: Color(0xFF8E8E93),
      ),
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Color(0xFF000000),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      fontFamily: 'Roboto',
      iconTheme: const IconThemeData(color: Color(0xFF000000)),
      dividerColor: const Color(0xFFE5E5EA),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF000000)),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF000000)),
        bodySmall: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0A84FF),
        primaryContainer: Color(0xFF66AFFF),
        inversePrimary: Color(0xFF0056CC),
        onPrimary: Colors.white,
        surface: Color(0xFF1C1C1E),
        onSurface: Color(0xFFFFFFFF),
        onSurfaceVariant: Color(0xFF8E8E93),
        outline: Color(0xFF38383A),
        background: Color(0xFF000000),
        error: Color(0xFFFF453A),
        tertiary: Color(0xFF32D74B),
        secondary: Color(0xFF8E8E93),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1C1E),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      fontFamily: 'Roboto',
      iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
      dividerColor: const Color(0xFF38383A),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
        bodySmall: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
      ),
    );
  }
}