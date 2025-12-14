import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Future<List<dynamic>>? _futureJogos;

  final List<String> _topTeams = [
    'Real Madrid',
    'Barcelona',
    'Manchester City',
    'Bayern Munich',
    'Liverpool',
    'Juventus',
    'PSG',
    'Chelsea',
    'Manchester United',
    'Arsenal',
  ];

  @override
  void initState() {
    super.initState();
    _loadTopMatches();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadTopMatches() {
    _futureJogos = context.read<AppState>().carregarJogosDestaque(_topTeams);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureJogos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.sports_soccer_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('Nenhum jogo em destaque no momento'),
              ],
            ),
          );
        }

        final jogos = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Jogos em Destaque',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: jogos.length,
                itemBuilder: (context, index) {
                  final jogo = jogos[index];
                  final isActive = index == _currentPage;
                  return AnimatedScale(
                    scale: isActive ? 1.0 : 0.92,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _buildFeaturedCard(jogo, isActive),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  jogos.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Próximos Jogos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: jogos.length,
                itemBuilder: (context, index) {
                  return _buildMatchListItem(jogos[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedCard(dynamic jogo, bool isActive) {
    final appState = context.read<AppState>();
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains('LIVE') || status.contains('HT');

    return GestureDetector(
      onTap: () {
        appState.setJogoDetalhes(jogo['match_id'], '');
        appState.navegarPara('jogo-detalhes');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (isLive) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        formatarStatus(status),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    jogo['league_name'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Image.network(
                        jogo['team_home_badge'] ?? '',
                        width: 48,
                        height: 48,
                        errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        jogo['match_hometeam_name'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${jogo['match_hometeam_score'] ?? '0'} : ${jogo['match_awayteam_score'] ?? '0'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Image.network(
                        jogo['team_away_badge'] ?? '',
                        width: 48,
                        height: 48,
                        errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        jogo['match_awayteam_name'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchListItem(dynamic jogo) {
    final appState = context.read<AppState>();
    final status = jogo['match_status'] ?? '';

    return InkWell(
      onTap: () {
        appState.setJogoDetalhes(jogo['match_id'], '');
        appState.navegarPara('jogo-detalhes');
      },
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 1),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  jogo['match_time'] ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  formatarStatus(status),
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.network(jogo['team_home_badge'] ?? '', width: 24, height: 24, errorBuilder: (_, __, ___) => Container(width: 24, height: 24)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(jogo['match_hometeam_name'] ?? '', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                      Text(jogo['match_hometeam_score'] ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Image.network(jogo['team_away_badge'] ?? '', width: 24, height: 24, errorBuilder: (_, __, ___) => Container(width: 24, height: 24)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(jogo['match_awayteam_name'] ?? '', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                      Text(jogo['match_awayteam_score'] ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
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