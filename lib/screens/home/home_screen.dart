import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const EditorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Conteúdo principal
          Column(
            children: [
              // AppBar customizada simples
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        // Botão menu (SVG)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MenuScreen(),
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/menu_icon.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onBackground,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Logo (SVG)
                        SvgPicture.asset(
                          'assets/logo.svg',
                          height: 28,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Spacer(),
                        // Botão de pesquisa (SVG)
                        GestureDetector(
                          onTap: () {
                            showSearch(
                              context: context,
                              delegate: CustomSearchDelegate(),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/search_icon.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onBackground,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Avatar (SVG)
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'J',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Corpo da página
              Expanded(child: _pages[_currentIndex]),
            ],
          ),

          // Bottom Navigation Bar FLUTUANTE
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Tab Home
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 0),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/home_icon.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                _currentIndex == 0
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Início',
                              style: TextStyle(
                                fontSize: 11,
                                color: _currentIndex == 0
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                fontWeight: _currentIndex == 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Tab Editor
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 1),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/editor_icon.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                _currentIndex == 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Editor',
                              style: TextStyle(
                                fontSize: 11,
                                color: _currentIndex == 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                fontWeight: _currentIndex == 1
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
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
    );
  }
}

// TELA DE MENU (como no Freepik)
class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header com arrow back
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/arrow_back_icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onBackground,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),

            // Tipo de conta (Personal)
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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          'P',
                          style: TextStyle(
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/arrow_down_icon.svg',
                      width: 20,
                      height: 20,
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

            // Opções do menu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _MenuItem(
                    icon: 'assets/home_icon.svg',
                    title: 'Início',
                    onTap: () {
                      Navigator.pop(context);
                    },
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

// Item do menu
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
              width: 24,
              height: 24,
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
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            if (hasArrow)
              SvgPicture.asset(
                'assets/arrow_right_icon.svg',
                width: 20,
                height: 20,
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

// Página Home
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O que você gostaria de criar hoje?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Cards de ação
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: 'assets/search_icon.svg',
                  title: 'Buscar conteúdo',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionCard(
                  icon: 'assets/spaces_icon.svg',
                  title: 'Spaces',
                  badge: 'NOVO',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Todas as ferramentas
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/tools_icon.svg',
                width: 20,
                height: 20,
              ),
              label: Text('Todas as ferramentas'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Seção de criações recentes
          Row(
            children: [
              Text(
                'Criações recentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Personal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SvgPicture.asset(
                'assets/arrow_down_icon.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Empty state
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/empty_icon.svg',
                    width: 80,
                    height: 80,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.withOpacity(0.3),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma criação encontrada',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Card de ação
class _ActionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String? badge;

  const _ActionCard({
    required this.icon,
    required this.title,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              Theme.of(context).primaryColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Página Editor
class EditorPage extends StatelessWidget {
  const EditorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Editor de Documentos'),
    );
  }
}

// Delegate de Pesquisa
class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Resultados para: $query'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: ['Documentos', 'Contratos', 'Relatórios']
          .map((item) => ListTile(
                title: Text(item),
                onTap: () {
                  query = item;
                  showResults(context);
                },
              ))
          .toList(),
    );
  }
}