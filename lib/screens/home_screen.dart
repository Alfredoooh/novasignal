import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'dart:convert';

import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_strings.dart';
import '../assets/app_icons.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/drawer_menu.dart';
import '../tabs/inicio_tab_screen.dart';
import '../tabs/loja_tab_screen.dart';
import '../tabs/basket_tab_screen.dart';

const Color transparent = Color(0x00000000);
const Color primaryColor = Color(0xFF2C3E50);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDrawerOpen = false;
  late Future<List<dynamic>> _productsFuture;
  String _selectedCategory = 'Todos';

  final List<String> _categories = ['Todos', 'Mais Vendidos', 'Em Promoção', 'Segunda Mão'];
  final translator = GoogleTranslator();
  String _translatedDarkMode = 'Modo Escuro';
  String _translatedNotifications = 'Notificações';
  
  final Map<String, String> _categoryTranslations = {
    'Todos': 'Todos',
    'Mais Vendidos': 'Mais Vendidos',
    'Em Promoção': 'Em Promoção',
    'Segunda Mão': 'Segunda Mão',
  };

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _drawerAnimation = CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawerController,
        curve: Curves.easeOut,
      ),
    );
    _productsFuture = fetchProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _translateTexts();
    });
  }

  Future<void> _translateTexts() async {
    final localeProvider = LocaleProvider.of(context);
    final currentLocale = localeProvider?.locale ?? 'pt';
    
    if (currentLocale == 'pt') {
      setState(() {
        _translatedDarkMode = 'Modo Escuro';
        _translatedNotifications = 'Notificações';
        _categoryTranslations['Todos'] = 'Todos';
        _categoryTranslations['Mais Vendidos'] = 'Mais Vendidos';
        _categoryTranslations['Em Promoção'] = 'Em Promoção';
        _categoryTranslations['Segunda Mão'] = 'Segunda Mão';
      });
      return;
    }

    try {
      final darkModeTranslation = await translator.translate('Modo Escuro', from: 'pt', to: 'en');
      final notificationsTranslation = await translator.translate('Notificações', from: 'pt', to: 'en');
      
      final Map<String, String> newTranslations = {};
      for (var category in _categories) {
        final translation = await translator.translate(category, from: 'pt', to: 'en');
        newTranslations[category] = translation.text;
      }
      
      if (mounted) {
        setState(() {
          _translatedDarkMode = darkModeTranslation.text;
          _translatedNotifications = notificationsTranslation.text;
          _categoryTranslations.addAll(newTranslations);
        });
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
  }

  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products?limit=50'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('products')) {
          return List<dynamic>.from(data['products']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching from dummyjson: $e');
    }

    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
      if (response.statusCode == 200) {
        return List<dynamic>.from(json.decode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching from fakestoreapi: $e');
    }

    throw Exception('Failed to load products from all APIs');
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
      appBarTitle = AppStrings.get('basket', currentLocale);
      titleWeight = FontWeight.w600;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: appBarColor,
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
                                onTap: _toggleDrawer,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.menu_rounded, color: Color(0xFFFFFFFF), size: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  appBarTitle,
                                  style: TextStyle(
                                    color: const Color(0xFFFFFFFF),
                                    fontSize: 20,
                                    fontWeight: titleWeight,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // TODO: Implementar pesquisa
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(9),
                                    child: SvgPicture.string(
                                      AppIcons.searchIcon,
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  _showOptionsMenu(context, isDark, currentLocale, theme);
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.more_vert_rounded, color: Color(0xFFFFFFFF), size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedIndex == 0)
                          Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final isSelected = _selectedCategory == category;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = category;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDark ? const Color(0xFFFFFFFF) : primaryColor)
                                            : (isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _categoryTranslations[category] ?? category,
                                          style: TextStyle(
                                            color: isSelected
                                                ? (isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF))
                                                : (isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50)),
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        Expanded(
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: [
                              InicioTabScreen(
                                bgColor: bgColor,
                                isDark: isDark,
                                productsFuture: _productsFuture,
                                selectedCategory: _selectedCategory,
                                categories: _categories,
                              ),
                              LojaTabScreen(
                                bgColor: bgColor,
                                isDark: isDark,
                                currentLocale: currentLocale,
                              ),
                              BasketTabScreen(
                                bgColor: bgColor,
                                isDark: isDark,
                                currentLocale: currentLocale,
                              ),
                            ],
                          ),
                        ),
                        BottomBar(
                          selectedIndex: _selectedIndex,
                          onItemSelected: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          isDark: isDark,
                          homeLabel: AppStrings.get('home', currentLocale),
                          storeLabel: AppStrings.get('channels', currentLocale),
                          basketLabel: AppStrings.get('basket', currentLocale),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _toggleDrawer,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Container(
                    color: Color.lerp(
                      Colors.transparent,
                      const Color(0x80000000),
                      _fadeAnimation.value,
                    ),
                  );
                },
              ),
            ),
          AnimatedBuilder(
            animation: _drawerAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-280 + (_drawerAnimation.value * 280), 0),
                child: Opacity(
                  opacity: _drawerAnimation.value,
                  child: DrawerMenu(
                    appName: AppStrings.get('app_name', currentLocale),
                    settingsLabel: AppStrings.get('settings', currentLocale),
                    onSettingsTap: () {
                      _toggleDrawer();
                      Navigator.of(context).pushNamed('/settings');
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, bool isDark, String currentLocale, ThemeProvider? theme) {
    final cardColor = isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50);
    final dividerColor = isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.only(top: 60, right: 16),
            width: 280,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/account');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.person_rounded, color: textColor, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppStrings.get('account', currentLocale),
                              style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 1, color: dividerColor),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Abrir notificações
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_rounded, color: textColor, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _translatedNotifications,
                              style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 1, color: dividerColor),
                  GestureDetector(
                    onTap: () {
                      theme?.toggleTheme(!isDark);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.dark_mode_rounded, color: textColor, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _translatedDarkMode,
                              style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isDark ? primaryColor : const Color(0xFFCED0D4),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFFFFF),
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
          ),
        );
      },
    );
  }
}