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
  Future<List<dynamic>>? _futureJogos;
  late AnimationController _loadingController;
  late AnimationController _blinkController;
  late TabController _tabController;
  late TabController _filtroTabController;
  List<dynamic>? _cachedJogos;
  String? _lastFiltro;
  Timer? _autoUpdateTimer;
  int _selectedDayIndex = 60; // Hoje está no meio dos 120 dias

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
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // 120 dias: 60 no passado + hoje + 59 no futuro
    _tabController = TabController(length: 120, vsync: this, initialIndex: 60);
    _filtroTabController = TabController(length: 4, vsync: this, initialIndex: 0);
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedDayIndex = _tabController.index;
        });
        _loadJogosDoDia();
      }
    });

    _filtroTabController.addListener(() {
      if (_filtroTabController.indexIsChanging) {
        final appState = context.read<AppState>();
        final filtros = ['hoje', 'direto', 'terminados', 'agendados'];
        appState.filtrarJogos(filtros[_filtroTabController.index]);
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
    _filtroTabController.dispose();
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
      final data = _getDateForIndex(_selectedDayIndex);
      final jogos = await appState.carregarJogosDoDia(data);

      if (!mounted) return;

      setState(() {
        _cachedJogos = jogos;
      });
    } catch (e) {
      // Falha silenciosa
    }
  }

  DateTime _getDateForIndex(int index) {
    final hoje = DateTime.now();
    final diferencaDias = index - 60; // 60 é o índice do "hoje"
    return hoje.add(Duration(days: diferencaDias));
  }

  String _getTabLabel(int index) {
    final data = _getDateForIndex(index);
    final diasDiferenca = index - 60;
    
    // Nomes especiais para dias próximos
    if (diasDiferenca == 0) return 'Hoje';
    if (diasDiferenca == -1) return 'Ontem';
    if (diasDiferenca == -2) return 'Anteontem';
    if (diasDiferenca == 1) return 'Amanhã';
    
    // Para outros dias: "Sexta/16", "Sáb/17", etc
    final diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final diaSemana = diasSemana[data.weekday % 7];
    
    return '$diaSemana/${data.day}';
  }

  void _loadJogosDoDia() async {
    final appState = context.read<AppState>();
    final data = _getDateForIndex(_selectedDayIndex);
    
    setState(() {
      _futureJogos = appState.carregarJogosDoDia(data);
    });

    _futureJogos?.then((jogos) {
      if (mounted) {
        setState(() {
          _cachedJogos = jogos;
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
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
            tabs: List.generate(120, (index) => Tab(text: _getTabLabel(index))),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: TabBar(
            controller: _filtroTabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: 'Todos'),
              Tab(text: 'Ao Vivo'),
              Tab(text: 'Terminados'),
              Tab(text: 'Agendados'),
            ],
          ),
        ),
        Expanded(
          child: _cachedJogos != null 
            ? _buildCachedContent(_cachedJogos!, appState.filtroJogos)
            : FutureBuilder<List<dynamic>>(
                future: _futureJogos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingShimmer();
                  } else if (snapshot.hasError) {
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
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _loadJogosDoDia,
                            icon: const Icon(Symbols.refresh_rounded),
                            label: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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

                  return _buildCachedContent(snapshot.data!, appState.filtroJogos);
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
      case 'agendados':
        return 'agendado';
      default:
        return 'disponível';
    }
  }

  List<dynamic> _filtrarJogos(List<dynamic> jogos, String filtro) {
    switch (filtro) {
      case 'direto':
        return jogos.where((j) {
          final status = j['match_status'] ?? '';
          return status.contains("'") || status == 'HT' || status == 'LIVE';
        }).toList();
      case 'terminados':
        return jogos.where((j) {
          final status = j['match_status'] ?? '';
          return status.contains('Finished') || status == 'FT' || status == 'AET';
        }).toList();
      case 'agendados':
        return jogos.where((j) {
          final status = j['match_status'] ?? '';
          return status.isEmpty || status == '' || 
                 (!status.contains("'") && status != 'HT' && status != 'LIVE' && 
                  !status.contains('Finished') && status != 'FT' && status != 'AET');
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
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      if (leagueLogo != null && leagueLogo.toString().isNotEmpty) ...[
                        Hero(
                          tag: 'liga_logo_$leagueId',
                          child: _CachedNetworkImage(
                            imageUrl: leagueLogo,
                            width: 28,
                            height: 28,
                            placeholder: Icon(
                              Symbols.emoji_events_rounded,
                              size: 24,
                              color: Theme.of(context).colorScheme.primary,
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
                          ligaNome,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${jogosLiga.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Symbols.chevron_right_rounded,
                        size: 20,
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
    final isLive = status.contains("'") || status == 'LIVE';
    final isHalfTime = status == 'HT';
    final isPlaying = isLive && !isHalfTime;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
          ),
        );
      },
      borderRadius: isLast 
          ? const BorderRadius.vertical(bottom: Radius.circular(16))
          : BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          borderRadius: isLast 
              ? const BorderRadius.vertical(bottom: Radius.circular(16))
              : BorderRadius.zero,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      jogo['match_time'] ?? '--:--',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isLive || isHalfTime) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isHalfTime ? Colors.amber : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                if (!isPlaying && (isLive || isHalfTime))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isHalfTime ? Colors.orange.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formatarStatus(status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isHalfTime ? Colors.orange : Colors.green,
                      ),
                    ),
                  )
                else if (!isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: getStatusColor(status, context).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formatarStatus(status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: getStatusColor(status, context),
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
                  child: Column(
                    children: [
                      Text(
                        '${jogo['match_hometeam_score'] ?? '-'} : ${jogo['match_awayteam_score'] ?? '-'}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (isPlaying) ...[
                        const SizedBox(height: 4),
                        AnimatedBuilder(
                          animation: _blinkController,
                          builder: (context, child) {
                            return Text(
                              "${status.replaceAll("'", "")}${_blinkController.value > 0.5 ? "'" : ""}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
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