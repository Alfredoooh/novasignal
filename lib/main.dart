import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
      'app_name': 'Cabinda Shop',
      'home': 'Inicio',
      'channels': 'Loja',
      'live_tv': 'Cesta',
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
      'app_name': 'Cabinda Shop',
      'home': 'Home',
      'channels': 'Store',
      'live_tv': 'Basket',
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
              case '/new_product':
                page = const NewProductScreen();
                break;
              case '/product_details':
                page = ProductDetailsScreen(product: settings.arguments as Map<String, dynamic>);
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

  static const String storeOutline = '''<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" id="Outline" viewBox="0 0 24 24" width="512" height="512"><path d="M24,10a.988.988,0,0,0-.024-.217l-1.3-5.868A4.968,4.968,0,0,0,17.792,0H6.208a4.968,4.968,0,0,0-4.88,3.915L.024,9.783A.988.988,0,0,0,0,10v1a3.984,3.984,0,0,0,1,2.643V19a5.006,5.006,0,0,0,5,5H18a5.006,5.006,0,0,0,5-5V13.643A3.984,3.984,0,0,0,24,11ZM2,10.109l1.28-5.76A2.982,2.982,0,0,1,6.208,2H7V5A1,1,0,0,0,9,5V2h6V5a1,1,0,0,0,2,0V2h.792A2.982,2.982,0,0,1,20.72,4.349L22,10.109V11a2,2,0,0,1-2,2H19a2,2,0,0,1-2-2,1,1,0,0,0-2,0,2,2,0,0,1-2,2H11a2,2,0,0,1-2-2,1,1,0,0,0-2,0,2,2,0,0,1-2,2H4a2,2,0,0,1-2-2ZM18,22H6a3,3,0,0,1-3-3V14.873A3.978,3.978,0,0,0,4,15H5a3.99,3.99,0,0,0,3-1.357A3.99,3.99,0,0,0,11,15h2a3.99,3.99,0,0,0,3-1.357A3.99,3.99,0,0,0,19,15h1a3.978,3.978,0,0,0,1-.127V19A3,3,0,0,1,18,22Z"/></svg>''';

  static const String storeFilled = '''<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" id="Filled" viewBox="0 0 24 24" width="512" height="512"><path d="M16,13a5,5,0,0,1-8,0,4.956,4.956,0,0,1-7,.977V19a5.006,5.006,0,0,0,5,5H18a5.006,5.006,0,0,0,5-5V13.974A4.956,4.956,0,0,1,16,13Z"/><path d="M21.7,3.131A3.975,3.975,0,0,0,17.792,0H17V3a1,1,0,0,1-2,0V0H9V3A1,1,0,0,1,7,3V0H6.208A3.975,3.975,0,0,0,2.3,3.132L1.022,8.9,1,10.02A3,3,0,0,0,7,10a1,1,0,0,1,2,0,3,3,0,1,0,6,0,1,1,0,0,1,2,0,3,3,0,1,0,6,0V9.107Z"/></svg>''';

  static const String basketOutline = '''<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" id="Outline" viewBox="0 0 24 24" width="512" height="512"><path d="M22.713,4.077A2.993,2.993,0,0,0,20.41,3H4.242L4.2,2.649A3,3,0,0,0,1.222,0H1A1,1,0,0,0,1,2h.222a1,1,0,0,1,.993.883l1.376,11.7A5,5,0,0,0,8.557,19H19a1,1,0,0,0,0-2H8.557a3,3,0,0,1-2.82-2h11.92a5,5,0,0,0,4.921-4.113l.785-4.354A2.994,2.994,0,0,0,22.713,4.077ZM21.4,6.178l-.786,4.354A3,3,0,0,1,17.657,13H5.419L4.478,5H20.41A1,1,0,0,1,21.4,6.178Z"/><circle cx="7" cy="22" r="2"/><circle cx="17" cy="22" r="2"/></svg>''';

  static const String basketFilled = '''<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" id="Filled" viewBox="0 0 24 24" width="512" height="512"><path d="M22.713,4.077A2.993,2.993,0,0,0,20.41,3H4.242L4.2,2.649A3,3,0,0,0,1.222,0H1A1,1,0,0,0,1,2h.222a1,1,0,0,1,.993.883l1.376,11.7A5,5,0,0,0,8.557,19H19a1,1,0,0,0,0-2H8.557a3,3,0,0,1-2.82-2h11.92a5,5,0,0,0,4.921-4.113l.785-4.354A2.994,2.994,0,0,0,22.713,4.077Z"/><circle cx="7" cy="22" r="2"/><circle cx="17" cy="22" r="2"/></svg>''';

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

