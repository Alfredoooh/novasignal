// lib/screens/menu/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<Offset> _itemAnimation(int index) {
    final start = 0.0 + (index * 0.08);
    final end = start + 0.5;
    return Tween<Offset>(
      begin: const Offset(-0.15, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/arrow_back_icon.svg',
                      width: 21.6,
                      height: 21.6,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onBackground,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: 25.2,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),

            // Top card with circular gradient "P"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Circular gradient avatar with 'P'
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.2, -0.2),
                          radius: 0.9,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'P',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Text(
                      'Personal',
                      style: TextStyle(
                        fontSize: 14.4,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/arrow_down_icon.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Menu (só os 3 itens) com animação de deslize suave
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  SlideTransition(
                    position: _itemAnimation(0),
                    child: _MenuItem(
                      icon: 'assets/home_icon.svg',
                      title: 'Início',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SlideTransition(
                    position: _itemAnimation(1),
                    child: _MenuItem(
                      icon: 'assets/profile_icon.svg',
                      title: 'Perfil',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  SlideTransition(
                    position: _itemAnimation(2),
                    child: _MenuItem(
                      icon: 'assets/settings_icon.svg',
                      title: 'Configurações',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final bool hasArrow;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.hasArrow = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 21.6,
              height: 21.6,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onBackground,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.4,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            if (hasArrow)
              SvgPicture.asset(
                'assets/arrow_right_icon.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
          ],
        ),
      ),
    );
  }
}