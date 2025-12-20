import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'jogo_detalhes_page.dart';

class LigaDetalhesPage extends StatefulWidget {
  final String ligaId;
  final Map<String, dynamic> ligaData;

  const LigaDetalhesPage({
    super.key,
    required this.ligaId,
    required this.ligaData,
  });

  @override
  State<LigaDetalhesPage> createState() => _LigaDetalhesPageState();
}

class _LigaDetalhesPageState extends State<LigaDetalhesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<List<dynamic>>? _futureJogos;
  Future<List<dynamic>>? _futureClassificacao;
  List<dynamic>? _cachedJogos;
  List<dynamic>? _cachedClassificacao;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLigaData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLigaData() {
    final appState = context.read<AppState>();
    setState(() {
      _futureJogos = appState.carregarJogosPorLiga(widget.ligaId);
      _futureClassificacao = appState.carregarClassificacao(widget.ligaId);
    });

    _futureJogos?.then((jogos) {
      if (mounted) {
        setState(() {
          _cachedJogos = jogos;
        });
      }
    });

    _futureClassificacao?.then((classificacao) {
      if (mounted) {
        setState(() {
          _cachedClassificacao = classificacao;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              stretch: true,
              leading: IconButton(
                icon: const Icon(Symbols.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.ligaData['league_name'] ?? 'Liga',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                  ),
                  child: Center(
                    child: widget.ligaData['league_logo'] != null && widget.ligaData['league_logo'].toString().isNotEmpty
                        ? Image.network(
                            widget.ligaData['league_logo'],
                            width: 80,
                            height: 80,
                            errorBuilder: (_, __, ___) => Icon(
                              Symbols.emoji_events_rounded,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          )
                        : Icon(
                            Symbols.emoji_events_rounded,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Classificação'),
                    Tab(text: 'Jogos'),
                    Tab(text: 'Estatísticas'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildClassificacaoTab(),
            _buildJogosTab(),
            _buildEstatisticasTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildClassificacaoTab() {
    if (_cachedClassificacao != null) {
      return _buildClassificacaoContent(_cachedClassificacao!);
    }

    return FutureBuilder<List<dynamic>>(
      future: _futureClassificacao,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.table_chart_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                const Text('Classificação não disponível'),
              ],
            ),
          );
        }
        return _buildClassificacaoContent(snapshot.data!);
      },
    );
  }

  Widget _buildClassificacaoContent(List<dynamic> classificacao) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classificacao.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40, child: Text('Pos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                const Expanded(child: Text('Clube', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                const SizedBox(width: 35, child: Text('J', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                const SizedBox(width: 45, child: Text('Pts', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              ],
            ),
          );
        }

        final time = classificacao[index - 1];
        final posicao = int.tryParse(time['overall_league_position']?.toString() ?? '0') ?? index;
        Color? posicaoColor;

        if (posicao <= 4) {
          posicaoColor = Colors.green.withOpacity(0.15);
        } else if (posicao <= 6) {
          posicaoColor = Colors.orange.withOpacity(0.15);
        } else if (posicao >= classificacao.length - 2) {
          posicaoColor = Colors.red.withOpacity(0.15);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: posicaoColor ?? Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 0.5,
              ),
              left: posicaoColor != null
                  ? BorderSide(
                      color: posicao <= 4
                          ? Colors.green
                          : posicao <= 6
                              ? Colors.orange
                              : Colors.red,
                      width: 3,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '$posicao',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    if (time['team_badge'] != null) ...[
                      Image.network(
                        time['team_badge'],
                        width: 24,
                        height: 24,
                        errorBuilder: (_, __, ___) => const SizedBox(width: 24, height: 24),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        time['team_name'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(
                  time['overall_league_payed']?.toString() ?? '0',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(
                width: 45,
                child: Text(
                  time['overall_league_PTS']?.toString() ?? '0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJogosTab() {
    if (_cachedJogos != null) {
      return _buildJogosContent(_cachedJogos!);
    }

    return FutureBuilder<List<dynamic>>(
      future: _futureJogos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
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
                const Text('Nenhum jogo disponível'),
              ],
            ),
          );
        }
        return _buildJogosContent(snapshot.data!);
      },
    );
  }

  Widget _buildJogosContent(List<dynamic> jogos) {
    final jogosSorted = List<dynamic>.from(jogos)
      ..sort((a, b) {
        final dateA = a['match_date'] ?? '';
        final dateB = b['match_date'] ?? '';
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jogosSorted.length,
      itemBuilder: (context, index) {
        final jogo = jogosSorted[index];
        final status = jogo['match_status'] ?? '';
        final isLive = status.contains("'") || status == 'LIVE';
        final isFinished = status.contains('Finished') || status == 'FT';

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLive 
                    ? Colors.red 
                    : Theme.of(context).dividerColor.withOpacity(0.2),
                width: isLive ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${jogo['match_date']} • ${jogo['match_time']}',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLive
                            ? Colors.red.withOpacity(0.2)
                            : isFinished
                                ? Theme.of(context).colorScheme.surfaceContainerHighest
                                : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formatarStatus(status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isLive ? Colors.red : isFinished ? Theme.of(context).colorScheme.onSurfaceVariant : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.network(
                            jogo['team_home_badge'] ?? '',
                            width: 32,
                            height: 32,
                            errorBuilder: (_, __, ___) => const SizedBox(width: 32, height: 32),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              jogo['match_hometeam_name'] ?? '',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${jogo['match_hometeam_score'] ?? '-'} : ${jogo['match_awayteam_score'] ?? '-'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              jogo['match_awayteam_name'] ?? '',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.network(
                            jogo['team_away_badge'] ?? '',
                            width: 32,
                            height: 32,
                            errorBuilder: (_, __, ___) => const SizedBox(width: 32, height: 32),
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
      },
    );
  }

  Widget _buildEstatisticasTab() {
    if (_cachedJogos == null) {
      return FutureBuilder<List<dynamic>>(
        future: _futureJogos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Sem dados disponíveis'));
          }
          return _buildEstatisticasContent(snapshot.data!);
        },
      );
    }
    return _buildEstatisticasContent(_cachedJogos!);
  }

  Widget _buildEstatisticasContent(List<dynamic> jogos) {
    final stats = _calcularEstatisticas(jogos);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          icon: Symbols.sports_soccer_rounded,
          title: 'Total de Jogos',
          value: '${stats['totalJogos']}',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Symbols.sports_score_rounded,
          title: 'Total de Gols',
          value: '${stats['totalGols']}',
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Symbols.calculate_rounded,
          title: 'Média de Gols/Jogo',
          value: stats['mediaGols'].toStringAsFixed(2),
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calcularEstatisticas(List<dynamic> jogos) {
    int totalJogos = 0;
    int totalGols = 0;

    for (var jogo in jogos) {
      final status = jogo['match_status'] ?? '';
      if (!status.contains('Finished') && status != 'FT') continue;

      totalJogos++;
      final homeScore = int.tryParse(jogo['match_hometeam_score']?.toString() ?? '0') ?? 0;
      final awayScore = int.tryParse(jogo['match_awayteam_score']?.toString() ?? '0') ?? 0;
      totalGols += homeScore + awayScore;
    }

    return {
      'totalJogos': totalJogos,
      'totalGols': totalGols,
      'mediaGols': totalJogos > 0 ? totalGols / totalJogos : 0.0,
    };
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}