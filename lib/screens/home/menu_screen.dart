import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
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
                    Container(
                      width: 28.8,
                      height: 28.8,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          'P',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.4,
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _MenuItem(
                    icon: 'assets/home_icon.svg',
                    title: 'Início',
                    onTap: () => Navigator.pop(context),
                  ),
                  _MenuItem(
                    icon: 'assets/suite_icon.svg',
                    title: 'Suite IA',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: 'assets/stock_icon.svg',
                    title: 'Stock',
                    hasArrow: true,
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: 'assets/community_icon.svg',
                    title: 'Comunidade',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _MenuItem(
                    icon: 'assets/generate_image_icon.svg',
                    title: 'Gerar imagens',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: 'assets/generate_video_icon.svg',
                    title: 'Gerar vídeos',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: 'assets/assistant_icon.svg',
                    title: 'Assistente',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: 'assets/tools_icon.svg',
                    title: 'Todas as ferramentas',
                    hasArrow: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _MenuItem(
                    icon: 'assets/history_icon.svg',
                    title: 'Histórico',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: 'assets/profile_icon.svg',
                    title: 'Perfil',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  _MenuItem(
                    icon: 'assets/settings_icon.svg',
                    title: 'Configurações',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
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