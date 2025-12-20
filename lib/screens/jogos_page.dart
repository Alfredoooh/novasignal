import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'dart:math' show cos, sin, pi;
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
  List<dynamic>? _cachedJogos;
  String? _lastFiltro;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJogos();
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _blinkController.dispose();
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

  void _loadJogos() async {
    final appState = context.read<AppState>();
    setState(() {
      _futureJogos = appState.carregarJogosDoDia(appState.dataSelecionada);
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
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _AnimatedFilterChip(
                  label: 'Hoje',
                  icon: Symbols.today_rounded,
                  isSelected: appState.filtroJogos == 'hoje',
                  onSelected: () => appState.filtrarJogos('hoje'),
                ),
                const SizedBox(width: 8),
                _AnimatedFilterChip(
                  label: 'Ao Vivo',
                  icon: Symbols.circle_rounded,
                  isSelected: appState.filtroJogos == 'direto',
                  onSelected: () => appState.filtrarJogos('direto'),
                ),
                const SizedBox(width: 8),
                _AnimatedFilterChip(
                  label: 'Terminados',
                  icon: Symbols.check_circle_rounded,
                  isSelected: appState.filtroJogos == 'terminados',
                  onSelected: () => appState.filtrarJogos('terminados'),
                ),
              ],
            ),
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
                            onPressed: _loadJogos,
                            icon: const Icon(Symbols.refresh_rounded),
                            label: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('Erro ao carregar jogos'));
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
            const Text('Nenhum jogo disponível'),
          ],
        ),
      );
    }

    return _buildJogosList(jogosFiltrados);
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
      default:
        return jogos;
    }
  }

  Widget _buildJogosList(List<dynamic> jogos) {
    Map<String, List<dynamic>> jogosPorLiga = {};
    List<String> ligasOrdenadas = [];

    for (var jogo in jogos) {
      String ligaNome = jogo['league_name'] ?? 'Outras';
      if (!jogosPorLiga.containsKey(ligaNome)) {
        jogosPorLiga[ligaNome] = [];
        ligasOrdenadas.add(ligaNome);
      }
      jogosPorLiga[ligaNome]!.add(jogo);
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: ligasOrdenadas.length,
      addAutomaticKeepAlives: true,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final ligaNome = ligasOrdenadas[index];
        final jogosLiga = jogosPorLiga[ligaNome]!;
        final leagueLogo = jogosLiga.isNotEmpty ? jogosLiga[0]['league_logo'] : null;
        final leagueId = jogosLiga.isNotEmpty ? jogosLiga[0]['league_id'] : null;

        return Container(
          color: Theme.of(context).colorScheme.surface,
          margin: const EdgeInsets.only(bottom: 8),
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      if (leagueLogo != null && leagueLogo.toString().isNotEmpty) ...[
                        _CachedNetworkImage(
                          imageUrl: leagueLogo,
                          width: 24,
                          height: 24,
                          placeholder: Icon(
                            Symbols.emoji_events_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ] else ...[
                        Icon(Symbols.emoji_events_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          ligaNome,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '${jogosLiga.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Symbols.chevron_right_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ...jogosLiga.map((jogo) => _buildMatchItem(jogo)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchItem(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'LIVE';
    final isHalfTime = status == 'HT';

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 0.5,
            ),
          ),
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
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                if (isLive)
                  AnimatedBuilder(
                    animation: _blinkController,
                    builder: (context, child) {
                      return Text(
                        "${status.replaceAll("'", "")}${_blinkController.value > 0.5 ? "'" : ""}",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      );
                    },
                  )
                else
                  Text(
                    formatarStatus(status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isHalfTime ? Colors.amber : getStatusColor(status, context),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _CachedNetworkImage(
                        imageUrl: jogo['team_home_badge'] ?? '',
                        width: 32,
                        height: 32,
                        placeholder: Container(width: 32, height: 32),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          jogo['match_hometeam_name'] ?? '',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _CachedNetworkImage(
                        imageUrl: jogo['team_away_badge'] ?? '',
                        width: 32,
                        height: 32,
                        placeholder: Container(width: 32, height: 32),
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

// Widget de filtro com animação de clique
class _AnimatedFilterChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const _AnimatedFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<_AnimatedFilterChip> createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<_AnimatedFilterChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _animation = Tween<double>(begin: 20, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onSelected();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(_animation.value),
              border: Border.all(
                color: widget.isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget de imagem com cache
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