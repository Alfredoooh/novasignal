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

class _JogoDetalhesPageState extends State<JogoDetalhesPage> with SingleTickerProviderStateMixin {
  Future<dynamic>? _futureJogo;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _futureJogo = context.read<AppState>().carregarJogoDetalhes(widget.jogoId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureJogo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.error_rounded, size: 64, color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('Erro ao carregar detalhes'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final jogo = snapshot.data!;
          return _buildJogoDetalhes(jogo, context);
        } else {
          return const Center(child: Text('Jogo não encontrado'));
        }
      },
    );
  }

  Widget _buildJogoDetalhes(dynamic jogo, BuildContext context) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';
    
    Color badgeColor;
    if (status.contains('Finished') || status == 'FT' || status == 'AET') {
      badgeColor = Theme.of(context).colorScheme.tertiary;
    } else if (isLive) {
      badgeColor = Theme.of(context).colorScheme.error;
    } else {
      badgeColor = Theme.of(context).colorScheme.secondary;
    }

    return Column(
      children: [
        // Header com placar
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Liga e Data
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.emoji_events_rounded, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${jogo['league_name'] ?? 'Liga'} • ${jogo['match_date'] ?? ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Times e Placar
              Row(
                children: [
                  // Time Casa
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          jogo['team_home_badge'] ?? 'https://via.placeholder.com/60',
                          width: 60,
                          height: 60,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jogo['match_hometeam_name'] ?? 'Home',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Placar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          '${jogo['match_hometeam_score'] ?? '0'} : ${jogo['match_awayteam_score'] ?? '0'}',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLive) ...[
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                formatarStatus(status),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: badgeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Time Fora
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          jogo['team_away_badge'] ?? 'https://via.placeholder.com/60',
                          width: 60,
                          height: 60,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jogo['match_awayteam_name'] ?? 'Away',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (jogo['match_stadium'] != null && jogo['match_stadium'].isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Symbols.stadium_rounded, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        jogo['match_stadium'],
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Tabs
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Resumo'),
              Tab(text: 'Estatísticas'),
              Tab(text: 'Escalações'),
            ],
          ),
        ),
        Container(height: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.3)),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildResumoTab(jogo),
              _buildEstatisticasTab(jogo),
              _buildEscalacoesTab(jogo),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResumoTab(dynamic jogo) {
    final hasGoals = jogo['goalscorer'] != null && jogo['goalscorer'].isNotEmpty;
    final hasCards = jogo['cards'] != null && jogo['cards'].isNotEmpty;
    final hasSubs = jogo['substitutions'] != null && 
                    (jogo['substitutions']['home']?.isNotEmpty == true || 
                     jogo['substitutions']['away']?.isNotEmpty == true);
    
    if (!hasGoals && !hasCards && !hasSubs) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.sports_soccer_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('Nenhum evento registrado', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (hasGoals) ...[
          _buildSectionTitle('Gols'),
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: jogo['goalscorer'].map<Widget>((gol) => _buildGoalItem(gol, jogo)).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (hasCards) ...[
          _buildSectionTitle('Cartões'),
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: jogo['cards'].map<Widget>((card) => _buildCardItem(card, jogo)).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEstatisticasTab(dynamic jogo) {
    if (jogo['statistics'] == null || jogo['statistics'].isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.bar_chart_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('Estatísticas não disponíveis', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: jogo['statistics'].length,
      itemBuilder: (context, index) {
        final stat = jogo['statistics'][index];
        return _buildStatItem(stat);
      },
    );
  }

  Widget _buildEscalacoesTab(dynamic jogo) {
    final hasLineups = jogo['lineups'] != null && 
                       (jogo['lineups']['home']?['starting_lineups'] != null ||
                        jogo['lineups']['away']?['starting_lineups'] != null);
    
    if (!hasLineups) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.people_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('Escalações não disponíveis', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (jogo['lineups']['home']?['starting_lineups'] != null) ...[
          _buildSectionTitle(jogo['match_hometeam_name'] ?? 'Casa'),
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: jogo['lineups']['home']['starting_lineups']
                  .map<Widget>((player) => _buildPlayerItem(player))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (jogo['lineups']['away']?['starting_lineups'] != null) ...[
          _buildSectionTitle(jogo['match_awayteam_name'] ?? 'Fora'),
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: jogo['lineups']['away']['starting_lineups']
                  .map<Widget>((player) => _buildPlayerItem(player))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(dynamic gol, dynamic jogo) {
    final isHome = gol['home_scorer'] != null;
    final scorer = isHome ? gol['home_scorer'] : gol['away_scorer'];
    final time = gol['time'] ?? '';
    final assist = gol['home_assist'] ?? gol['away_assist'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Symbols.sports_soccer_rounded, color: Theme.of(context).colorScheme.tertiary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scorer ?? 'N/A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                if (assist != null && assist.isNotEmpty)
                  Text('Assistência: $assist', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text('$time\'', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildCardItem(dynamic card, dynamic jogo) {
    final isYellow = card['card'] == 'yellow card';
    final player = card['home_fault'] ?? card['away_fault'] ?? 'N/A';
    final time = card['time'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 16,
            decoration: BoxDecoration(
              color: isYellow ? const Color(0xFFFFD700) : const Color(0xFFDC143C),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(player, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Text('$time\'', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildStatItem(dynamic stat) {
    final home = double.tryParse(stat['home'] ?? '0') ?? 0;
    final away = double.tryParse(stat['away'] ?? '0') ?? 0;
    final total = home + away > 0 ? home + away : 1;
    final homePercent = (home / total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${home.toInt()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text(stat['type'] ?? '', style: Theme.of(context).textTheme.bodySmall),
              Text('${away.toInt()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  flex: (homePercent * 100).toInt(),
                  child: Container(height: 6, color: Theme.of(context).colorScheme.primary),
                ),
                Expanded(
                  flex: ((1 - homePercent) * 100).toInt(),
                  child: Container(height: 6, color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerItem(dynamic player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player['lineup_number'] ?? '?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player['player'] ?? 'Unknown', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(player['lineup_position'] ?? '', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}