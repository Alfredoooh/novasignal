import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/bottom_bar.dart';
import 'home_screen.dart';
import 'ai_screen.dart';
import 'new_screen.dart';

class MainScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;

  const MainScreen({
    Key? key,
    required this.themeProvider,
    required this.languageProvider,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        themeProvider: widget.themeProvider,
        languageProvider: widget.languageProvider,
      ),
      AIScreen(languageProvider: widget.languageProvider),
      NewScreen(languageProvider: widget.languageProvider),
    ];
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: BottomBar(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
        languageProvider: widget.languageProvider,
        isDarkMode: widget.themeProvider.isDarkMode,
      ),
    );
  }
}