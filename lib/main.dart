import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color transparent = Color(0x00000000);
const Color primaryColor = Color(0xFF2C3E50);

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
      'app_name': 'TVgo',
      'home': 'Inicio',
      'channels': 'Canais',
      'live_tv': 'Partidas',
      'settings': 'Configuracoes',
      'dark_mode': 'Modo Escuro',
      'language': 'Idioma',
      'choose_language': 'Escolher Idioma',
      'portuguese': 'Portugues',
      'english': 'English',
      'help': 'Ajuda',
      'security': 'Seguranca e Privacidade',
      'account': 'Configuracoes da Conta',
    },
    'en': {
      'app_name': 'TVgo',
      'home': 'Home',
      'channels': 'Channels',
      'live_tv': 'Matches',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'choose_language': 'Choose Language',
      'portuguese': 'Portugues',
      'english': 'English',
      'help': 'Help',
      'security': 'Security and Privacy',
      'account': 'Account Settings',
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
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = prefs.getBool('isDark') ?? false;
      _locale = prefs.getString('locale') ?? 'pt';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    await prefs.setString('locale', _locale);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      isDark: _isDark,
      toggleTheme: (v) {
        setState(() => _isDark = v);
        _savePreferences();
      },
      child: LocaleProvider(
        locale: _locale,
        changeLocale: (v) {
          setState(() => _locale = v);
          _savePreferences();
        },
        child: WidgetsApp(
          color: const Color(0xFFFFFFFF),
          pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
            return PageRouteBuilder<T>(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) => builder(context),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  fillColor: transparent,
                  child: child,
                );
              },
            );
          },
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/settings':
                page = const SettingsScreen();
                break;
              case '/help':
                page = const HelpScreen();
                break;
              case '/security':
                page = const SecurityScreen();
                break;
              case '/account':
                page = const AccountScreen();
                break;
              default:
                page = const HomeScreen();
            }
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  fillColor: transparent,
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

  static const String walletOutline = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" id="Layer_1" data-name="Layer 1" viewBox="0 0 24 24" width="512" height="512"><path d="M20.5,6H5.5c-.789,0-1.53-.376-2-.999,.457-.607,1.184-1.001,2-1.001H22.5c1.972-.034,1.971-2.967,0-3H5.5C2.468,1,0,3.467,0,6.5v11c0,3.033,2.468,5.5,5.5,5.5h15c1.93,0,3.5-1.57,3.5-3.5V9.5c0-1.93-1.57-3.5-3.5-3.5Zm.5,13.5c0,.276-.225,.5-.5,.5H5.5c-1.379,0-2.5-1.122-2.5-2.5V8.396c.763,.39,1.618,.604,2.5,.604h15c.275,0,.5,.224,.5,.5v10Zm-2-5c-.034,1.972-2.967,1.971-3,0,.034-1.972,2.967-1.971,3,0Z"/></svg>''';

  static const String walletFilled = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" id="Layer_1" data-name="Layer 1" viewBox="0 0 24 24" width="512" height="512"><path d="M21,6H5c-.859,0-1.672-.372-2.235-.999,.55-.614,1.349-1.001,2.235-1.001H23c1.308-.006,1.307-1.995,0-2H5C2.239,2,0,4.239,0,7v10c0,2.761,2.239,5,5,5H21c1.657,0,3-1.343,3-3V9c0-1.657-1.343-3-3-3Zm-1,9c-1.308-.006-1.308-1.994,0-2,1.308,.006,1.308,1.994,0,2Z"/></svg>''';

  static const String matchesOutline = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" id="Layer_1" data-name="Layer 1" viewBox="0 0 24 24">
  <path d="m19,3H5C2.243,3,0,5.243,0,8v8c0,2.757,2.243,5,5,5h14c2.757,0,5-2.243,5-5v-8c0-2.757-2.243-5-5-5Zm3,11h-2v-4h2v4Zm-10,0c-1.103,0-2-.897-2-2s.897-2,2-2,2,.897,2,2-.897,2-2,2ZM2,10h2v4h-2v-4Zm0,6h2c1.103,0,2-.897,2-2v-4c0-1.103-.897-2-2-2h-2c0-1.654,1.346-3,3-3h6v3.142c-1.72.447-3,1.999-3,3.858s1.28,3.411,3,3.858v3.142h-6c-1.654,0-3-1.346-3-3Zm17,3h-6v-3.142c1.72-.447,3-1.999,3-3.858s-1.28-3.411-3-3.858v-3.142h6c1.654,0,3,1.346,3,3h-2c-1.103,0-2,.897-2,2v4c0,1.103.897,2,2,2h2c0,1.654-1.346,3-3,3Z"/>
