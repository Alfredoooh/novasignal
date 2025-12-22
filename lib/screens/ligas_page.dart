import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
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
          'jogos': 0,
          'vitorias': 0,
          'empates': 0,
          'derrotas': 0,
          'gols_pro': 0,
          'gols_contra': 0,
          'pontos': 0,
        };
      }

      if (!tabelaCalculada.containsKey(awayTeam)) {
        tabelaCalculada[awayTeam] = {
          'team_name': awayTeam,
          'team_badge': awayBadge,
          'jogos': 0,
          'vitorias': 0,
          'empates': 0,
          'derrotas': 0,
          'gols_pro': 0,
          'gols_contra': 0,
          'pontos': 0,
        };
      }

      tabelaCalculada[homeTeam]!['jogos'] = (tabelaCalculada[homeTeam]!['jogos'] as int) + 1;
      tabelaCalculada[awayTeam]!['jogos'] = (tabelaCalculada[awayTeam]!['jogos'] as int) + 1;

      tabelaCalculada[homeTeam]!['gols_pro'] = (tabelaCalculada[homeTeam]!['gols_pro'] as int) + homeScore;
      tabelaCalculada[homeTeam]!['gols_contra'] = (tabelaCalculada[homeTeam]!['gols_contra'] as int) + awayScore;
      tabelaCalculada[awayTeam]!['gols_pro'] = (tabelaCalculada[awayTeam]!['gols_pro'] as int) + awayScore;
      tabelaCalculada[awayTeam]!['gols_contra'] = (tabelaCalculada[awayTeam]!['gols_contra'] as int) + homeScore;

      if (homeScore > awayScore) {
        tabelaCalculada[homeTeam]!['vitorias'] = (tabelaCalculada[homeTeam]!['vitorias'] as int) + 1;
        tabelaCalculada[homeTeam]!['pontos'] = (tabelaCalculada[homeTeam]!['pontos'] as int) + 3;
        tabelaCalculada[awayTeam]!['derrotas'] = (tabelaCalculada[awayTeam]!['derrotas'] as int) + 1;
      } else if (awayScore > homeScore) {
        tabelaCalculada[awayTeam]!['vitorias'] = (tabelaCalculada[awayTeam]!['vitorias'] as int) + 1;
        tabelaCalculada[awayTeam]!['pontos'] = (tabelaCalculada[awayTeam]!['pontos'] as int) + 3;
        tabelaCalculada[homeTeam]!['derrotas'] = (tabelaCalculada[homeTeam]!['derrotas'] as int) + 1;
      } else {
        tabelaCalculada[homeTeam]!['empates'] = (tabelaCalculada[homeTeam]!['empates'] as int) + 1;
        tabelaCalculada[homeTeam]!['pontos'] = (tabelaCalculada[homeTeam]!['pontos'] as int) + 1;
        tabelaCalculada[awayTeam]!['empates'] = (tabelaCalculada[awayTeam]!['empates'] as int) + 1;
        tabelaCalculada[awayTeam]!['pontos'] = (tabelaCalculada[awayTeam]!['pontos'] as int) + 1;
      }
    }

    final tabelaOrdenada = tabelaCalculada.values.toList()
      ..sort((a, b) {
        final pontosCompare = (b['pontos'] as int).compareTo(a['pontos'] as int);
        if (pontosCompare != 0) return pontosCompare;

        final saldoA = (a['gols_pro'] as int) - (a['gols_contra'] as int);
        final saldoB = (b['gols_pro'] as int) - (b['gols_contra'] as int);
        final saldoCompare = saldoB.compareTo(saldoA);
        if (saldoCompare != 0) return saldoCompare;

        return (b['gols_pro'] as int).compareTo(a['gols_pro'] as int);
      });

    setState(() {
      _cachedClassificacao = tabelaOrdenada;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ligaData = widget.ligaData ??
        {
          'league_name': widget.ligaNome ?? 'Liga',
          'league_logo': widget.ligaLogo ?? '',
        };

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
                  ligaData['league_name'] ?? 'Liga',
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
                    child: ligaData['league_logo'] != null && ligaData['league_logo'].toString().isNotEmpty
                        ? Image.network(
                            ligaData['league_logo'],
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
        return _buildClassificacaoContent(_cachedClassificacao ?? []);
      },
    );
  }

  Widget _buildClassificacaoContent(List<dynamic> classificacao) {
    if (classificacao.isEmpty) {
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
              color: Theme.of(context).colorScheme.primaryContainer,
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Clube',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final time = classificacao[index - 1];
        final posicao = index;

        final jogos = time['jogos'] as int;
        final vitorias = time['vitorias'] as int;
        final empates = time['empates'] as int;
        final derrotas = time['derrotas'] as int;
        final pontos = time['pontos'] as int;

        Color? posicaoColor;
        Color? borderColor;

        if (posicao <= 4) {
          posicaoColor = Colors.green.withOpacity(0.15);
          borderColor = Colors.green;
        } else if (posicao <= 6) {
          posicaoColor = Colors.orange.withOpacity(0.15);
          borderColor = Colors.orange;
        } else if (posicao >= classificacao.length - 2) {
          posicaoColor = Colors.red.withOpacity(0.15);
          borderColor = Colors.red;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: posicaoColor ?? Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
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
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
                        errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 28),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        time['team_name']?.toString() ?? 'Unknown',
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                            ? Colors.red
                            : isFinished
                                ? Theme.of(context).colorScheme.surfaceContainerHighest
                                : Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formatarStatus(status),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
                            errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 32),
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
                            errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 32),
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
    if (_cachedClassificacao == null) {
      return FutureBuilder<List<dynamic>>(
        future: _futureJogos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Sem dados disponíveis'));
          }
          return _buildEstatisticasContent(_cachedClassificacao ?? []);
        },
      );
    }
    return _buildEstatisticasContent(_cachedClassificacao!);
  }

  Widget _buildEstatisticasContent(List<dynamic> classificacao) {
    if (classificacao.isEmpty) {
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
            const Text('Sem dados de estatísticas'),
          ],
        ),
      );
    }

    final top3 = classificacao.take(3).toList();
    final bottom3 = classificacao.length >= 3 
        ? classificacao.skip(classificacao.length - 3).take(3).toList() 
        : [];

    final artilheiros = _calcularArtilheiros();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 3 Clubes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildPodium(top3),
          if (bottom3.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Zona de Rebaixamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...bottom3.asMap().entries.map((entry) {
              final time = entry.value;
              final pos = classificacao.length - 2 + entry.key;
              return _buildBottomTeamCard(time, pos);
            }),
          ],
          if (artilheiros.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Artilheiros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...artilheiros.take(5).map((artilheiro) => _buildArtilheiroCard(artilheiro)),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _calcularArtilheiros() {
    if (_cachedJogos == null) return [];

    Map<String, Map<String, dynamic>> golsPorTime = {};

    for (var jogo in _cachedJogos!) {
      final homeTeam = jogo['match_hometeam_name'] ?? '';
      final awayTeam = jogo['match_awayteam_name'] ?? '';
      final homeScore = int.tryParse(jogo['match_hometeam_score']?.toString() ?? '0') ?? 0;
      final awayScore = int.tryParse(jogo['match_awayteam_score']?.toString() ?? '0') ?? 0;
      final homeBadge = jogo['team_home_badge'] ?? '';
      final awayBadge = jogo['team_away_badge'] ?? '';

      if (!golsPorTime.containsKey(homeTeam)) {
        golsPorTime[homeTeam] = {
          'team': homeTeam,
          'badge': homeBadge,
          'gols': 0,
        };
      }

      if (!golsPorTime.containsKey(awayTeam)) {
        golsPorTime[awayTeam] = {
          'team': awayTeam,
          'badge': awayBadge,
          'gols': 0,
        };
      }

      golsPorTime[homeTeam]!['gols'] = (golsPorTime[homeTeam]!['gols'] as int) + homeScore;
      golsPorTime[awayTeam]!['gols'] = (golsPorTime[awayTeam]!['gols'] as int) + awayScore;
    }

    final artilheiros = golsPorTime.values.toList()
      ..sort((a, b) => (b['gols'] as int).compareTo(a['gols'] as int));

    return artilheiros;
  }

  Widget _buildArtilheiroCard(Map<String, dynamic> artilheiro) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if ((artilheiro['badge'] ?? '').toString().isNotEmpty)
            Image.network(
              artilheiro['badge'],
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 40),
            )
          else
            const Icon(Icons.shield, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              artilheiro['team']?.toString() ?? '',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${artilheiro['gols']} gols',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<dynamic> top3) {
    if (top3.length < 3) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPodiumTeam(top3[1], 2),
          _buildPodiumTeam(top3[0], 1),
          _buildPodiumTeam(top3[2], 3),
        ],
      ),
    );
  }

  String _abreviarNome(String nomeCompleto) {
    final partes = nomeCompleto.trim().split(' ');
    if (partes.length == 1) return nomeCompleto;

    final abreviados = partes.sublist(0, partes.length - 1).map((p) => '${p[0]}.').toList();
    final ultimo = partes.last;

    return '${abreviados.join('')} $ultimo';
  }

  Widget _buildPodiumTeam(Map<String, dynamic> time, int posicao) {
    final pontos = time['pontos'] as int;

    final nomeCompleto = time['team_name']?.toString() ?? '';
    final nomeAbreviado = _abreviarNome(nomeCompleto);

    String medalImage;
    if (posicao == 1) {
      medalImage = 'assets/gold_medal.png';
    } else if (posicao == 2) {
      medalImage = 'assets/silver_medal.png';
    } else {
      medalImage = 'assets/bronze_medal.png';
    }

    return Expanded(
      child: Column(
        children: [
          Image.asset(
            medalImage,
            width: posicao == 1 ? 50 : 45,
            height: posicao == 1 ? 50 : 45,
            errorBuilder: (_, __, ___) => Icon(
              Symbols.workspace_premium_rounded,
              size: posicao == 1 ? 50 : 45,
              color: posicao == 1 ? Colors.amber : posicao == 2 ? Colors.grey.shade400 : Colors.brown,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            width: posicao == 1 ? 70 : 60,
            height: posicao == 1 ? 70 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: posicao == 1 ? Colors.amber : posicao == 2 ? Colors.grey.shade400 : Colors.brown,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: (time['team_badge'] ?? '').toString().isNotEmpty
                  ? Image.network(
                      time['team_badge'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Symbols.shield_rounded,
                        size: posicao == 1 ? 35 : 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Symbols.shield_rounded,
                      size: posicao == 1 ? 35 : 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            nomeAbreviado,
            style: TextStyle(
              fontSize: posicao == 1 ? 13 : 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: posicao == 1 
                  ? Colors.amber.withOpacity(0.2) 
                  : posicao == 2 
                      ? Colors.grey.shade300.withOpacity(0.3) 
                      : Colors.brown.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$pontos pts',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: posicao == 1 ? Colors.amber.shade800 : posicao == 2 ? Colors.grey.shade700 : Colors.brown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTeamCard(Map<String, dynamic> time, int posicao) {
    final pontos = time['pontos'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Row(
        children: [
          Text(
            '$posicao',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.red),
          ),
          const SizedBox(width: 16),
          if ((time['team_badge'] ?? '').toString().isNotEmpty)
            Image.network(
              time['team_badge'],
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 40),
            )
          else
            const Icon(Icons.shield, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              time['team_name']?.toString() ?? '',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$pontos pts',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red),
          ),
        ],
      ),
    );
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