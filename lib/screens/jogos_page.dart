import 'dart:async';
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
  late AnimationController _blinkController;
  late PageController _pageController;
  Timer? _autoRefreshTimer;

  final Map<int, List<dynamic>> _cacheJogosPorTab = {};

  String? _lastFiltro;
  int _selectedTabIndex = 60;
  bool _isLoadingNewTab = false;
  int _contentKey = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pageController = PageController(initialPage: 60);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJogosDoDia();
      _startAutoRefresh();
    });
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _refreshCurrentTab();
      }
    });
  }

  Future<void> _refreshCurrentTab() async {
    _cacheJogosPorTab.remove(_selectedTabIndex);
    await _loadJogosDoDia();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _pageController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(JogosPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final appState = context.read<AppState>();
    if (_lastFiltro != appState.filtroJogos) {
      _lastFiltro = appState.filtroJogos;
      if (mounted) {
        setState(() {
          _contentKey++;
        });
      }
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
    final jogos = _cacheJogosPorTab[_selectedTabIndex];
    if (jogos == null) return 0;
    return jogos.where((jogo) => _isJogoAoVivo(jogo)).length;
  }

  Future<void> _loadJogosDoDia() async {
    if (!mounted) return;

    if (_cacheJogosPorTab.containsKey(_selectedTabIndex)) {
      if (mounted) {
        setState(() {
          _isLoadingNewTab = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingNewTab = true;
      });
    }

    final appState = context.read<AppState>();
    final resultado = _getDateAndFilterForIndex(_selectedTabIndex);

    appState.filtrarJogos(resultado['filter']);

    try {
      final jogos = await appState.carregarJogosDoDia(resultado['date']);

      if (mounted) {
        setState(() {
          _cacheJogosPorTab[_selectedTabIndex] = jogos;
          _isLoadingNewTab = false;
          _contentKey++;
        });
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar jogos: $e');
      if (mounted) {
        setState(() {
          _isLoadingNewTab = false;
          _cacheJogosPorTab[_selectedTabIndex] = [];
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    _cacheJogosPorTab.remove(_selectedTabIndex);
    await _loadJogosDoDia();
  }

  void _onPageChanged(int index) {
    if (_selectedTabIndex == index) return;

    final resultado = _getDateAndFilterForIndex(index);
    context.read<AppState>().filtrarJogos(resultado['filter']);

    if (_cacheJogosPorTab.containsKey(index)) {
      setState(() {
        _selectedTabIndex = index;
        _contentKey++;
      });
    } else {
      setState(() {
        _selectedTabIndex = index;
        _isLoadingNewTab = true;
        _contentKey++;
      });
      _loadJogosDoDia();
    }
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: List.generate(121, (index) {
                final isSelected = _selectedTabIndex == index;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary 
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      _getTabLabel(index),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: 121,
            itemBuilder: (context, index) {
              return _buildOptimizedContent(appState, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizedContent(AppState appState, int index) {
    final jogos = _cacheJogosPorTab[index];

    if (_isLoadingNewTab && jogos == null && index == _selectedTabIndex) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (jogos == null && index == _selectedTabIndex) {
      return const Center(
        child: Text(
          'Sem ligação à rede\nPor favor, tente mais tarde',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    if (jogos == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: _buildCachedContent(jogos, appState.filtroJogos),
    );
  }

  Widget _buildCachedContent(List<dynamic> jogos, String filtro) {
    final jogosFiltrados = _filtrarJogos(jogos, filtro);

    if (jogosFiltrados.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
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
          ),
        ],
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

    if (int.tryParse(status.toString()) != null) {
      return true;
    }

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

  String _truncarNomeLiga(String nome) {
    if (nome.length <= 30) return nome;
    return '${nome.substring(0, 27)}...';
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
      key: ValueKey('lista_$_selectedTabIndex'),
      padding: EdgeInsets.zero,
      itemCount: ligasOrdenadas.length,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      itemBuilder: (context, index) {
        final ligaNome = ligasOrdenadas[index];
        final jogosLiga = jogosPorLiga[ligaNome]!;
        final ligaInfo = ligasInfo[ligaNome]!;
        final leagueLogo = ligaInfo['logo'];
        final leagueId = ligaInfo['id'];
        final isLastLiga = index == ligasOrdenadas.length - 1;

        return Column(
          children: [
            _AnimatedBouncyButton(
              onPressed: () {
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
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    if (leagueLogo != null && leagueLogo.toString().isNotEmpty) ...[
                      Hero(
                        tag: 'liga_logo_$leagueId',
                        child: _CachedNetworkImage(
                          imageUrl: leagueLogo,
                          width: 24,
                          height: 24,
                          placeholder: Icon(
                            Symbols.emoji_events_rounded,
                            size: 24,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else ...[
                      Icon(
                        Symbols.emoji_events_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        _truncarNomeLiga(ligaNome),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${jogosLiga.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            ...jogosLiga.asMap().entries.map((entry) {
              final idx = entry.key;
              final jogo = entry.value;
              final isLast = idx == jogosLiga.length - 1;
              return _buildMatchItem(jogo, isLast);
            }),
            if (!isLastLiga)
              Container(
                height: 8,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMatchItem(dynamic jogo, bool isLast) {
    final status = jogo['match_status'] ?? '';
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

    String displayStatus = status;
    if (isNumericStatus) {
      displayStatus = "$status'";
    }

    final isAoVivoTab = _selectedTabIndex == 61;

    return _AnimatedBouncyButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      if (!isAoVivoTab) ...[
                        const SizedBox(width: 8),
                        AnimatedBuilder(
                          animation: _blinkController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: _blinkController.value > 0.5
                                    ? [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.7),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: const Text(
                                'AO VIVO',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
                      const Text(
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
          if (!isLast)
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
        ],
      ),
    );
  }
}

class _AnimatedBouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _AnimatedBouncyButton({
    required this.child,
    required this.onPressed,
  });

  @override
  State<_AnimatedBouncyButton> createState() => _AnimatedBouncyButtonState();
}

class _AnimatedBouncyButtonState extends State<_AnimatedBouncyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    _controller.reset();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
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