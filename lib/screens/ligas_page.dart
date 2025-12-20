import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'jogo_detalhes_page.dart';

class LigaDetalhesPage extends StatefulWidget {
  final String ligaId;
  final String ligaNome;
  final String? ligaLogo;

  const LigaDetalhesPage({
    super.key,
    required this.ligaId,
    required this.ligaNome,
    this.ligaLogo,
  });

  @override
  State<LigaDetalhesPage> createState() => _LigaDetalhesPageState();
}

class _LigaDetalhesPageState extends State<LigaDetalhesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<List<dynamic>>? _futureJogos;
  List<dynamic>? _cachedJogos;

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
    });

    _futureJogos?.then((jogos) {
      if (mounted) {
        setState(() {
          _cachedJogos = jogos;
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
                  widget.ligaNome,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
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
                    child: widget.ligaLogo != null && widget.ligaLogo!.isNotEmpty
                        ? Image.network(
                            widget.ligaLogo!,
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
                    Tab(text: 'Tabela'),
                    Tab(text: 'Jogos'),
                    Tab(text: 'Estatísticas'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _cachedJogos != null
            ? TabBarView(
                controller: _tabController,
                children: [
                  _buildTabelaTab(_cachedJogos!),
                  _buildJogosTab(_cachedJogos!),
                  _buildEstatisticasTab(_cachedJogos!),
                ],
              )
            : FutureBuilder<List<dynamic>>(
                future: _futureJogos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
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
                          const Text('Erro ao carregar dados da liga'),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _loadLigaData,
                            icon: const Icon(Symbols.refresh_rounded),
                            label: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum dado disponível'));
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabelaTab(snapshot.data!),
                      _buildJogosTab(snapshot.data!),
                      _buildEstatisticasTab(snapshot.data!),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTabelaTab(List<dynamic> jogos) {
    final tabela = _calcularTabela(jogos);

    if (tabela.isEmpty) {
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
            const Text('Tabela não disponível'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tabela.length + 1,
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
                SizedBox(
                  width: 40,
                  child: Text(
                    'Pos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Clube',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'J',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'V',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'E',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'D',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 45,
                  child: Text(
                    'Pts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final time = tabela[index - 1];
        final posicao = index;
        Color? posicaoColor;

        if (posicao <= 4) {
          posicaoColor = Colors.green.withOpacity(0.15);
        } else if (posicao <= 6) {
          posicaoColor = Colors.orange.withOpacity(0.15);
        } else if (posicao >= tabela.length - 2) {
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    if (time['logo'] != null) ...[
                      Image.network(
                        time['logo'],
                        width: 24,
                        height: 24,
                        errorBuilder: (_, __, ___) => const SizedBox(width: 24, height: 24),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        time['nome'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(
                  '${time['jogos']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(
                  '${time['vitorias']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.green),
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(
                  '${time['empates']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.orange),
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(
                  '${time['derrotas']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.red),
                ),
              ),
              SizedBox(
                width: 45,
                child: Text(
                  '${time['pontos']}',
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

  Widget _buildJogosTab(List<dynamic> jogos) {
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
        return _buildMatchCard(jogo);
      },
    );
  }

  Widget _buildMatchCard(dynamic jogo) {
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
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${jogo['match_date']} • ${jogo['match_time']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLive
                        ? Colors.green.withOpacity(0.2)
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
                      color: isLive
                          ? Colors.green
                          : isFinished
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Colors.blue,
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
  }

  Widget _buildEstatisticasTab(List<dynamic> jogos) {
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
          title: 'Média de Gols por Jogo',
          value: stats['mediaGols'].toStringAsFixed(2),
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Symbols.home_rounded,
          title: 'Vitórias Casa',
          value: '${stats['vitoriasCasa']}',
          subtitle: '${stats['percentualCasa'].toStringAsFixed(1)}%',
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Symbols.flight_rounded,
          title: 'Vitórias Fora',
          value: '${stats['vitoriasFora']}',
          subtitle: '${stats['percentualFora'].toStringAsFixed(1)}%',
          color: Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Symbols.balance_rounded,
          title: 'Empates',
          value: '${stats['empates']}',
          subtitle: '${stats['percentualEmpates'].toStringAsFixed(1)}%',
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _calcularTabela(List<dynamic> jogos) {
    final Map<String, Map<String, dynamic>> times = {};

    for (var jogo in jogos) {
      final status = jogo['match_status'] ?? '';
      if (!status.contains('Finished') && status != 'FT' && status != 'AET') continue;

      final homeName = jogo['match_hometeam_name'];
      final awayName = jogo['match_awayteam_name'];
      final homeScore = int.tryParse(jogo['match_hometeam_score']?.toString() ?? '0') ?? 0;
      final awayScore = int.tryParse(jogo['match_awayteam_score']?.toString() ?? '0') ?? 0;

      if (homeName != null) {
        times.putIfAbsent(homeName, () => {
          'nome': homeName,
          'logo': jogo['team_home_badge'],
          'jogos': 0,
          'vitorias': 0,
          'empates': 0,
          'derrotas': 0,
          'golsPro': 0,
          'golsContra': 0,
          'pontos': 0,
        });

        times[homeName]!['jogos']++;
        times[homeName]!['golsPro'] += homeScore;
        times[homeName]!['golsContra'] += awayScore;

        if (homeScore > awayScore) {
          times[homeName]!['vitorias']++;
          times[homeName]!['pontos'] += 3;
        } else if (homeScore == awayScore) {
          times[homeName]!['empates']++;
          times[homeName]!['pontos'] += 1;
        } else {
          times[homeName]!['derrotas']++;
        }
      }

      if (awayName != null) {
        times.putIfAbsent(awayName, () => {
          'nome': awayName,
          'logo': jogo['team_away_badge'],
          'jogos': 0,
          'vitorias': 0,
          'empates': 0,
          'derrotas': 0,
          'golsPro': 0,
          'golsContra': 0,
          'pontos': 0,
        });

        times[awayName]!['jogos']++;
        times[awayName]!['golsPro'] += awayScore;
        times[awayName]!['golsContra'] += homeScore;

        if (awayScore > homeScore) {
          times[awayName]!['vitorias']++;
          times[awayName]!['pontos'] += 3;
        } else if (awayScore == homeScore) {
          times[awayName]!['empates']++;
          times[awayName]!['pontos'] += 1;
        } else {
          times[awayName]!['derrotas']++;
        }
      }
    }

    final tabela = times.values.toList();
    tabela.sort((a, b) {
      final comparePontos = b['pontos'].compareTo(a['pontos']);
      if (comparePontos != 0) return comparePontos;

      final saldoA = a['golsPro'] - a['golsContra'];
      final saldoB = b['golsPro'] - b['golsContra'];
      final compareSaldo = saldoB.compareTo(saldoA);
      if (compareSaldo != 0) return compareSaldo;

      return b['golsPro'].compareTo(a['golsPro']);
    });

    return tabela;
  }

  Map<String, dynamic> _calcularEstatisticas(List<dynamic> jogos) {
    int totalJogos = 0;
    int totalGols = 0;
    int vitoriasCasa = 0;
    int vitoriasFora = 0;
    int empates = 0;

    for (var jogo in jogos) {
      final status = jogo['match_status'] ?? '';
      if (!status.contains('Finished') && status != 'FT' && status != 'AET') continue;

      totalJogos++;

      final homeScore = int.tryParse(jogo['match_hometeam_score']?.toString() ?? '0') ?? 0;
      final awayScore = int.tryParse(jogo['match_awayteam_score']?.toString() ?? '0') ?? 0;

      totalGols += homeScore + awayScore;

      if (homeScore > awayScore) {
        vitoriasCasa++;
      } else if (awayScore > homeScore) {
        vitoriasFora++;
      } else {
        empates++;
      }
    }

    return {
      'totalJogos': totalJogos,
      'totalGols': totalGols,
      'mediaGols': totalJogos > 0 ? totalGols / totalJogos : 0.0,
      'vitoriasCasa': vitoriasCasa,
      'vitoriasFora': vitoriasFora,
      'empates': empates,
      'percentualCasa': totalJogos > 0 ? (vitoriasCasa / totalJogos) * 100 : 0.0,
      'percentualFora': totalJogos > 0 ? (vitoriasFora / totalJogos) * 100 : 0.0,
      'percentualEmpates': totalJogos > 0 ? (empates / totalJogos) * 100 : 0.0,
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
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}