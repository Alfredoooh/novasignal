import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';

// ==================== LIGAS PAGE ====================
class LigasPage extends StatefulWidget {
  const LigasPage({super.key});

  @override
  State<LigasPage> createState() => _LigasPageState();
}

class _LigasPageState extends State<LigasPage> {
  Future<List<dynamic>>? _futureLigas;

  @override
  void initState() {
    super.initState();
    _futureLigas = context.read<AppState>().carregarLigas();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureLigas,
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
                const Text('Erro ao carregar ligas'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final ligas = snapshot.data!;
          Map<String, List<dynamic>> ligasPorPais = {};
          for (var liga in ligas) {
            String pais = liga['country_name'] ?? 'Outros';
            ligasPorPais.putIfAbsent(pais, () => []);
            ligasPorPais[pais]!.add(liga);
          }
          final sortedPaises = ligasPorPais.keys.toList()..sort();
          
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: sortedPaises.length,
            itemBuilder: (context, index) {
              final pais = sortedPaises[index];
              final ligasDoPais = ligasPorPais[pais]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(Symbols.location_on_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(pais, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: ligasDoPais.map((liga) => _buildLeagueItem(liga, context)).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          return const Center(child: Text('Sem ligas'));
        }
      },
    );
  }

  Widget _buildLeagueItem(dynamic liga, BuildContext context) {
    final appState = context.read<AppState>();
    return InkWell(
      onTap: () {
        appState.setLigaDetalhes(liga['league_id'], liga['league_name']);
        appState.navegarPara('liga-detalhes');
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    liga['league_logo'] ?? 'https://via.placeholder.com/36',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 36,
                      height: 36,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(Symbols.emoji_events_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    liga['league_name'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Symbols.chevron_right_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ],
            ),
          ),
          Container(height: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.2)),
        ],
      ),
    );
  }
}

// ==================== LIGA DETALHES PAGE ====================
class LigaDetalhesPage extends StatefulWidget {
  final String ligaId;

  const LigaDetalhesPage({super.key, required this.ligaId});

  @override
  State<LigaDetalhesPage> createState() => _LigaDetalhesPageState();
}

class _LigaDetalhesPageState extends State<LigaDetalhesPage> with SingleTickerProviderStateMixin {
  Future<List<dynamic>>? _futureClassificacao;
  Future<List<dynamic>>? _futureJogos;
  dynamic _liga;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final appState = context.read<AppState>();
    _liga = appState.todasLigas.firstWhere((l) => l['league_id'] == widget.ligaId, orElse: () => null);
    _futureClassificacao = appState.carregarClassificacao(widget.ligaId);
    _futureJogos = appState.carregarUltimosJogosLiga(widget.ligaId);
  }

  @override
  Widget build(BuildContext context) {
    if (_liga == null) {
      return const Center(child: Text('Liga não encontrada'));
    }

    return Column(
      children: [
        // Header
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _liga['league_logo'] ?? 'https://via.placeholder.com/56',
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(Symbols.emoji_events_rounded, size: 32, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_liga['league_name'] ?? 'Unknown', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(_liga['country_name'] ?? 'Unknown', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
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
              Tab(text: 'Classificação'),
              Tab(text: 'Últimos Jogos'),
            ],
          ),
        ),
        Container(height: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.3)),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildClassificacaoTab(),
              _buildJogosTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassificacaoTab() {
    return FutureBuilder<List<dynamic>>(
      future: _futureClassificacao,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.leaderboard_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('Classificação não disponível', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        }

        final classificacao = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: classificacao.length,
          itemBuilder: (context, index) {
            final equipa = classificacao[index];
            Color? indicatorColor;
            if (index < 4) indicatorColor = const Color(0xFF4CAF50);
            else if (index < 6) indicatorColor = const Color(0xFF2196F3);
            else if (index >= classificacao.length - 3) indicatorColor = const Color(0xFFF44336);

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  left: indicatorColor != null ? BorderSide(color: indicatorColor, width: 4) : BorderSide.none,
                  bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2), width: 0.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      equipa['overall_league_position'] ?? '?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Image.network(
                    equipa['team_badge'] ?? 'https://via.placeholder.com/28',
                    width: 28,
                    height: 28,
                    errorBuilder: (_, __, ___) => Container(width: 28, height: 28, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      equipa['team_name'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 36, child: Text('${equipa['overall_league_payed'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                  SizedBox(width: 36, child: Text('${equipa['overall_league_PTS'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJogosTab() {
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
                Text('Nenhum jogo recente', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        }

        final jogos = snapshot.data!.take(15).toList();
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: jogos.length,
          itemBuilder: (context, index) {
            final jogo = jogos[index];
            return _buildMatchItem(jogo);
          },
        );
      },
    );
  }

  Widget _buildMatchItem(dynamic jogo) {
    final appState = context.read<AppState>();
    final status = jogo['match_status'] ?? '';
    Color badgeColor;
    if (status.contains('Finished') || status == 'FT') {
      badgeColor = Theme.of(context).colorScheme.tertiary;
    } else if (status.contains("'") || status == 'HT' || status == 'LIVE') {
      badgeColor = Theme.of(context).colorScheme.error;
    } else {
      badgeColor = Theme.of(context).colorScheme.secondary;
    }

    return InkWell(
      onTap: () {
        appState.setJogoDetalhes(jogo['match_id'], '');
        appState.navegarPara('jogo-detalhes');
      },
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2), width: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${jogo['match_date']} • ${jogo['match_time']}', style: Theme.of(context).textTheme.bodySmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(formatarStatus(status), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.network(jogo['team_home_badge'] ?? 'https://via.placeholder.com/32', width: 32, height: 32, errorBuilder: (_, __, ___) => Container(width: 32, height: 32, color: Colors.grey[300])),
                      const SizedBox(width: 10),
                      Expanded(child: Text(jogo['match_hometeam_name'] ?? 'Home', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('${jogo['match_hometeam_score'] ?? '-'} : ${jogo['match_awayteam_score'] ?? '-'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(child: Text(jogo['match_awayteam_name'] ?? 'Away', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
                      const SizedBox(width: 10),
                      Image.network(jogo['team_away_badge'] ?? 'https://via.placeholder.com/32', width: 32, height: 32, errorBuilder: (_, __, ___) => Container(width: 32, height: 32, color: Colors.grey[300])),
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
}
