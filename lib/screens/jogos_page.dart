import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'jogo_detalhes_page.dart';
import 'ligas_page.dart';

class JogosPage extends StatefulWidget {
  const JogosPage({super.key});

  @override
  State<JogosPage> createState() => _JogosPageState();
}

class _JogosPageState extends State<JogosPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Future<List<dynamic>>? _futureJogos;
  late AnimationController _loadingController;
  late AnimationController _blinkController;
  late TabController _tabController;
  late PageController _pageController;
  List<dynamic>? _cachedJogos;
  String? _lastFiltro;
  Timer? _autoUpdateTimer;
  int _selectedTabIndex = 60;
  bool _isLoadingNewTab = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _tabController = TabController(length: 121, vsync: this, initialIndex: 60);
    _pageController = PageController(initialPage: 60);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJogosDoDia();
      _startAutoUpdate();
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _blinkController.dispose();
    _tabController.dispose();
    _pageController.dispose();
    _autoUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(JogosPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final appState = context.read<AppState>();
    if (_lastFiltro != appState.filtroJogos) {
      _lastFiltro = appState.filtroJogos;
      if (mounted) setState(() {});
    }
  }

  void _startAutoUpdate() {
    _autoUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _silentUpdate();
      }
    });
  }

  Future<void> _silentUpdate() async {
    if (!mounted) return;

    try {
      final appState = context.read<AppState>();
      final resultado = _getDateAndFilterForIndex(_selectedTabIndex);
      final jogos = await appState.carregarJogosDoDia(resultado['date']);

      if (!mounted) return;

      setState(() {
        _cachedJogos = jogos;
      });
    } catch (e) {
      // Falha silenciosa
    }
  }

  Map<String, dynamic> _getDateAndFilterForIndex(int index) {
    final hoje = DateTime.now();

    if (index < 60) {
      final diferencaDias = index - 60;
      return {
        'date': hoje.add(Duration(days: diferencaDias)),
        'filter': 'hoje',
      };
    }

    if (index == 60) {
      return {'date': hoje, 'filter': 'hoje'};
    }

    if (index == 61) {
      return {'date': hoje, 'filter': 'direto'};
    }

    if (index == 62) {
      return {'date': hoje, 'filter': 'terminados'};
    }

    final diferencaDias = index - 62;
    return {
      'date': hoje.add(Duration(days: diferencaDias)),
      'filter': 'hoje',
    };
  }

  String _getTabLabel(int index) {
    if (index < 60) {
      final data = DateTime.now().add(Duration(days: index - 60));
      final diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      final diaSemana = diasSemana[data.weekday % 7];

      if (index == 58) return 'Anteontem';
      if (index == 59) return 'Ontem';

      return '$diaSemana/${data.day}';
    }

    if (index == 60) return 'Hoje';

    if (index == 61) {
      final jogosAoVivo = _contarJogosAoVivo();
      return jogosAoVivo > 0 ? 'Ao Vivo ($jogosAoVivo)' : 'Ao Vivo';
    }
    if (index == 62) return 'Terminados';

    final data = DateTime.now().add(Duration(days: index - 62));
    final diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final diaSemana = diasSemana[data.weekday % 7];

    if (index == 63) return 'Amanhã';

    return '$diaSemana/${data.day}';
  }

  int _contarJogosAoVivo() {
    if (_cachedJogos == null) return 0;
    return _cachedJogos!.where((jogo) => _isJogoAoVivo(jogo)).length;
  }

  void _loadJogosDoDia() async {
    final appState = context.read<AppState>();
    final resultado = _getDateAndFilterForIndex(_selectedTabIndex);

    appState.filtrarJogos(resultado['filter']);

    setState(() {
      _isLoadingNewTab = true;
      _futureJogos = appState.carregarJogosDoDia(resultado['date']);
    });

    _futureJogos?.then((jogos) {
      if (mounted) {
        setState(() {
          _cachedJogos = jogos;
          _isLoadingNewTab = false;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isLoadingNewTab = false;
        });
      }
    });
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            width: 50,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  shape: BoxShape.circle,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appState = context.watch<AppState>();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: List.generate(121, (index) => Tab(text: _getTabLabel(index))),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              _tabController.animateTo(index);
              setState(() {
                _selectedTabIndex = index;
                _cachedJogos = null;
              });
              _loadJogosDoDia();
            },
            itemCount: 121,
            itemBuilder: (context, index) {
              if (index != _selectedTabIndex) {
                return const SizedBox.shrink();
              }

              if (_isLoadingNewTab || _cachedJogos == null) {
                return _buildLoadingShimmer();
              }

              return _buildCachedContent(_cachedJogos!, appState.filtroJogos);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCachedContent(List<dynamic> jogos, String filtro) {
    final jogosFiltrados = _filtrarJogos(jogos, filtro);

    if (jogosFiltrados.isEmpty) {
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
            Text('Nenhum jogo ${_getTituloFiltro(filtro)}'),
          ],
        ),
      );
    }

    return _buildJogosList(jogosFiltrados);
  }

  String _getTituloFiltro(String filtro) {
    switch (filtro) {
      case 'direto':
        return 'ao vivo no momento';
      case 'terminados':
        return 'terminado';
      default:
        return 'disponível';
    }
  }

  bool _isJogoAoVivo(dynamic jogo) {
    final status = jogo['match_status'] ?? '';

    // Verifica se é um número (minutos do jogo)
    if (int.tryParse(status.toString()) != null) {
      return true;
    }

    // Verifica formatos comuns de jogo ao vivo
    return status.contains("'") || 
           status == 'HT' || 
           status == 'LIVE' ||
           status == '1H' ||
           status == '2H' ||
           status.toLowerCase().contains('half');
  }

  List<dynamic> _filtrarJogos(List<dynamic> jogos, String filtro) {
    switch (filtro) {
      case 'direto':
        return jogos.where((jogo) => _isJogoAoVivo(jogo)).toList();
      case 'terminados':
        return jogos.where((jogo) {
          final status = jogo['match_status'] ?? '';
          return status.contains('Finished') || 
                 status == 'FT' || 
                 status == 'AET' ||
                 status == 'AP' ||
                 status == 'Pen.';
        }).toList();
      default:
        return jogos;
    }
  }

  Widget _buildJogosList(List<dynamic> jogos) {
    Map<String, List<dynamic>> jogosPorLiga = {};
    Map<String, Map<String, dynamic>> ligasInfo = {};
    List<String> ligasOrdenadas = [];

    for (var jogo in jogos) {
      String ligaNome = jogo['league_name'] ?? 'Outras';
      if (!jogosPorLiga.containsKey(ligaNome)) {
        jogosPorLiga[ligaNome] = [];
        ligasOrdenadas.add(ligaNome);
        ligasInfo[ligaNome] = {
          'logo': jogo['league_logo'],
          'id': jogo['league_id'],
        };
      }
      jogosPorLiga[ligaNome]!.add(jogo);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: ligasOrdenadas.length,
      addAutomaticKeepAlives: true,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final ligaNome = ligasOrdenadas[index];
        final jogosLiga = jogosPorLiga[ligaNome]!;
        final ligaInfo = ligasInfo[ligaNome]!;
        final leagueLogo = ligaInfo['logo'];
        final leagueId = ligaInfo['id'];

        return Container(
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  if (leagueId != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LigaDetalhesPage(
                          ligaId: leagueId.toString(),
                          ligaNome: ligaNome,
                          ligaLogo: leagueLogo,
                        ),
                      ),
                    );
                  }
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (leagueLogo != null && leagueLogo.toString().isNotEmpty) ...[
                        Hero(
                          tag: 'liga_logo_$leagueId',
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: _CachedNetworkImage(
                              imageUrl: leagueLogo,
                              width: 20,
                              height: 20,
                              placeholder: Icon(
                                Symbols.emoji_events_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ] else ...[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          child: Icon(
                            Symbols.emoji_events_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          ligaNome,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${jogosLiga.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Symbols.chevron_right_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              ...jogosLiga.asMap().entries.map((entry) {
                final idx = entry.key;
                final jogo = entry.value;
                final isLast = idx == jogosLiga.length - 1;
                return _buildMatchItem(jogo, isLast);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchItem(dynamic jogo, bool isLast) {
    final status = jogo['match_status'] ?? '';

    // Verifica se é um número (minutos do jogo)
    final isNumericStatus = int.tryParse(status.toString()) != null;

    final isLive = isNumericStatus || 
                   status.contains("'") || 
                   status == 'LIVE' ||
                   status == '1H' ||
                   status == '2H';

    final isHalfTime = status == 'HT' || status.toLowerCase() == 'half time';
    final isPlaying = isLive && !isHalfTime;

    final isFinished = status.contains('Finished') || 
                       status == 'FT' || 
                       status == 'AET' ||
                       status == 'AP' ||
                       status == 'Pen.';

    // Formatar o status para exibição
    String displayStatus = status;
    if (isNumericStatus) {
      displayStatus = "$status'";
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
          ),
        );
      },
      borderRadius: isLast 
          ? const BorderRadius.vertical(bottom: Radius.circular(12))
          : BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          border: isLast ? null : Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          borderRadius: isLast 
              ? const BorderRadius.vertical(bottom: Radius.circular(12))
              : BorderRadius.zero,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _CachedNetworkImage(
                        imageUrl: jogo['team_home_badge'] ?? '',
                        width: 32,
                        height: 32,
                        placeholder: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${jogo['match_hometeam_score'] ?? '-'} : ${jogo['match_awayteam_score'] ?? '-'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
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
                      _CachedNetworkImage(
                        imageUrl: jogo['team_away_badge'] ?? '',
                        width: 32,
                        height: 32,
                        placeholder: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isPlaying) ...[
                  AnimatedBuilder(
                    animation: _blinkController,
                    builder: (context, child) {
                      return Text(
                        isNumericStatus 
                            ? "${status}${_blinkController.value > 0.5 ? "'" : ""}"
                            : "${displayStatus.replaceAll("'", "")}${_blinkController.value > 0.5 ? "'" : ""}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00C853),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ] else if (isHalfTime) ...[
                  Text(
                    'HT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else if (isFinished) ...[
                  Text(
                    'Finalizado',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ] else ...[
                  Text(
                    jogo['match_time'] ?? '--:--',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final Widget placeholder;

  const _CachedNetworkImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.placeholder,
  });

  @override
  State<_CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<_CachedNetworkImage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.imageUrl.isEmpty) {
      return widget.placeholder;
    }

    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      cacheWidth: (widget.width * MediaQuery.of(context).devicePixelRatio).round(),
      cacheHeight: (widget.height * MediaQuery.of(context).devicePixelRatio).round(),
      errorBuilder: (_, __, ___) => widget.placeholder,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.placeholder,
        );
      },
    );
  }
}