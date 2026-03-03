import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/document_service.dart';
import 'screens/editor_screen.dart';
import 'widgets/theme.dart';

// ─── MAIN ────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          primary: AppColors.acc,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accDark,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
        ),
      ),
      home: const EditorScreen(isRoot: true),
    );
  }
}
