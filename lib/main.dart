import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const SportsApp());
}

class ThemeProvider extends InheritedWidget {
  final bool isDark;
  final Function(bool) toggleTheme;

  const ThemeProvider({
    Key? key,
    required this.isDark,
    required this.toggleTheme,
    required Widget child,
  }) : super(key: key, child: child);

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) => isDark != oldWidget.isDark;
}

class LocaleProvider extends InheritedWidget {
  final String locale;
  final Function(String) changeLocale;

  const LocaleProvider({
    Key? key,
    required this.locale,
    required this.changeLocale,
    required Widget child,
  }) : super(key: key, child: child);

  static LocaleProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleProvider>();
  }

  @override
  bool updateShouldNotify(LocaleProvider oldWidget) => locale != oldWidget.locale;
}

class AppStrings {
  static Map<String, Map<String, String>> translations = {
    'pt': {
      'app_name': 'Bet Manager',
      'home': 'Início',
      'my_games': 'Meus Jogos',
      'settings': 'Configurações',
      'dark_mode': 'Modo Escuro',
      'language': 'Idioma',
      'choose_language': 'Escolher Idioma',
      'portuguese': 'Português',
      'english': 'English',
      'warning': 'Aviso',
      'error_occurred': 'Ocorreu um erro',
      'close': 'Fechar',
    },
    'en': {
      'app_name': 'Bet Manager',
      'home': 'Home',
      'my_games': 'My Games',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'choose_language': 'Choose Language',
      'portuguese': 'Português',
      'english': 'English',
      'warning': 'Warning',
      'error_occurred': 'An error occurred',
      'close': 'Close',
    },
  };

  static String get(String key, String locale) {
    return translations[locale]?[key] ?? translations['en']?[key] ?? key;
  }
}

class SportsApp extends StatefulWidget {
  const SportsApp({Key? key}) : super(key: key);

  @override
  State<SportsApp> createState() => _SportsAppState();
}

