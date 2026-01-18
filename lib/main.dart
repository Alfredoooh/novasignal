import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color transparent = Color(0x00000000);

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
      'home': 'Inicio',
      'my_games': 'Meus Jogos',
      'tv': 'TV',
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
      'app_name': 'Bet Manager',
      'home': 'Home',
      'my_games': 'My Games',
      'tv': 'TV',
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
  
  static const String matchesOutline = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m19,3H5C2.243,3,0,5.243,0,8v8c0,2.757,2.243,5,5,5h14c2.757,0,5-2.243,5-5v-8c0-2.757-2.243-5-5-5Zm3,11h-2v-4h2v4Zm-10,0c-1.103,0-2-.897-2-2s.897-2,2-2,2,.897,2,2-.897,2-2,2ZM2,10h2v4h-2v-4Zm0,6h2c1.103,0,2-.897,2-2v-4c0-1.103-.897-2-2-2h-2c0-1.654,1.346-3,3-3h6v3.142c-1.72.447-3,1.999-3,3.858s1.28,3.411,3,3.858v3.142h-6c-1.654,0-3-1.346-3-3Zm17,3h-6v-3.142c1.72-.447,3-1.999,3-3.858s-1.28-3.411-3-3.858v-3.142h6c1.654,0,3,1.346,3,3h-2c-1.103,0-2,.897-2,2v4c0,1.103.897,2,2,2h2c0,1.654-1.346,3-3,3Z"/></svg>''';
  
  static const String matchesFilled = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m12,14c-1.103,0-2-.897-2-2s.897-2,2-2,2,.897,2,2-.897,2-2,2ZM3,10H0v4h3v-4Zm18,4h3v-4h-3v4Zm-2,0v-4c0-1.103.897-2,2-2h3c0-2.757-2.243-5-5-5h-6v5.142c1.72.447,3,1.999,3,3.858s-1.28,3.411-3,3.858v5.142h6c2.757,0,5-2.243,5-5h-3c-1.103,0-2-.897-2-2Zm-8,1.858c-1.72-.447-3-1.999-3-3.858s1.28-3.411,3-3.858V3h-6C2.243,3,0,5.243,0,8h3c1.103,0,2,.897,2,2v4c0,1.103-.897,2-2,2H0c0,2.757,2.243,5,5,5h6v-5.142Z"/></svg>''';
  
  static const String tvOutline = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,3H5A5.006,5.006,0,0,0,0,8v6a5.006,5.006,0,0,0,5,5h6v1H8a1,1,0,0,0,0,2h8a1,1,0,0,0,0-2H13V19h6a5.006,5.006,0,0,0,5-5V8A5.006,5.006,0,0,0,19,3Zm3,11a3,3,0,0,1-3,3H5a3,3,0,0,1-3-3V8A3,3,0,0,1,5,5H19a3,3,0,0,1,3,3Z"/></svg>''';
  
  static const String tvFilled = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,3H5A5.006,5.006,0,0,0,0,8v6a5.006,5.006,0,0,0,5,5h6v1H8a1,1,0,0,0,0,2h8a1,1,0,0,0,0-2H13V19h6a5.006,5.006,0,0,0,5-5V8A5.006,5.006,0,0,0,19,3Z"/></svg>''';
  
  static const String settingsIcon = '''<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"><path d="M844.8 580.266667c2.133333-14.933333 4.266667-29.866667 4.266667-46.933334s-2.133333-32-4.266667-46.933333l96-68.266667c8.533333-6.4 12.8-19.2 6.4-29.866666L853.333333 230.4c-6.4-10.666667-17.066667-14.933333-27.733333-8.533333l-106.666667 49.066666c-25.6-19.2-51.2-34.133333-81.066666-46.933333L627.2 106.666667c-2.133333-10.666667-10.666667-19.2-21.333333-19.2h-183.466667c-10.666667 0-21.333333 8.533333-21.333333 19.2l-10.666667 117.333333c-29.866667 12.8-57.6 27.733333-81.066667 46.933333l-106.666666-49.066666c-10.666667-4.266667-23.466667 0-27.733334 8.533333l-91.733333 157.866667c-6.4 10.666667-2.133333 23.466667 6.4 29.866666l96 68.266667c-2.133333 14.933333-4.266667 29.866667-4.266667 46.933333s2.133333 32 4.266667 46.933334L85.333333 648.533333c-8.533333 6.4-12.8 19.2-6.4 29.866667L170.666667 836.266667c6.4 10.666667 17.066667 14.933333 27.733333 8.533333l106.666667-49.066667c25.6 19.2 51.2 34.133333 81.066666 46.933334l10.666667 117.333333c2.133333 10.666667 10.666667 19.2 21.333333 19.2h183.466667c10.666667 0 21.333333-8.533333 21.333333-19.2l10.666667-117.333333c29.866667-12.8 57.6-27.733333 81.066667-46.933334l106.666666 49.066667c10.666667 4.266667 23.466667 0 27.733334-8.533333l91.733333-157.866667c6.4-10.666667 2.133333-23.466667-6.4-29.866667l-89.6-68.266666zM512 746.666667c-117.333333 0-213.333333-96-213.333333-213.333334s96-213.333333 213.333333-213.333333 213.333333 96 213.333333 213.333333-96 213.333333-213.333333 213.333334z" fill="#607D8B"/><path d="M512 277.333333c-140.8 0-256 115.2-256 256s115.2 256 256 256 256-115.2 256-256-115.2-256-256-256z m0 362.666667c-59.733333 0-106.666667-46.933333-106.666667-106.666667s46.933333-106.666667 106.666667-106.666666 106.666667 46.933333 106.666667 106.666666-46.933333 106.666667-106.666667 106.666667z" fill="#455A64"/></svg>''';
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
  late YoutubePlayerController _youtubeController;
  bool _showVideoLoading = true;
  bool _showPopupMenu = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _drawerAnimation = CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut);
    
    _youtubeController = YoutubePlayerController(
      initialVideoId: '3Np1_JcC36c',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        hideControls: true,
        disableDragSeek: true,
        hideThumbnail: true,
        enableCaption: false,
        loop: true,
        forceHD: true,
        controlsVisibleAtStart: false,
      ),
    );
    
    _youtubeController.addListener(() {
      if (_selectedIndex == 2 && _youtubeController.value.isPlaying && _showVideoLoading) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() => _showVideoLoading = false);
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex == 2) {
      if (!_youtubeController.value.isPlaying) {
        _youtubeController.play();
        setState(() => _showVideoLoading = true);
      }
    } else {
      if (_youtubeController.value.isPlaying) {
        _youtubeController.pause();
      }
    }
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _youtubeController.dispose();
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

    String appBarTitle = AppStrings.get('app_name', currentLocale);
    if (_selectedIndex == 1) {
      appBarTitle = AppStrings.get('my_games', currentLocale);
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
                                      style: TextStyle(
                                        color: const Color(0xFFFFFFFF),
                                        fontSize: 20,
                                        fontWeight: _selectedIndex == 0 ? FontWeight.w900 : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  CompositedTransformTarget(
                                    link: _layerLink,
                                    child: GestureDetector(
                                      onTap: _togglePopupMenu,
                                      child: const Icon(Symbols.more_vert_rounded, color: Color(0xFFFFFFFF), size: 24),
                                    ),
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
                                _buildTVScreen(bgColor),
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
                                _buildBottomItem(2, AppIcons.tvOutline, AppIcons.tvFilled, AppStrings.get('tv', currentLocale), isDark),
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

  Widget _buildTVScreen(Color bgColor) {
    return Container(
      color: bgColor,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  YoutubePlayer(
                    controller: _youtubeController,
                    showVideoProgressIndicator: false,
                    progressIndicatorColor: const Color(0x00000000),
                    bottomActions: const [],
                    topActions: const [],
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(color: const Color(0x00000000)),
                    ),
                  ),
                  if (!_youtubeController.value.isReady)
                    Positioned.fill(
                      child: Container(
                        color: const Color(0xFF000000),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Carregando',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeInOut,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                  onEnd: () {
                                    Future.delayed(Duration(milliseconds: index * 200), () {
                                      if (mounted) setState(() {});
                                    });
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: bgColor,
              child: Center(
                child: Text(
                  'Conteudo adicional',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFFB0B3B8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isDark, String currentLocale) {
    final drawerBgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2C3E50);

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
                      child: SvgPicture.string(
                        AppIcons.settingsIcon,
                        color: const Color(0xFFFFFFFF),
                      ),
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
    final inactiveColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
            if (index == 2) {
              _youtubeController.play();
            } else {
              _youtubeController.pause();
            }
          });
        },
        child: Container(
          color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 0,
                  vertical: isSelected ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3498DB).withOpacity(0.15) : transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: SvgPicture.string(
                          isSelected ? filledIcon : outlineIcon,
                          color: isSelected ? const Color(0xFF3498DB) : inactiveColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/account'),
                      child: Container(
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8)),
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
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => theme?.toggleTheme(!isDark),
                      child: Container(
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8)),
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
                                  color: isDark ? const Color(0xFF3498DB) : const Color(0xFFCED0D4),
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
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _showLanguageDialog(context, currentLocale, locale, isDark),
                      child: Container(
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8)),
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
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/security'),
                      child: Container(
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8)),
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
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/help'),
                      child: Container(
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8)),
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
    showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(
        transitionDuration: Duration(milliseconds: 300),
        reverseTransitionDuration: Duration(milliseconds: 200),
      ),
      builder: (context) {
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
              const Icon(Symbols.check_rounded, color: Color(0xFF3498DB), size: 24),
          ],
        ),
      ),
    );
  }
}