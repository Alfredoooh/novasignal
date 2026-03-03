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
    themeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() => setState(() {});

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
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFF13223),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF000000),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1B1B1B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFA6559),
          surface: Color(0xFF343434),
          onSurface: Color(0xFFFFE8E3),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

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