class _SportsAppState extends State<SportsApp> {
  bool _isDark = false;
  String _locale = 'pt';

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      isDark: _isDark,
      toggleTheme: (v) => setState(() => _isDark = v),
      child: LocaleProvider(
        locale: _locale,
        changeLocale: (v) => setState(() => _locale = v),
        child: WidgetsApp(
          color: const Color(0xFFFFFFFF),
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/settings':
                page = const SettingsScreen();
                break;
              default:
                page = const HomeScreen();
            }
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(animation),
                  child: child,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AppIcons {
  static const String homeOutline = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.121,9.069,15.536,1.483a5.008,5.008,0,0,0-7.072,0L.879,9.069A2.978,2.978,0,0,0,0,11.19v9.817a3,3,0,0,0,3,3H21a3,3,0,0,0,3-3V11.19A2.978,2.978,0,0,0,23.121,9.069ZM15,22.007H9V18.073a3,3,0,0,1,6,0Zm7-1a1,1,0,0,1-1,1H17V18.073a5,5,0,0,0-10,0v3.934H3a1,1,0,0,1-1-1V11.19a1.008,1.008,0,0,1,.293-.707L9.878,2.9a3.008,3.008,0,0,1,4.244,0l7.585,7.586A1.008,1.008,0,0,1,22,11.19Z"/></svg>''';
  
  static const String homeFilled = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M256,319.841c-35.346,0-64,28.654-64,64v128h128v-128C320,348.495,291.346,319.841,256,319.841z"/><path d="M362.667,383.841v128H448c35.346,0,64-28.654,64-64V253.26c0.005-11.083-4.302-21.733-12.011-29.696l-181.29-195.99c-31.988-34.61-85.976-36.735-120.586-4.747c-1.644,1.52-3.228,3.103-4.747,4.747L12.395,223.5C4.453,231.496-0.003,242.31,0,253.58v194.261c0,35.346,28.654,64,64,64h85.333v-128c0.399-58.172,47.366-105.676,104.073-107.044C312.01,275.383,362.22,323.696,362.667,383.841z"/></svg>''';
  
  static const String matchesOutline = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m19,3H5C2.243,3,0,5.243,0,8v8c0,2.757,2.243,5,5,5h14c2.757,0,5-2.243,5-5v-8c0-2.757-2.243-5-5-5Zm3,11h-2v-4h2v4Zm-10,0c-1.103,0-2-.897-2-2s.897-2,2-2,2,.897,2,2-.897,2-2,2ZM2,10h2v4h-2v-4Zm0,6h2c1.103,0,2-.897,2-2v-4c0-1.103-.897-2-2-2h-2c0-1.654,1.346-3,3-3h6v3.142c-1.72.447-3,1.999-3,3.858s1.28,3.411,3,3.858v3.142h-6c-1.654,0-3-1.346-3-3Zm17,3h-6v-3.142c1.72-.447,3-1.999,3-3.858s-1.28-3.411-3-3.858v-3.142h6c1.654,0,3,1.346,3,3h-2c-1.103,0-2,.897-2,2v4c0,1.103.897,2,2,2h2c0,1.654-1.346,3-3,3Z"/></svg>''';
  
  static const String matchesFilled = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m12,14c-1.103,0-2-.897-2-2s.897-2,2-2,2,.897,2,2-.897,2-2,2ZM3,10H0v4h3v-4Zm18,4h3v-4h-3v4Zm-2,0v-4c0-1.103.897-2,2-2h3c0-2.757-2.243-5-5-5h-6v5.142c1.72.447,3,1.999,3,3.858s-1.28,3.411-3,3.858v5.142h6c2.757,0,5-2.243,5-5h-3c-1.103,0-2-.897-2-2Zm-8,1.858c-1.72-.447-3-1.999-3-3.858s1.28-3.411,3-3.858V3h-6C2.243,3,0,5.243,0,8h3c1.103,0,2,.897,2,2v4c0,1.103-.897,2-2,2H0c0,2.757,2.243,5,5,5h6v-5.142Z"/></svg>''';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _drawerAnimation = CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_isDrawerOpen) {
      _drawerController.reverse();
    } else {
      _drawerController.forward();
    }
    setState(() => _isDrawerOpen = !_isDrawerOpen);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final locale = LocaleProvider.of(context);
    final isDark = theme?.isDark ?? false;
    final currentLocale = locale?.locale ?? 'pt';

    final bgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFF0F0F0);
    final appBarColor = isDark ? const Color(0xFF242526) : const Color(0xFF2C3E50);

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _drawerAnimation,
          builder: (context, child) {
            final slideValue = _drawerAnimation.value * 280;
            final scaleValue = 1.0 - (_drawerAnimation.value * 0.2);
            
            return Transform.translate(
              offset: Offset(slideValue, 0),
              child: Transform.scale(
                scale: scaleValue,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_drawerAnimation.value * 20),
                    boxShadow: _isDrawerOpen ? [BoxShadow(color: const Color(0x40000000), blurRadius: 20, offset: const Offset(-5, 0))] : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_drawerAnimation.value * 20),
                    child: _buildMainContent(bgColor, appBarColor, currentLocale, isDark),
                  ),
                ),
              ),
            );
          },
        ),
        _buildDrawer(isDark, currentLocale),
        if (_isDrawerOpen)
          GestureDetector(
            onTap: _toggleDrawer,
            child: Container(color: const Color(0x00000000)),
          ),
      ],
    );
  }

  Widget _buildMainContent(Color bgColor, Color appBarColor, String currentLocale, bool isDark) {
    return Container(
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: appBarColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleDrawer,
                    child: const Icon(IconData(0xe5d2, fontFamily: 'MaterialIcons'), color: Color(0xFFFFFFFF), size: 24),
                  ),
                  GestureDetector(
                    onTap: _toggleDrawer,
                    child: const Icon(IconData(0xe5d2, fontFamily: 'MaterialIcons'), color: Color(0xFFFFFFFF), size: 24),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppStrings.get('app_name', currentLocale),
                        style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/settings'),
                    child: const Icon(IconData(0xe5d3, fontFamily: 'MaterialIcons'), color: Color(0xFFFFFFFF), size: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  Container(color: bgColor, child: Center(child: Text('Home', style: TextStyle(fontSize: 24, color: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D))))),
                  Container(color: bgColor, child: Center(child: Text(AppStrings.get('my_games', currentLocale), style: TextStyle(fontSize: 24, color: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D))))),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0), width: 1)),
              ),
              child: Row(
                children: [
                  _buildBottomItem(0, AppIcons.homeOutline, AppIcons.homeFilled, AppStrings.get('home', currentLocale), isDark),
                  _buildBottomItem(1, AppIcons.matchesOutline, AppIcons.matchesFilled, AppStrings.get('my_games', currentLocale), isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(bool isDark, String currentLocale) {
    final bgColor = isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);
    final headerColor = isDark ? const Color(0xFF3A3B3C) : const Color(0xFF2C3E50);
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50);

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 280,
        color: bgColor,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: headerColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(AppStrings.get('app_name', currentLocale), style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(child: Container()),
              Container(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    _toggleDrawer();
                    Navigator.of(context).pushNamed('/settings');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF3498DB), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(IconData(0xe8b8, fontFamily: 'MaterialIcons'), color: Color(0xFFFFFFFF), size: 20),
                        const SizedBox(width: 8),
                        Text(AppStrings.get('settings', currentLocale), style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
                    child: Center(
                      child: Text(
                        AppStrings.get('app_name', currentLocale),
                        style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/settings'),
                    child: const Icon(IconData(0xe5d3, fontFamily: 'MaterialIcons'), color: Color(0xFFFFFFFF), size: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  Container(color: bgColor, child: Center(child: Text('Home', style: TextStyle(fontSize: 24, color: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D))))),
                  Container(color: bgColor, child: Center(child: Text(AppStrings.get('my_games', currentLocale), style: TextStyle(fontSize: 24, color: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D))))),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0), width: 1)),
              ),
              child: Row(
                children: [
                  _buildBottomItem(0, AppIcons.homeOutline, AppIcons.homeFilled, AppStrings.get('home', currentLocale), isDark),
                  _buildBottomItem(1, AppIcons.matchesOutline, AppIcons.matchesFilled, AppStrings.get('my_games', currentLocale), isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem(int index, String outlineIcon, String filledIcon, String label, bool isDark) {
    final isSelected = _selectedIndex == index;
    final inactiveColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.string(
                  isSelected ? filledIcon : outlineIcon,
                  color: isSelected ? const Color(0xFF3498DB) : inactiveColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? const Color(0xFF3498DB) : inactiveColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final locale = LocaleProvider.of(context);
    final isDark = theme?.isDark ?? false;
    final currentLocale = locale?.locale ?? 'pt';

    final bgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFF0F0F0);
    final appBarColor = isDark ? const Color(0xFF242526) : const Color(0xFF2C3E50);
    final cardColor = isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50);
    final subtitleColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D);

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: appBarColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(IconData(0xe5c4, fontFamily: 'MaterialIcons'), color: Color(0xFFFFFFFF), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(AppStrings.get('settings', currentLocale), style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8)),
                      child: GestureDetector(
                        onTap: () => theme?.toggleTheme(!isDark),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(const IconData(0xe3a9, fontFamily: 'MaterialIcons'), color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(child: Text(AppStrings.get('dark_mode', currentLocale), style: TextStyle(fontSize: 16, color: textColor))),
                              Container(
                                width: 50,
                                height: 28,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: isDark ? const Color(0xFF3498DB) : const Color(0xFFCED0D4)),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFFFFF)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8)),
                      child: GestureDetector(
                        onTap: () => _showLanguageDialog(context, currentLocale, locale, isDark),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(const IconData(0xe8e2, fontFamily: 'MaterialIcons'), color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppStrings.get('language', currentLocale), style: TextStyle(fontSize: 16, color: textColor)),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentLocale == 'pt' ? AppStrings.get('portuguese', currentLocale) : AppStrings.get('english', currentLocale),
                                      style: TextStyle(fontSize: 14, color: subtitleColor),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(const IconData(0xe5df, fontFamily: 'MaterialIcons'), color: subtitleColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, String currentLocale, LocaleProvider? localeProvider, bool isDark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: const Color(0x80000000),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(AppStrings.get('choose_language', currentLocale), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50))),
                ),
                _buildLanguageOption(context, 'pt', AppStrings.get('portuguese', currentLocale), currentLocale == 'pt', localeProvider, isDark),
                Container(height: 1, color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0)),
                _buildLanguageOption(context, 'en', AppStrings.get('english', currentLocale), currentLocale == 'en', localeProvider, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String localeCode, String label, bool isSelected, LocaleProvider? localeProvider, bool isDark) {
    return GestureDetector(
      onTap: () {
        localeProvider?.changeLocale(localeCode);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: 16, color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50)))),
            if (isSelected) const Icon(IconData(0xe5ca, fontFamily: 'MaterialIcons'), color: Color(0xFF3498DB), size: 24),
          ],
        ),
      ),
    );
  }
}