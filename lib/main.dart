import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();
  final LanguageProvider _languageProvider = LanguageProvider();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await _themeProvider.loadTheme();
    await _languageProvider.loadLanguage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_themeProvider, _languageProvider]),
      builder: (context, child) {
        return MaterialApp(
          title: 'App',
          debugShowCheckedModeBanner: false,
          theme: _themeProvider.currentTheme,
          home: MainScreen(
            themeProvider: _themeProvider,
            languageProvider: _languageProvider,
          ),
        );
      },
    );
  }
}