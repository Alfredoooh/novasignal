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
  Widget? _secondaryScreen;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      // Limpa a tela secundária ao trocar de aba
      _secondaryScreen = null;
    });
  }

  void _onSecondaryScreenChanged(Widget screen) {
    setState(() {
      _secondaryScreen = screen;
    });
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          themeProvider: widget.themeProvider,
          languageProvider: widget.languageProvider,
          onSecondaryScreenChanged: _isDesktop(context) ? _onSecondaryScreenChanged : null,
        );
      case 1:
        return AIScreen(languageProvider: widget.languageProvider);
      case 2:
        return NewScreen(languageProvider: widget.languageProvider);
      default:
        return HomeScreen(
          themeProvider: widget.themeProvider,
          languageProvider: widget.languageProvider,
          onSecondaryScreenChanged: _isDesktop(context) ? _onSecondaryScreenChanged : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar (80px)
            BottomBar(
              currentIndex: _currentIndex,
              onTabChanged: _onTabChanged,
              languageProvider: widget.languageProvider,
              isDarkMode: widget.themeProvider.isDarkMode,
            ),
            
            // Divisão 50/50 no centro
            Expanded(
              child: Row(
                children: [
                  // Tela Esquerda (50%) - Sempre visível
                  Expanded(
                    flex: 1,
                    child: _getCurrentScreen(),
                  ),
                  
                  // Divisor vertical
                  Container(
                    width: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  
                  // Tela Direita (50%) - Tela Secundária
                  Expanded(
                    flex: 1,
                    child: _secondaryScreen ?? _EmptySecondaryScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Layout mobile - comportamento normal
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

// Tela secundária vazia (placeholder quando nada está aberto)
class _EmptySecondaryScreen extends StatelessWidget {
  const _EmptySecondaryScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 80,
              color: theme.colorScheme.secondary.withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            Text(
              'Select an item to view details',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.secondary.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click on any template to see more information',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}