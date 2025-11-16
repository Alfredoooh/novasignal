// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'bot_page.dart';
import 'conversor_page.dart';
import 'trade_page.dart';
import 'user_profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget?> _pages = [null, null, null, null, null];

  final List<String> _tabTitles = [
    'Home',
    'Bot',
    'Conversor',
    'Trade',
    'Perfil',
  ];

  Widget _getPage(int index) {
    if (_pages[index] != null) return _pages[index]!;
    switch (index) {
      case 0:
        _pages[0] = const HomePage();
        break;
      case 1:
        _pages[1] = const BotPage();
        break;
      case 2:
        _pages[2] = const ConversorPage();
        break;
      case 3:
        _pages[3] = const TradePage();
        break;
      case 4:
        _pages[4] = const UserProfilePage();
        break;
      default:
        _pages[index] = const SizedBox.shrink();
    }
    return _pages[index]!;
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0A0A0A);
    const cardColor = Color(0xFF1C1C1E);
    const textColor = Color(0xFFFFFFFF);
    const secondaryColor = Color(0xFF8E8E93);
    const activeColor = Color(0xFF1877F2);
    const bottomNavColor = Color(0xFF1C1C1E);
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                // AppBar
                Container(
                  color: cardColor,
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 56,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              _tabTitles[_currentIndex],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              color: textColor,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined),
                              color: textColor,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: List.generate(5, (i) => _getPage(i)),
                  ),
                ),
              ],
            ),
          ),

          // Sidebar para telas largas
          if (isWideScreen)
            Container(
              width: 80,
              color: bottomNavColor,
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildVerticalTabItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      activeColor: activeColor,
                      inactiveColor: secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildVerticalTabItem(
                      index: 1,
                      icon: Icons.smart_toy_outlined,
                      activeIcon: Icons.smart_toy,
                      activeColor: activeColor,
                      inactiveColor: secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildVerticalTabItem(
                      index: 2,
                      icon: Icons.currency_exchange_outlined,
                      activeIcon: Icons.currency_exchange,
                      activeColor: activeColor,
                      inactiveColor: secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildVerticalTabItem(
                      index: 3,
                      icon: Icons.trending_up_outlined,
                      activeIcon: Icons.trending_up,
                      activeColor: activeColor,
                      inactiveColor: secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildVerticalTabItem(
                      index: 4,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      activeColor: activeColor,
                      inactiveColor: secondaryColor,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // Bottom Navigation Bar para mobile
      bottomNavigationBar: !isWideScreen
          ? Container(
              decoration: const BoxDecoration(
                color: bottomNavColor,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF2C2C2E),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabItem(
                        index: 0,
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Home',
                        activeColor: activeColor,
                        inactiveColor: secondaryColor,
                      ),
                      _buildTabItem(
                        index: 1,
                        icon: Icons.smart_toy_outlined,
                        activeIcon: Icons.smart_toy,
                        label: 'Bot',
                        activeColor: activeColor,
                        inactiveColor: secondaryColor,
                      ),
                      _buildTabItem(
                        index: 2,
                        icon: Icons.currency_exchange_outlined,
                        activeIcon: Icons.currency_exchange,
                        label: 'Conversor',
                        activeColor: activeColor,
                        inactiveColor: secondaryColor,
                      ),
                      _buildTabItem(
                        index: 3,
                        icon: Icons.trending_up_outlined,
                        activeIcon: Icons.trending_up,
                        label: 'Trade',
                        activeColor: activeColor,
                        inactiveColor: secondaryColor,
                      ),
                      _buildTabItem(
                        index: 4,
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Perfil',
                        activeColor: activeColor,
                        inactiveColor: secondaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final bool active = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              size: 24,
              color: active ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final bool active = _currentIndex == index;

    return InkWell(
      onTap: () => _onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          active ? activeIcon : icon,
          size: 28,
          color: active ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}