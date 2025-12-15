import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'jogo_detalhes_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  List<dynamic> _jogos = [];
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        int next = _pageController.page!.round();
        if (_currentPage != next) {
          setState(() {
            _currentPage = next;
          });
        }
      }
    });
    _loadTopMatches();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTopMatches() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appState = context.read<AppState>();
      final jogos = await appState.carregarJogosDestaque(appState.topClubs);
      
      if (!mounted) return;
      
      setState(() {
        _jogos = jogos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, List<dynamic>> _categorizeMatches(List<dynamic> jogos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final liveAndToday = <dynamic>[];
    final upcoming = <dynamic>[];

    for (var jogo in jogos) {
      try {
        final matchDateStr = jogo['match_date'] ?? '';
        if (matchDateStr.isEmpty) {
          upcoming.add(jogo);
          continue;
        }

        final parts = matchDateStr.split('-');
        if (parts.length != 3) {
          upcoming.add(jogo);
          continue;
        }

        final matchDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        final status = jogo['match_status'] ?? '';
        final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

        if (isLive || matchDate.isAtSameMomentAs(today)) {
          liveAndToday.add(jogo);
        } else if (matchDate.isAfter(today)) {
          upcoming.add(jogo);
        }
      } catch (e) {
        upcoming.add(jogo);
      }
    }

    return {
      'liveAndToday': liveAndToday,
      'upcoming': upcoming,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Carregando jogos...',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.error_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Erro ao carregar jogos'),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadTopMatches,
              icon: const Icon(Symbols.refresh_rounded),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_jogos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.sports_soccer_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text('Nenhum jogo em destaque no momento'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadTopMatches,
              icon: const Icon(Symbols.refresh_rounded),
              label: const Text('Recarregar'),
            ),
          ],
        ),
      );
    }

    final categorized = _categorizeMatches(_jogos);
    final featured = categorized['liveAndToday']!.isNotEmpty 
        ? categorized['liveAndToday']! 
        : (_jogos.length > 5 ? _jogos.take(5).toList() : _jogos);
    final upcoming = categorized['upcoming']!.isNotEmpty 
        ? categorized['upcoming']! 
        : _jogos;

    return RefreshIndicator(
      onRefresh: _loadTopMatches,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Jogos em Destaque',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            if (featured.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: featured.length,
                  itemBuilder: (context, index) {
                    return _buildFeaturedCard(featured[index]);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    featured.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (upcoming.isNotEmpty) ...[
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Próximos Jogos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMatchesList(upcoming),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (isLive) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        formatarStatus(status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    jogo['league_name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
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
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shield,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        jogo['match_hometeam_name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${jogo['match_hometeam_score'] ?? '0'} : ${jogo['match_awayteam_score'] ?? '0'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
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
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shield,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        jogo['match_awayteam_name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildMatchesList(List<dynamic> jogos) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: jogos.take(8).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final jogo = entry.value;
          final isLast = index == jogos.take(8).length - 1;
          return _buildMatchListItem(jogo, isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildMatchListItem(dynamic jogo, bool isLast) {
    final status = jogo['match_status'] ?? '';

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
          ),
        );
      },
      borderRadius: BorderRadius.vertical(
        top: Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jogo['match_time'] ?? '',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  formatarStatus(status),
                  style: TextStyle(
                    fontSize: 10,
                    color: getStatusColor(status, context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.network(
                        jogo['team_home_badge'] ?? '',
                        width: 24,
                        height: 24,
                        errorBuilder: (_, __, ___) => Container(width: 24, height: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          jogo['match_hometeam_name'] ?? '',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        jogo['match_hometeam_score'] ?? '-',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Image.network(
                        jogo['team_away_badge'] ?? '',
                        width: 24,
                        height: 24,
                        errorBuilder: (_, __, ___) => Container(width: 24, height: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          jogo['match_awayteam_name'] ?? '',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        jogo['match_awayteam_score'] ?? '-',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
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