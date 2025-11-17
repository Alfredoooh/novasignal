// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'home_page.dart';
import 'bot_page.dart';
import 'conversor_page.dart';
import 'trade_page.dart';
import 'user_profile_page.dart';
import 'settings_page.dart';

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

  void _openSettings() {
    if (Platform.isIOS) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => const SettingsPage(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SettingsPage(),
        ),
      );
    }
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
                              icon: Platform.isIOS
                                  ? const Icon(CupertinoIcons.bell)
                                  : const Icon(Icons.notifications_outlined),
                              color: textColor,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Platform.isIOS
                                  ? const Icon(CupertinoIcons.ellipsis)
                                  : const Icon(Icons.more_vert),
                              color: textColor,
                              onPressed: _openSettings,
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
                      child: CustomIcons.home,
                      activeChild: CustomIcons.homeFilled,
                      activeColor: activeColor,
                      inactiveColor: secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildVerticalTabItem(
                      index: 1,
                      child: Platform.isIOS
                          ? const Icon(CupertinoIcons.chart_bar_alt_fill, size: 28)
                          : const Icon(Icons.bar_chart, size: 28),
                      activeChild: Platform.isIOS
                          ? const Icon(CupertinoIcons.chart_bar_alt_fill, size: 28)
                          : const Icon(Icons.bar_chart, size: 28),
                      activeColor: activeColor,
                      inactiveColor: secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildVerticalTabItem(
                      index: 2,
                      child: Platform.isIOS
                          ? const Icon(CupertinoIcons.arrow_2_circlepath, size: 28)
                          : const Icon(Icons.currency_exchange_outlined, size: 28),
                      activeChild: Platform.isIOS
                          ? const Icon(CupertinoIcons.arrow_2_circlepath, size: 28)
                          : const Icon(Icons.currency_exchange, size: 28),
                      activeColor: activeColor,
                      inactiveColor: secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildVerticalTabItem(
                      index: 3,
                      child: CustomIcons.trade,
                      activeChild: CustomIcons.tradeFilled,
                      activeColor: activeColor,
                      inactiveColor: secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildVerticalTabItem(
                      index: 4,
                      child: Platform.isIOS
                          ? const Icon(CupertinoIcons.person, size: 28)
                          : const Icon(Icons.person_outline, size: 28),
                      activeChild: Platform.isIOS
                          ? const Icon(CupertinoIcons.person_fill, size: 28)
                          : const Icon(Icons.person, size: 28),
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
                        child: CustomIcons.home,
                        activeChild: CustomIcons.homeFilled,
                        label: 'Home',
                        activeColor: activeColor,
                        inactiveColor: secondaryColor,
                      ),
                      _buildTabItem(
                        index: 1,
                        child: Platform.isIOS
                            ? const Icon(CupertinoIcons.chart_bar_alt_fill, size: 24)
                            : const Icon(Icons.bar_chart, size: 24),
                        activeChild: Platform.isIOS
                            ? const Icon(CupertinoIcons.chart_bar_alt_fill, size: 24)
                            : const Icon(Icons.bar_chart, size: 24),
                        label: 'Bot',
                        activeColor: activeColor,
                        inactiveColor: secondaryColor,
                      ),
                      _buildTabItem(
                        index: 2,
                        child: Platform.isIOS
                            ? const Icon(CupertinoIcons.arrow_2_circlepath, size: 24)
                            : const Icon(Icons.currency_exchange_outlined, size: 24),
                        activeChild: Platform.isIOS
                            ? const Icon(CupertinoIcons.arrow_2_circlepath, size: 24)
                            : const Icon(Icons.currency_exchange, size: 24),
                        label: 'Conversor',
                        activeColor: activeColor,
                        inactiveColor: secondaryColor,
                      ),
                      _buildTabItem(
                        index: 3,
                        child: CustomIcons.trade,
                        activeChild: CustomIcons.tradeFilled,
                        label: 'Trade',
                        activeColor: activeColor,
                        inactiveColor: secondaryColor,
                      ),
                      _buildTabItem(
                        index: 4,
                        child: Platform.isIOS
                            ? const Icon(CupertinoIcons.person, size: 24)
                            : const Icon(Icons.person_outline, size: 24),
                        activeChild: Platform.isIOS
                            ? const Icon(CupertinoIcons.person_fill, size: 24)
                            : const Icon(Icons.person, size: 24),
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
    required Widget child,
    required Widget activeChild,
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
            IconTheme(
              data: IconThemeData(
                color: active ? activeColor : inactiveColor,
                size: 24,
              ),
              child: active ? activeChild : child,
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
    required Widget child,
    required Widget activeChild,
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
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: active ? activeColor : inactiveColor,
              size: 28,
            ),
            child: active ? activeChild : child,
          ),
        ),
      ),
    );
  }
}

// Ícones customizados
class CustomIcons {
  static const Widget home = Icon(
    Icons.home_outlined,
    size: 24,
  );

  static const Widget homeFilled = Icon(
    Icons.home,
    size: 24,
  );

  static final Widget trade = CustomPaint(
    size: const Size(24, 24),
    painter: TradePainter(filled: false),
  );

  static final Widget tradeFilled = CustomPaint(
    size: const Size(24, 24),
    painter: TradePainter(filled: true),
  );
}

// Painter para o ícone de Trade customizado
class TradePainter extends CustomPainter {
  final bool filled;

  TradePainter({required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Desenha uma linha de tendência ascendente com pontos
    path.moveTo(size.width * 0.15, size.height * 0.75);
    path.lineTo(size.width * 0.35, size.height * 0.55);
    path.lineTo(size.width * 0.55, size.height * 0.65);
    path.lineTo(size.width * 0.85, size.height * 0.25);

    canvas.drawPath(path, paint);

    // Desenha pontos nos vértices
    final pointPaint = Paint()..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.75),
      3,
      pointPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.55),
      3,
      pointPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.65),
      3,
      pointPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.25),
      3,
      pointPaint,
    );

    // Desenha seta no final
    final arrowPath = Path();
    arrowPath.moveTo(size.width * 0.85, size.height * 0.25);
    arrowPath.lineTo(size.width * 0.75, size.height * 0.25);
    arrowPath.lineTo(size.width * 0.85, size.height * 0.25);
    arrowPath.lineTo(size.width * 0.85, size.height * 0.35);

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}