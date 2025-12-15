import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';

class JogoDetalhesPage extends StatefulWidget {
  final String jogoId;

  const JogoDetalhesPage({super.key, required this.jogoId});

  @override
  State<JogoDetalhesPage> createState() => _JogoDetalhesPageState();
}

class _JogoDetalhesPageState extends State<JogoDetalhesPage> {
  Future<dynamic>? _futureJogo;

  @override
  void initState() {
    super.initState();
    _futureJogo = context.read<AppState>().carregarJogoDetalhes(widget.jogoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<dynamic>(
        future: _futureJogo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.error_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text('Erro ao carregar detalhes'),
                ],
              ),
            );
          }

          final jogo = snapshot.data!;
          return _buildDetalhes(jogo);
        },
      ),
    );
  }

  Widget _buildDetalhes(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back_rounded),
            onPressed: () => context.read<AppState>().voltarPagina(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        jogo['league_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Image.network(
                                  jogo['team_home_badge'] ?? '',
                                  width: 56,
                                  height: 56,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 56, color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  jogo['match_hometeam_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${jogo['match_hometeam_score'] ?? '0'} : ${jogo['match_awayteam_score'] ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isLive 
                                      ? getStatusColor(status, context).withOpacity(0.3)
                                      : Colors.white.withOpacity(0.2),
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
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Image.network(
                                  jogo['team_away_badge'] ?? '',
                                  width: 56,
                                  height: 56,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 56, color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  jogo['match_awayteam_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${jogo['match_date']} • ${jogo['match_time']}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (jogo['goalscorer'] != null && jogo['goalscorer'].isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Gols',
                  icon: Symbols.sports_soccer_rounded,
                  child: Column(
                    children: (jogo['goalscorer'] as List).map<Widget>((gol) {
                      final scorer = gol['home_scorer'] ?? gol['away_scorer'] ?? 'N/A';
                      final time = gol['time'] ?? '';
                      final isHome = gol['home_scorer'] != null;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Symbols.sports_soccer_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scorer,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    isHome ? jogo['match_hometeam_name'] : jogo['match_awayteam_name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$time\'',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              if (jogo['cards'] != null && jogo['cards'].isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Cartões',
                  icon: Symbols.style_rounded,
                  child: Column(
                    children: (jogo['cards'] as List).map<Widget>((card) {
                      final isYellow = card['card'] == 'yellow card';
                      final player = card['home_fault'] ?? card['away_fault'] ?? 'N/A';
                      final time = card['time'] ?? '';
                      final isHome = card['home_fault'] != null;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isYellow ? const Color(0xFFFFD700) : const Color(0xFFDC143C),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    isHome ? jogo['match_hometeam_name'] : jogo['match_awayteam_name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$time\'',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              if (jogo['statistics'] != null && jogo['statistics'].isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Estatísticas',
                  icon: Symbols.bar_chart_rounded,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: (jogo['statistics'] as List).map<Widget>((stat) {
                        final home = double.tryParse(stat['home'] ?? '0') ?? 0;
                        final away = double.tryParse(stat['away'] ?? '0') ?? 0;
                        final total = home + away > 0 ? home + away : 1;
                        final homePercent = home / total;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${home.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    stat['type'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '${away.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: (homePercent * 100).toInt(),
                                      child: Container(
                                        height: 6,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    Expanded(
                                      flex: ((1 - homePercent) * 100).toInt(),
                                      child: Container(
                                        height: 6,
                                        color: Theme.of(context).colorScheme.tertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}