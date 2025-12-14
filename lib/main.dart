import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
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
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF000000),
        onSurfaceVariant: Color(0xFF8E8E93),
        outline: Color(0xFFE5E5EA),
        background: Color(0xFFF2F2F7),
        error: Color(0xFFFF3B30),
        tertiary: Color(0xFF34C759),
      ),
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        foregroundColor: Color(0xFF000000),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerColor: const Color(0xFFE5E5EA),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0A84FF),
        surface: Color(0xFF1C1C1E),
        onSurface: Color(0xFFFFFFFF),
        onSurfaceVariant: Color(0xFF8E8E93),
        outline: Color(0xFF38383A),
        background: Color(0xFF000000),
        error: Color(0xFFFF453A),
        tertiary: Color(0xFF32D74B),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1C1E),
        elevation: 0,
        foregroundColor: Color(0xFFFFFFFF),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerColor: const Color(0xFF38383A),
    );
  }
}