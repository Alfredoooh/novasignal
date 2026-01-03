import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/cors_image.dart';
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

  List<dynamic>? _jogos;
  List<dynamic>? _classificacao;
  bool _isLoading = true;
  String? _errorMessage;

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

    _fadeController.forward();
    _loadLigaData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadLigaData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appState = context.read<AppState>();

      final jogos = await appState.carregarJogosPorLiga(widget.ligaId);

      print('🏆 Liga ID: ${widget.ligaId}');
      print('⚽ Jogos carregados: ${jogos.length}');

      if (jogos.isNotEmpty) {
        print('📋 Primeiro jogo: ${jogos[0]}');
      }

      final classificacao = _buildClassificacaoFromMatches(jogos);

      print('📊 Classificação calculada: ${classificacao.length} times');

      if (mounted) {
        setState(() {
          _jogos = jogos;
          _classificacao = classificacao;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar dados da liga: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar dados: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _buildClassificacaoFromMatches(List<dynamic> jogos) {
    if (jogos.isEmpty) return [];

    Map<String, Map<String, dynamic>> tabelaCalculada = {};

    for (var jogo in jogos) {
      final status = jogo['match_status']?.toString() ?? '';
      final isFinished = status.contains('Finished') || status == 'FT' || status == 'AET';

      if (!isFinished) continue;

      final homeTeam = jogo['match_hometeam_name']?.toString() ?? '';
      final awayTeam = jogo['match_awayteam_name']?.toString() ?? '';

      if (homeTeam.isEmpty || awayTeam.isEmpty) continue;

      final homeScore = int.tryParse(jogo['match_hometeam_score']?.toString() ?? '0') ?? 0;
      final awayScore = int.tryParse(jogo['match_awayteam_score']?.toString() ?? '0') ?? 0;
      final homeBadge = jogo['team_home_badge']?.toString() ?? '';
      final awayBadge = jogo['team_away_badge']?.toString() ?? '';

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

    return tabelaOrdenada;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                                ? CorsImage(
                                    imageUrl: ligaData['league_logo'],
                                    width: 80,
                                    height: 80,
                                    errorWidget: Icon(
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
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.error_rounded,
                            size: 64,
                            color: cs.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar dados',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _loadLigaData,
                            icon: const Icon(Symbols.refresh_rounded),
                            label: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
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

  Widget _buildClassificacaoTab() {
    if (_classificacao == null || _classificacao!.isEmpty) {
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
            Text(
              'Nenhum jogo finalizado ainda',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A classificação aparecerá após os jogos',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return _buildClassificacaoContent(_classificacao!);
  }

  Widget _buildClassificacaoContent(List<dynamic> classificacao) {
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
          posicaoColor = Colors.green.withOpacity(0.08);
          borderColor = Colors.green.withOpacity(0.4);
        } else if (posicao <= 6) {
          posicaoColor = Colors.orange.withOpacity(0.08);
          borderColor = Colors.orange.withOpacity(0.4);
        } else if (posicao >= classificacao.length - 2) {
          posicaoColor = Theme.of(context).colorScheme.errorContainer.withOpacity(0.3);
          borderColor = Theme.of(context).colorScheme.error.withOpacity(0.3);
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
                    color: posicaoColor ?? Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                        width: 0.5,
                      ),
                      left: borderColor != null
                          ? BorderSide(color: borderColor, width: 3)
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
                            TeamLogo(
                              logoUrl: time['team_badge'],
                              size: 28,
                            ),
                            const SizedBox(width: 10),
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJogosTab() {
    if (_jogos == null || _jogos!.isEmpty) {
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
            Text(
              'Nenhum jogo disponível',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return _buildJogosContent(_jogos!);
  }

  Widget _buildJogosContent(List<dynamic> jogos) {
    final jogosSorted = List<dynamic>.from(jogos)
      ..sort((a, b) {
        final dateA = a['match_date']?.toString() ?? '';
        final dateB = b['match_date']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jogosSorted.length,
      itemBuilder: (context, index) {
        final jogo = jogosSorted[index];
        final status = jogo['match_status']?.toString() ?? '';
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
                child: InkWell(
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
                            ? Colors.red.withOpacity(0.3)
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
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
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isFinished 
                                      ? Theme.of(context).colorScheme.onSurface 
                                      : Colors.white,
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
                                  TeamLogo(
                                    logoUrl: jogo['team_home_badge'],
                                    size: 32,
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
                                  TeamLogo(
                                    logoUrl: jogo['team_away_badge'],
                                    size: 32,
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
            );
          },
        );
      },
    );
  }

  Widget _buildEstatisticasTab() {
    if (_classificacao == null || _classificacao!.isEmpty) {
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

    return _buildEstatisticasContent(_classificacao!);
  }

  Widget _buildEstatisticasContent(List<dynamic> classificacao) {
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
          if (top3.length >= 3) ...[
            Text(
              'Top 3 Clubes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildPodium(top3, context),
          ],
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
            const SizedBox(height: 12),
            ...bottom3.asMap().entries.map((entry) {
              final time = entry.value;
              final pos = classificacao.length - 2 + entry.key;
              final isFirst = entry.key == 0;
              final isLast = entry.key == bottom3.length - 1;
              return _buildBottomTeamCard(time, pos, context, isFirst, isLast);
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
            const SizedBox(height: 12),
            ...artilheiros.take(5).toList().asMap().entries.map((entry) {
              final isFirst = entry.key == 0;
              final isLast = entry.key == artilheiros.take(5).length - 1;
              return _buildArtilheiroCard(entry.value, context, isFirst, isLast);
            }),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _calcularArtilheiros() {
    if (_jogos == null || _jogos!.isEmpty) return [];

    Map<String, Map<String, dynamic>> golsPorTime = {};

    for (var jogo in _jogos!) {
      final homeTeam = jogo['match_hometeam_name']?.toString() ?? '';
      final awayTeam = jogo['match_awayteam_name']?.toString() ?? '';
      final homeScore = int.tryParse(jogo['match_hometeam_score']?.toString() ?? '0') ?? 0;
      final awayScore = int.tryParse(jogo['match_awayteam_score']?.toString() ?? '0') ?? 0;
      final homeBadge = jogo['team_home_badge']?.toString() ?? '';
      final awayBadge = jogo['team_away_badge']?.toString() ?? '';

      if (homeTeam.isEmpty || awayTeam.isEmpty) continue;

      if (!golsPorTime.containsKey(homeTeam)) {
        golsPorTime[homeTeam] = {'team': homeTeam, 'badge': homeBadge, 'gols': 0};
      }

      if (!golsPorTime.containsKey(awayTeam)) {
        golsPorTime[awayTeam] = {'team': awayTeam, 'badge': awayBadge, 'gols': 0};
      }

      golsPorTime[homeTeam]!['gols'] = (golsPorTime[homeTeam]!['gols'] as int) + homeScore;
      golsPorTime[awayTeam]!['gols'] = (golsPorTime[awayTeam]!['gols'] as int) + awayScore;
    }

    final artilheiros = golsPorTime.values.toList()
      ..sort((a, b) => (b['gols'] as int).compareTo(a['gols'] as int));

    return artilheiros;
  }

  Widget _buildArtilheiroCard(Map<String, dynamic> artilheiro, BuildContext context, bool isFirst, bool isLast) {
    final cs = Theme.of(context).colorScheme;
    
    BorderRadius borderRadius;
    if (isFirst && isLast) {
      borderRadius = BorderRadius.circular(16);
    } else if (isFirst) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(4),
      );
    } else if (isLast) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    } else {
      borderRadius = BorderRadius.circular(4);
    }

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          TeamLogo(
            logoUrl: artilheiro['badge'],
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              artilheiro['team']?.toString() ?? '',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${artilheiro['gols']} gols',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<dynamic> top3, BuildContext context) {
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
          _buildPodiumTeam(top3[1], 2, context),
          _buildPodiumTeam(top3[0], 1, context),
          _buildPodiumTeam(top3[2], 3, context),
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

  Widget _buildPodiumTeam(Map<String, dynamic> time, int posicao, BuildContext context) {
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
                color: posicao == 1 
                    ? Colors.amber.withOpacity(0.5)
                    : posicao == 2 
                        ? Colors.grey.shade400.withOpacity(0.5)
                        : Colors.brown.withOpacity(0.5),
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
              child: TeamLogo(
                logoUrl: time['team_badge'],
                size: posicao == 1 ? 70 : 60,
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
          Text(
            '$pontos pts',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTeamCard(Map<String, dynamic> time, int posicao, BuildContext context, bool isFirst, bool isLast) {
    final pontos = time['pontos'] as int;
    final cs = Theme.of(context).colorScheme;
    
    BorderRadius borderRadius;
    if (isFirst && isLast) {
      borderRadius = BorderRadius.circular(16);
    } else if (isFirst) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(4),
      );
    } else if (isLast) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    } else {
      borderRadius = BorderRadius.circular(4);
    }

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(0.3),
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.error.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$posicao',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.error,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          TeamLogo(
            logoUrl: time['team_badge'],
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              time['team_name']?.toString() ?? '',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$pontos pts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.error,
            ),
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