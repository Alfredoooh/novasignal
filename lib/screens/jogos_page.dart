import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animations/animations.dart';
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
  late AnimationController _loadingController;
  late AnimationController _blinkController;
  late TabController _tabController;

  // Cache otimizado por índice de tab
  final Map<int, List<dynamic>> _cacheJogosPorTab = {};

  String? _lastFiltro;
  Timer? _autoUpdateTimer;
  int _selectedTabIndex = 60;
  bool _isLoadingNewTab = false;

  // Key para forçar rebuild apenas do conteúdo
  int _contentKey = 0;

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

    // Listener otimizado - apenas quando a animação terminar
    _tabController.addListener(_handleTabChange);

    // ✅ CORREÇÃO: Carrega os dados imediatamente após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJogosDoDia();
      _startAutoUpdate();
    });
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && _tabController.index != _selectedTabIndex) {
      final newIndex = _tabController.index;

      // Atualiza imediatamente se já tiver cache
      if (_cacheJogosPorTab.containsKey(newIndex)) {
        setState(() {
          _selectedTabIndex = newIndex;
          _contentKey++;
        });
      } else {
        // Só mostra loading se não tiver cache
        setState(() {
          _selectedTabIndex = newIndex;
          _isLoadingNewTab = true;
          _contentKey++;
        });
        _loadJogosDoDia();
      }
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _blinkController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _autoUpdateTimer?.cancel();
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

  void _startAutoUpdate() {
    _autoUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
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
        _cacheJogosPorTab[_selectedTabIndex] = jogos;
        _contentKey++;
      });
    } catch (e) {
      debugPrint('❌ Erro no silent update: $e');
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

  // ✅ CORREÇÃO: Método refatorado para carregar corretamente
  Future<void> _loadJogosDoDia() async {
    if (!mounted) return;

    // Verifica se já tem cache para essa tab
    if (_cacheJogosPorTab.containsKey(_selectedTabIndex)) {
      if (mounted) {
        setState(() {
          _isLoadingNewTab = false;
        });
      }
      return;
    }

    // ✅ Marca como loading ANTES de começar
    if (mounted) {
      setState(() {
        _isLoadingNewTab = true;
      });
    }

    final appState = context.read<AppState>();
    final resultado = _getDateAndFilterForIndex(_selectedTabIndex);

    appState.filtrarJogos(resultado['filter']);

    try {
      debugPrint('🔄 Carregando jogos para tab $_selectedTabIndex - Data: ${resultado['date']} - Filtro: ${resultado['filter']}');
      
      final jogos = await appState.carregarJogosDoDia(resultado['date']);

      debugPrint('✅ ${jogos.length} jogos carregados para tab $_selectedTabIndex');

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
          // ✅ Salva lista vazia para evitar carregamento infinito
          _cacheJogosPorTab[_selectedTabIndex] = [];
        });
      }
    }
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 120,
            borderRadius: 16,
            blur: 10,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.3),
                Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.1),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.outline.withOpacity(0.2),
                Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
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
            tabAlignment: TabAlignment.start,
            tabs: List.generate(121, (index) => Tab(text: _getTabLabel(index))),
          ),
        ),
        Expanded(
          child: _buildOptimizedContent(appState),
        ),
      ],
    );
  }

  Widget _buildOptimizedContent(AppState appState) {
    final jogos = _cacheJogosPorTab[_selectedTabIndex];

    // ✅ CORREÇÃO: Mostra loading enquanto carrega pela primeira vez
    if (_isLoadingNewTab && jogos == null) {
      return _buildLoadingShimmer();
    }

    // ✅ Se não tem dados e não está carregando, mostra vazio
    if (jogos == null) {
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
            const Text('Erro ao carregar jogos'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _cacheJogosPorTab.remove(_selectedTabIndex);
                _loadJogosDoDia();
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // Usa AnimatedSwitcher para transição suave
    return AnimatedSwitcher(
      key: ValueKey(_contentKey),
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _buildCachedContent(jogos, appState.filtroJogos),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: ligasOrdenadas.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final ligaNome = ligasOrdenadas[index];
        final jogosLiga = jogosPorLiga[ligaNome]!;
        final ligaInfo = ligasInfo[ligaNome]!;
        final leagueLogo = ligaInfo['logo'];
        final leagueId = ligaInfo['id'];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
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
              _AnimatedBouncyButton(
                onPressed: () {
                  if (leagueId != null) {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => LigaDetalhesPage(
                          ligaId: leagueId.toString(),
                          ligaNome: ligaNome,
                          ligaLogo: leagueLogo,
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
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
            ],
          ),
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

    return _AnimatedBouncyButton(
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                JogoDetalhesPage(jogoId: jogo['match_id']),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
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
                    if (isPlaying)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 40),
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

// ==================== ANIMATED BOUNCY BUTTON ====================
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

// ==================== CACHED NETWORK IMAGE ====================
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