class NewProductScreen extends StatelessWidget {
  const NewProductScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final isDark = theme?.isDark ?? false;
    final bgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFF0F0F0);
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(product['title'], style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product['thumbnail'], fit: BoxFit.cover, height: 200, width: double.infinity),
            const SizedBox(height: 16),
            Text(product['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            Text('\\[ {product['price']}', style: TextStyle(fontSize: 20, color: primaryColor)),
            const SizedBox(height: 16),
            Text(product['description'], style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
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
  late Future<List<dynamic>> _productsFuture;
  String _selectedCategory = 'Todos';

  final List<String> _categories = ['Todos', 'Mais Vendidos', 'Em Promoção', 'Segunda Mão'];

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _drawerAnimation = CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut);
    _productsFuture = fetchProducts();
  }

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['products'];
    } else {
      throw Exception('Failed to load products');
    }
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
    FontWeight titleWeight = FontWeight.w900;
    if (_selectedIndex == 1) {
      appBarTitle = AppStrings.get('channels', currentLocale);
      titleWeight = FontWeight.w600;
    } else if (_selectedIndex == 2) {
      appBarTitle = AppStrings.get('live_tv', currentLocale);
      titleWeight = FontWeight.w600;
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: _toggleDrawer,
                                    child: const Icon(Icons.menu, color: Color(0xFFFFFFFF), size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      appBarTitle,
                                      style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 20,
                                        fontWeight: titleWeight,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.more_vert, color: Color(0xFFFFFFFF), size: 24),
                                ],
                              ),
                            ),
                          if (_selectedIndex == 0)
                            Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  final category = _categories[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: FilterChip(
                                      label: Text(category),
                                      selected: _selectedCategory == category,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedCategory = selected ? category : 'Todos';
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          Expanded(
                            child: IndexedStack(
                              index: _selectedIndex,
                              children: [
                                _buildHomeScreen(bgColor, isDark),
                                _buildStoreScreen(bgColor, isDark, currentLocale),
                                _buildBasketScreen(bgColor, isDark, currentLocale),
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
                                _buildBottomItem(1, AppIcons.storeOutline, AppIcons.storeFilled, AppStrings.get('channels', currentLocale), isDark),
                                _buildBottomItem(2, AppIcons.basketOutline, AppIcons.basketFilled, AppStrings.get('live_tv', currentLocale), isDark),
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
      child: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MasonryGridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemCount: 10,
              itemBuilder: (context, index) => StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: _buildSkeletonProductCard(isDark),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> products = snapshot.data!;
            if (_selectedCategory != 'Todos') {
              // Simulate filtering, in real app implement actual filter
              products = products.take(5).toList();
            }
            return MasonryGridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/product_details', arguments: product);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: Image.network(
                            product['thumbnail'],
                            height: 120 + (index % 3 * 20),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                color: Colors.grey,
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['title'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\ \]{product['price']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildSkeletonProductCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmer(double.infinity, 120, isDark),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmer(100, 12, isDark),
                const SizedBox(height: 4),
                _buildShimmer(60, 10, isDark),
                const SizedBox(height: 4),
                _buildShimmer(80, 12, isDark),
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

  Widget _buildStoreScreen(Color bgColor, bool isDark, String currentLocale) {
    return Container(
      color: bgColor,
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildBasketScreen(Color bgColor, bool isDark, String currentLocale) {
    return Container(
      color: bgColor,
      child: const SizedBox.shrink(),
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
          padding: const EdgeInsets.symmetric(vertical: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF), size: 24),
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
                              Icon(Icons.person, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('account', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: subtitleColor, size: 20),
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
                              Icon(Icons.dark_mode, color: textColor, size: 24),
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
                              Icon(Icons.language, color: textColor, size: 24),
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
                              Icon(Icons.chevron_right, color: subtitleColor, size: 20),
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
                              Icon(Icons.lock, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('security', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: subtitleColor, size: 20),
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
                              Icon(Icons.help, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('help', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: subtitleColor, size: 20),
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
                          Icons.close,
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
              const Icon(Icons.check, color: primaryColor, size: 24),
          ],
        ),
      ),
    );
  }
}