import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/document_service.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/editor_screen.dart';
import 'widgets/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.init();
  await DocumentService.instance.load();
  runApp(const WriteApp());
}

class WriteApp extends StatefulWidget {
  const WriteApp({super.key});
  @override
  State<WriteApp> createState() => _WriteAppState();
}

class _WriteAppState extends State<WriteApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    themeNotifier.removeListener(() => setState(() {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp(
      title: 'Write',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.light(
          primary: accColor(false),
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.dark(
          primary: accColor(true),
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// Decide: mostra AuthScreen ou vai directo ao editor
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _authed = AuthService.instance.loggedIn;
  }

  void _onDone() => setState(() => _authed = true);

  @override
  Widget build(BuildContext context) {
    if (_authed) return const EditorScreen(isRoot: true);
    return AuthScreen(onDone: _onDone);
  }
}
