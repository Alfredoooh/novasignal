import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:http/http.dart' as http;
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDrawerOpen = false;
  late Future<List<dynamic>> _productsFuture;
  String _selectedCategory = 'Todos';

  final List<String> _categories = ['Todos', 'Mais Vendidos', 'Em Promoção', 'Segunda Mão'];

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _drawerAnimation = CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeOutCubic,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeOutCubic,
    ));
    
    _productsFuture = fetchProducts();
  }

  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products?limit=50'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['products'];
      }
    } catch (e) {
      print('Error fetching from dummyjson: $e');
    }

    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching from fakestoreapi: $e');
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

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: appBarColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Stack(
        children: [
          // Drawer Menu
          DrawerMenu(
            appName: AppStrings.get('app_name', currentLocale),
            settingsLabel: AppStrings.get('settings', currentLocale),
            onSettingsTap: () {
              _toggleDrawer();
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          
          // Main Content with iOS-style push animation
          AnimatedBuilder(
            animation: _drawerAnimation,
            builder: (context, child) {
              final slideValue = _drawerAnimation.value * 280;
              final scale = _scaleAnimation.value;

              return Transform.translate(
                offset: Offset(slideValue, 0),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: _isDrawerOpen 
                        ? [
                            BoxShadow(
                              color: const Color(0x30000000),
                              blurRadius: 30,
                              spreadRadius: -5,
                              offset: const Offset(-8, 0),
                            )
                          ] 
                        : null,
                      borderRadius: _isDrawerOpen 
                        ? BorderRadius.circular(16)
                        : BorderRadius.zero,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      color: bgColor,
                      child: SafeArea(
                        child: Column(
                          children: [
                            // AppBar com bordas curvas
                            Container(
                              decoration: BoxDecoration(
                                color: appBarColor,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0x15000000),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  _AnimatedIconButton(
                                    onTap: _toggleDrawer,
                                    child: const Icon(Icons.menu, color: Color(0xFFFFFFFF), size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      appBarTitle,
                                      style: TextStyle(
                                        color: const Color(0xFFFFFFFF),
                                        fontSize: 20,
                                        fontWeight: titleWeight,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  _AnimatedIconButton(
                                    onTap: () {
                                      // TODO: Implementar pesquisa
                                    },
                                    child: SvgPicture.string(
                                      AppIcons.searchIcon,
                                      width: 22,
                                      height: 22,
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _AnimatedIconButton(
                                    onTap: () {
                                      // TODO: Implementar menu
                                    },
                                    child: const Icon(Icons.more_vert, color: Color(0xFFFFFFFF), size: 24),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Categories
                            if (_selectedIndex == 0)
                              Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _categories.length,
                                  itemBuilder: (context, index) {
                                    final category = _categories[index];
                                    final isSelected = _selectedCategory == category;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: _AnimatedCategoryChip(
                                        category: category,
                                        isSelected: isSelected,
                                        isDark: isDark,
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory = category;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            
                            // Content
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
                            
                            // Bottom Bar
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
                  ),
                ),
              );
            },
          ),
          
          // Overlay when drawer is open
          if (_isDrawerOpen)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _toggleDrawer,
                  child: Container(
                    color: Color.lerp(
                      const Color(0x00000000),
                      const Color(0x66000000),
                      _fadeAnimation.value,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _AnimatedIconButton({
    required this.onTap,
    required this.child,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(_isPressed ? 8 : 50),
        ),
        child: widget.child,
      ),
    );
  }
}

class _AnimatedCategoryChip extends StatefulWidget {
  final String category;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _AnimatedCategoryChip({
    required this.category,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_AnimatedCategoryChip> createState() => _AnimatedCategoryChipState();
}

class _AnimatedCategoryChipState extends State<_AnimatedCategoryChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isSelected 
              ? (widget.isDark ? const Color(0xFFFFFFFF) : primaryColor)
              : (widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(_isPressed ? 12 : 100),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: (widget.isDark ? const Color(0x20FFFFFF) : primaryColor).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            widget.category,
            style: TextStyle(
              color: widget.isSelected 
                  ? (widget.isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF))
                  : (widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50)),
              fontSize: 14,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}