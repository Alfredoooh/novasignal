import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'jogo_detalhes_page.dart';

class LigaDetalhesPage extends StatefulWidget {
  final String ligaId;
  final Map<String, dynamic>? ligaData;
  final String? ligaNome;
  final String? ligaLogo;

  const LigaDetalhesPage({
    super.key,
    required this.ligaId,
    this.ligaData,
    this.ligaNome,
    this.ligaLogo,
  });

  @override
  State<LigaDetalhesPage> createState() => _LigaDetalhesPageState();
}

class _LigaDetalhesPageState extends State<LigaDetalhesPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  Future<List<dynamic>>? _futureJogos;
  Future<List<dynamic>>? _futureClassificacao;
  List<dynamic>? _cachedJogos;
  List<dynamic>? _cachedClassificacao;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _loadLigaData();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
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
          _buildClassificacaoFromMatches(jogos);
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

  void _buildClassificacaoFromMatches(List<dynamic> jogos) {
    if (jogos.isEmpty) return;

    Map<String, Map<String, dynamic>> tabelaCalculada = {};

    for (var jogo in jogos) {
      final status = jogo['match_status'] ?? '';
      final isFinished = status.contains('Finished') || status == 'FT' || status == 'AET';

      if (!isFinished) continue;

      final homeTeam = jogo['match_hometeam_name'] ?? '';
      final awayTeam = jogo['match_awayteam_name'] ?? '';
      final homeScore = int.tryParse(jogo['match_hometeam_score']?.toString() ?? '0') ?? 0;
      final awayScore = int.tryParse(jogo['match_awayteam_score']?.toString() ?? '0') ?? 0;
      final homeBadge = jogo['team_home_badge'] ?? '';
      final awayBadge = jogo['team_away_badge'] ?? '';

      if (!tabelaCalculada.containsKey(homeTeam)) {
        tabelaCalculada[homeTeam] = {
          'team_name': homeTeam,
          'team_badge': homeBadge,
          'overall_league_payed': 0,
          'overall_league_W': 0,
          'overall_league_D': 0,
          'overall_league_L': 0,
          'overall_league_GF': 0,
          'overall_league_GA': 0,
          'overall_league_PTS': 0,
        };
      }

      if (!tabelaCalculada.containsKey(awayTeam)) {
        tabelaCalculada[awayTeam] = {
          'team_name': awayTeam,
          'team_badge': awayBadge,
          'overall_league_payed': 0,
          'overall_league_W': 0,
          'overall_league_D': 0,
          'overall_league_L': 0,
          'overall_league_GF': 0,
          'overall_league_GA': 0,
          'overall_league_PTS': 0,
        };
      }

      tabelaCalculada[homeTeam]!['overall_league_payed'] = 
          (tabelaCalculada[homeTeam]!['overall_league_payed'] as int) + 1;
      tabelaCalculada[awayTeam]!['overall_league_payed'] = 
          (tabelaCalculada[awayTeam]!['overall_league_payed'] as int) + 1;

      tabelaCalculada[homeTeam]!['overall_league_GF'] = 
          (tabelaCalculada[homeTeam]!['overall_league_GF'] as int) + homeScore;
      tabelaCalculada[homeTeam]!['overall_league_GA'] = 
          (tabelaCalculada[homeTeam]!['overall_league_GA'] as int) + awayScore;
      tabelaCalculada[awayTeam]!['overall_league_GF'] = 
          (tabelaCalculada[awayTeam]!['overall_league_GF'] as int) + awayScore;
      tabelaCalculada[awayTeam]!['overall_league_GA'] = 
          (tabelaCalculada[awayTeam]!['overall_league_GA'] as int) + homeScore;

      if (homeScore > awayScore) {
        tabelaCalculada[homeTeam]!['overall_league_W'] = 
            (tabelaCalculada[homeTeam]!['overall_league_W'] as int) + 1;
        tabelaCalculada[homeTeam]!['overall_league_PTS'] = 
            (tabelaCalculada[homeTeam]!['overall_league_PTS'] as int) + 3;
        tabelaCalculada[awayTeam]!['overall_league_L'] = 
            (tabelaCalculada[awayTeam]!['overall_league_L'] as int) + 1;
      } else if (awayScore > homeScore) {
        tabelaCalculada[awayTeam]!['overall_league_W'] = 
            (tabelaCalculada[awayTeam]!['overall_league_W'] as int) + 1;
        tabelaCalculada[awayTeam]!['overall_league_PTS'] = 
            (tabelaCalculada[awayTeam]!['overall_league_PTS'] as int) + 3;
        tabelaCalculada[homeTeam]!['overall_league_L'] = 
            (tabelaCalculada[homeTeam]!['overall_league_L'] as int) + 1;
      } else {
        tabelaCalculada[homeTeam]!['overall_league_D'] = 
            (tabelaCalculada[homeTeam]!['overall_league_D'] as int) + 1;
        tabelaCalculada[homeTeam]!['overall_league_PTS'] = 
            (tabelaCalculada[homeTeam]!['overall_league_PTS'] as int) + 1;
        tabelaCalculada[awayTeam]!['overall_league_D'] = 
            (tabelaCalculada[awayTeam]!['overall_league_D'] as int) + 1;
        tabelaCalculada[awayTeam]!['overall_league_PTS'] = 
            (tabelaCalculada[awayTeam]!['overall_league_PTS'] as int) + 1;
      }
    }

    final tabelaOrdenada = tabelaCalculada.values.toList()
      ..sort((a, b) {
        final pontosCompare = (b['overall_league_PTS'] as int)
            .compareTo(a['overall_league_PTS'] as int);
        if (pontosCompare != 0) return pontosCompare;

        final saldoA = (a['overall_league_GF'] as int) - (a['overall_league_GA'] as int);
        final saldoB = (b['overall_league_GF'] as int) - (b['overall_league_GA'] as int);
        final saldoCompare = saldoB.compareTo(saldoA);
        if (saldoCompare != 0) return saldoCompare;

        return (b['overall_league_GF'] as int).compareTo(a['overall_league_GF'] as int);
      });

    setState(() {
      _cachedClassificacao = tabelaOrdenada;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final ligaData = widget.ligaData ??
        {
          'league_name': widget.ligaNome ?? 'Liga',
          'league_logo': widget.ligaLogo ?? '',
        };

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                stretch: true,
                backgroundColor: cs.surface,
                leading: IconButton(
                  icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    ligaData['league_name'] ?? 'Liga',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
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
                          cs.primaryContainer,
                          cs.surface,
                        ],
                      ),
                    ),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.7 + (0.3 * value),
                            child: ligaData['league_logo'] != null && 
                                   ligaData['league_logo'].toString().isNotEmpty
                                ? Image.network(
                                    ligaData['league_logo'],
                                    width: 80,
                                    height: 80,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Symbols.emoji_events_rounded,
                                      size: 80,
                                      color: cs.primary.withOpacity(0.3),
                                    ),
                                  )
                                : Icon(
                                    Symbols.emoji_events_rounded,
                                    size: 80,
                                    color: cs.primary.withOpacity(0.3),
                                  ),
                          );
                        },
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
                    labelColor: cs.primary,
                    unselectedLabelColor: cs.onSurfaceVariant,
                    indicatorColor: cs.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'Classificação'),
                      Tab(text: 'Jogos'),
                      Tab(text: 'Estatísticas'),
                    ],
                  ),
                  cs.surface,
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
      ),
    );
  }

  // Continua na Parte 2...
  Widget _buildClassificacaoTab() {
    return Container(); // Placeholder - implementado na Parte 2
  }

  Widget _buildJogosTab() {
    return Container(); // Placeholder - implementado na Parte 2
  }

  Widget _buildEstatisticasTab() {
    return Container(); // Placeholder - implementado na Parte 2
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _backgroundColor;

  _SliverTabBarDelegate(this._tabBar, this._backgroundColor);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

// CONTINUAÇÃO DA PARTE 1 - Cole este código substituindo os métodos placeholder

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
          if (_cachedJogos != null && _cachedJogos!.isNotEmpty) {
            return _buildClassificacaoContent(_cachedClassificacao ?? []);
          }
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (classificacao.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.table_chart_rounded,
              size: 64,
              color: cs.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text('Nenhum jogo finalizado ainda'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classificacao.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? cs.primaryContainer : cs.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'Pos',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Clube',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'J',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'V',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'E',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'D',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(
                  width: 45,
                  child: Text(
                    'Pts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final time = classificacao[index - 1];
        final posicao = index;

        final jogos = (time['overall_league_payed'] ?? time['jogos'] ?? 0) as int;
        final vitorias = (time['overall_league_W'] ?? time['vitorias'] ?? 0) as int;
        final empates = (time['overall_league_D'] ?? time['empates'] ?? 0) as int;
        final derrotas = (time['overall_league_L'] ?? time['derrotas'] ?? 0) as int;
        final pontos = (time['overall_league_PTS'] ?? time['pontos'] ?? 0) as int;

        Color? posicaoColor;
        Color? borderColor;

        if (posicao <= 4) {
          posicaoColor = Colors.green.withOpacity(isDark ? 0.15 : 0.1);
          borderColor = Colors.green;
        } else if (posicao <= 6) {
          posicaoColor = Colors.orange.withOpacity(isDark ? 0.15 : 0.1);
          borderColor = Colors.orange;
        } else if (posicao >= classificacao.length - 2) {
          posicaoColor = Colors.red.withOpacity(isDark ? 0.15 : 0.1);
          borderColor = Colors.red;
        }

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 30)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: posicaoColor ?? (isDark ? cs.surface : Colors.white),
                    border: Border(
                      bottom: BorderSide(
                        color: cs.outlineVariant.withOpacity(0.2),
                        width: 0.5,
                      ),
                      left: borderColor != null
                          ? BorderSide(color: borderColor, width: 4)
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$posicao',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            if ((time['team_badge'] ?? '').toString().isNotEmpty) ...[
                              Image.network(
                                time['team_badge'],
                                width: 28,
                                height: 28,
                                errorBuilder: (_, __, ___) => Icon(
                                  Symbols.shield_rounded,
                                  size: 28,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: Text(
                                time['team_name']?.toString() ?? 'Unknown',
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
                          '$jogos',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        width: 35,
                        child: Text(
                          '$vitorias',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        width: 35,
                        child: Text(
                          '$empates',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        width: 35,
                        child: Text(
                          '$derrotas',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        width: 45,
                        child: Text(
                          '$pontos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 40)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 15 * (1 - value)),
                child: OpenContainer(
                  closedElevation: 0,
                  openElevation: 0,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  closedColor: isDark ? cs.surfaceContainerHighest : Colors.white,
                  openColor: cs.surface,
                  transitionDuration: const Duration(milliseconds: 400),
                  closedBuilder: (context, action) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? cs.surfaceContainerHighest : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isLive
                            ? Colors.red
                            : cs.outlineVariant.withOpacity(0.3),
                        width: isLive ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: action,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${jogo['match_date']} • ${jogo['match_time']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLive
                                        ? Colors.red
                                        : isFinished
                                            ? cs.surfaceContainer
                                            : Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    formatarStatus(status),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isLive || !isFinished
                                          ? Colors.white
                                          : cs.onSurfaceVariant,
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
                                        errorBuilder: (_, __, ___) => Icon(
                                          Symbols.shield_rounded,
                                          size: 32,
                                          color: cs.onSurfaceVariant,
                                        ),
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
                                      color: cs.primary,
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
                                        errorBuilder: (_, __, ___) => Icon(
                                          Symbols.shield_rounded,
                                          size: 32,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  openBuilder: (context, action) => JogoDetalhesPage(
                    jogoId: jogo['match_id'],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEstatisticasTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.analytics_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text('Estatísticas em breve'),
        ],
      ),
    );
  }