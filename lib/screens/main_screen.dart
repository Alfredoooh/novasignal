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
  Widget _secondaryScreen = const SizedBox.shrink();

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      // Limpa a tela secundária ao trocar de aba
      _secondaryScreen = const SizedBox.shrink();
    });
  }

  void _onSecondaryScreenChanged(Widget screen) {
    setState(() {
      _secondaryScreen = screen;
    });
  }

  bool _isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return width >= 900 || (width > height && width >= 768);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);

    Widget currentScreen;
    switch (_currentIndex) {
      case 0:
        currentScreen = HomeScreen(
          themeProvider: widget.themeProvider,
          languageProvider: widget.languageProvider,
          onSecondaryScreenChanged: isDesktop ? _onSecondaryScreenChanged : null,
        );
        break;
      case 1:
        currentScreen = AIScreen(languageProvider: widget.languageProvider);
        break;
      case 2:
        currentScreen = NewScreen(languageProvider: widget.languageProvider);
        break;
      default:
        currentScreen = HomeScreen(
          themeProvider: widget.themeProvider,
          languageProvider: widget.languageProvider,
          onSecondaryScreenChanged: isDesktop ? _onSecondaryScreenChanged : null,
        );
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar
            BottomBar(
              currentIndex: _currentIndex,
              onTabChanged: _onTabChanged,
              languageProvider: widget.languageProvider,
              isDarkMode: widget.themeProvider.isDarkMode,
            ),
            // Tela principal
            Expanded(
              child: currentScreen,
            ),
            // Tela secundária (se houver)
            if (_secondaryScreen is! SizedBox)
              Container(
                width: 400,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: _secondaryScreen,
              ),
          ],
        ),
      );
    }

    // Layout mobile
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            themeProvider: widget.themeProvider,
            languageProvider: widget.languageProvider,
          ),
          AIScreen(languageProvider: widget.languageProvider),
          NewScreen(languageProvider: widget.languageProvider),
        ],
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