</svg>''';

  static const String matchesFilled = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" id="Layer_1" data-name="Layer 1" viewBox="0 0 24 24">
  <path d="m12,14c-1.103,0-2-.897-2-2s.897-2,2-2,2,.897,2,2-.897,2-2,2ZM3,10H0v4h3v-4Zm18,4h3v-4h-3v4Zm-2,0v-4c0-1.103.897-2,2-2h3c0-2.757-2.243-5-5-5h-6v5.142c1.72.447,3,1.999,3,3.858s-1.28,3.411-3,3.858v5.142h6c2.757,0,5-2.243,5-5h-3c-1.103,0-2-.897-2-2Zm-8,1.858c-1.72-.447-3-1.999-3-3.858s1.28-3.411,3-3.858V3h-6C2.243,3,0,5.243,0,8h3c1.103,0,2,.897,2,2v4c0,1.103-.897,2-2,2H0c0,2.757,2.243,5,5,5h6v-5.142Z"/>
</svg>''';

  static const String settingsIcon = '''<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"><path d="M844.8 580.266667c2.133333-14.933333 4.266667-29.866667 4.266667-46.933334s-2.133333-32 4.266667-46.933333l96-68.266667c8.533333-6.4 12.8-19.2 6.4-29.866666L853.333333 230.4c-6.4-10.666667-17.066667-14.933333-27.733333-8.533333l-106.666667 49.066666c-25.6-19.2-51.2-34.133333-81.066666-46.933333L627.2 106.666667c-2.133333-10.666667-10.666667-19.2-21.333333-19.2h-183.466667c-10.666667 0-21.333333 8.533333-21.333333 19.2l-10.666667 117.333333c-29.866667 12.8-57.6 27.733333-81.066667 46.933333l-106.666666-49.066666c-10.666667-4.266667-23.466667 0-27.733334 8.533333l-91.733333 157.866667c-6.4 10.666667-2.133333 23.466667 6.4 29.866666l96 68.266667c-2.133333 14.933333-4.266667 29.866667-4.266667 46.933333s2.133333 32 4.266667 46.933334L85.333333 648.533333c-8.533333 6.4-12.8 19.2-6.4 29.866667L170.666667 836.266667c6.4 10.666667 17.066667 14.933333 27.733333 8.533333l106.666667-49.066667c25.6 19.2 51.2 34.133333 81.066666 46.933334l10.666667 117.333333c2.133333 10.666667 10.666667 19.2 21.333333 19.2h183.466667c10.666667 0 21.333333-8.533333 21.333333-19.2l10.666667-117.333333c29.866667-12.8 57.6-27.733333 81.066667-46.933334l106.666666 49.066667c10.666667 4.266667 23.466667 0 27.733334-8.533333l91.733333-157.866667c6.4-10.666667 2.133333-23.466667-6.4-29.866667l-89.6-68.266666zM512 746.666667c-117.333333 0-213.333333-96-213.333333-213.333334s96-213.333333 213.333333-213.333333 213.333333 96 213.333333 213.333333-96 213.333333-213.333333 213.333334z" fill="#607D8B"/><path d="M512 277.333333c-140.8 0-256 115.2-256 256s115.2 256 256 256 256-115.2 256-256-115.2-256-256-256z m0 362.666667c-59.733333 0-106.666667-46.933333-106.666667-106.666667s46.933333-106.666667 106.666667-106.666666 106.666667 46.933333 106.666667 106.666666-46.933333 106.666667-106.666667 106.666667z" fill="#455A64"/></svg>''';
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
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
    final appBarColor = primaryColor;

    String appBarTitle = AppStrings.get('app_name', currentLocale);
    if (_selectedIndex == 1) {
      appBarTitle = AppStrings.get('channels', currentLocale);
    } else if (_selectedIndex == 2) {
      appBarTitle = AppStrings.get('live_tv', currentLocale);
    }

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: _selectedIndex == 2 ? const Color(0xFF000000) : appBarColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _drawerAnimation,
            builder: (context, child) {
              final slideValue = _drawerAnimation.value * 280;

              return Transform.translate(
                offset: Offset(slideValue, 0),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: _isDrawerOpen ? [const BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(-5, 0))] : null,
                  ),
                  child: Container(
                    color: bgColor,
                    child: SafeArea(
                      top: _selectedIndex != 2,
                      child: Column(
                        children: [
                          if (_selectedIndex != 2)
                            Container(
                              color: appBarColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: _toggleDrawer,
                                    child: const Icon(Symbols.menu_rounded, color: Color(0xFFFFFFFF), size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      appBarTitle,
                                      style: const TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const Icon(Symbols.more_vert_rounded, color: Color(0xFFFFFFFF), size: 24),
                                ],
                              ),
                            ),
                          Expanded(
                            child: IndexedStack(
                              index: _selectedIndex,
                              children: [
                                _buildHomeScreen(bgColor, isDark),
                                _buildChannelsScreen(bgColor, isDark, currentLocale),
                                _buildMatchesScreen(bgColor),
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
                                _buildBottomItemCenter(1, AppIcons.walletOutline, AppIcons.walletFilled, AppStrings.get('channels', currentLocale), isDark),
                                _buildBottomItem(2, AppIcons.matchesOutline, AppIcons.matchesFilled, AppStrings.get('live_tv', currentLocale), isDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _toggleDrawer,
              child: Container(color: const Color(0x80000000)),
            ),
          AnimatedBuilder(
            animation: _drawerAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-280 + (_drawerAnimation.value * 280), 0),
                child: _buildDrawer(isDark, currentLocale),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen(Color bgColor, bool isDark) {
    return Container(
      color: bgColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: List.generate(5, (index) => _buildSkeletonCard(isDark)),
      ),
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0), width: 8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildShimmer(40, 40, isDark, isCircle: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmer(120, 12, isDark),
                      const SizedBox(height: 6),
                      _buildShimmer(80, 10, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildShimmer(double.infinity, 200, isDark),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmer(double.infinity, 12, isDark),
                const SizedBox(height: 6),
                _buildShimmer(250, 12, isDark),
                const SizedBox(height: 6),
                _buildShimmer(180, 12, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(double width, double height, bool isDark, {bool isCircle = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : BorderRadius.zero,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) setState(() {});
          });
        }
      },
    );
  }

  Widget _buildChannelsScreen(Color bgColor, bool isDark, String currentLocale) {
    return Container(
      color: bgColor,
      child: Center(
        child: Text(
          AppStrings.get('channels', currentLocale),
          style: TextStyle(
            fontSize: 24,
            color: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchesScreen(Color bgColor) {
    return Container(
      color: bgColor,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * 9 / 16,
            color: const Color(0xFF000000),
            child: const Center(
              child: Icon(
                Symbols.sports_soccer,
                color: Color(0xFF666666),
                size: 80,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: bgColor,
              child: const Center(
                child: Text(
                  'Conteudo adicional',
                  style: TextStyle(fontSize: 16, color: Color(0xFFB0B3B8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isDark, String currentLocale) {
    final drawerBgColor = primaryColor;

    return Container(
      width: 280,
      color: drawerBgColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.get('app_name', currentLocale),
                    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(child: Container()),
            GestureDetector(
              onTap: () {
                _toggleDrawer();
                Navigator.of(context).pushNamed('/settings');
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.string(AppIcons.settingsIcon, color: const Color(0xFFFFFFFF)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.get('settings', currentLocale),
                      style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem(int index, String outlineIcon, String filledIcon, String label, bool isDark) {
    final isSelected = _selectedIndex == index;
    final selectedColor = isDark ? const Color(0xFFFFFFFF) : primaryColor;
    final inactiveColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulseIcon(
                icon: isSelected ? filledIcon : outlineIcon,
                color: isSelected ? selectedColor : inactiveColor,
                isSelected: isSelected,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? selectedColor : inactiveColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomItemCenter(int index, String outlineIcon, String filledIcon, String label, bool isDark) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: SvgPicture.string(
                    isSelected ? filledIcon : outlineIcon,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? (isDark ? const Color(0xFFFFFFFF) : primaryColor) : (isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D)),
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

class _PulseIcon extends StatefulWidget {
  final String icon;
  final Color color;
  final bool isSelected;

  const _PulseIcon({
    required this.icon,
    required this.color,
    required this.isSelected,
  });

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_PulseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected && widget.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.string(widget.icon, color: widget.color),
          ),
        );
      },
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
    final appBarColor = primaryColor;
    final cardColor = isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50);
    final subtitleColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D);
    final dividerColor = isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0);

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
                    child: const Icon(Symbols.arrow_back_rounded, color: Color(0xFFFFFFFF), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppStrings.get('settings', currentLocale),
                    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/account'),
                      child: Container(
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Symbols.person_rounded, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('account', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Icon(Symbols.chevron_right_rounded, color: subtitleColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(height: 1, color: dividerColor),
                    GestureDetector(
                      onTap: () => theme?.toggleTheme(!isDark),
                      child: Container(
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Symbols.dark_mode_rounded, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('dark_mode', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Container(
                                width: 50,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: isDark ? primaryColor : const Color(0xFFCED0D4),
                                ),
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
                    Container(height: 1, color: dividerColor),
                    GestureDetector(
                      onTap: () => _showLanguageDialog(context, currentLocale, locale, isDark),
                      child: Container(
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Symbols.language_rounded, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.get('language', currentLocale),
                                      style: TextStyle(fontSize: 16, color: textColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentLocale == 'pt' ? AppStrings.get('portuguese', currentLocale) : AppStrings.get('english', currentLocale),
                                      style: TextStyle(fontSize: 14, color: subtitleColor),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Symbols.chevron_right_rounded, color: subtitleColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(height: 1, color: dividerColor),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/security'),
                      child: Container(
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Symbols.lock_rounded, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('security', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Icon(Symbols.chevron_right_rounded, color: subtitleColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(height: 1, color: dividerColor),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/help'),
                      child: Container(
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Symbols.help_rounded, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('help', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Icon(Symbols.chevron_right_rounded, color: subtitleColor, size: 20),
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
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.get('choose_language', currentLocale),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Symbols.close_rounded,
                          size: 24,
                          color: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
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
        color: transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50)),
              ),
            ),
            if (isSelected)
              const Icon(Symbols.check_rounded, color: primaryColor, size: 24),
          ],
        ),
      ),
    );
  }
}