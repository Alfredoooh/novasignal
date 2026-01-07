import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/cors_image.dart';
import 'jogo_detalhes_page.dart';
import 'ligas_page.dart';

class JogosPage extends StatefulWidget {
  const JogosPage({super.key});

  @override
  State<JogosPage> createState() => _JogosPageState();
}

class _JogosPageState extends State<JogosPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _blinkController;
  Timer? _autoRefreshTimer;

  final Map<String, List<dynamic>> _cacheJogosPorFiltro = {};

  final List<String> _ligasPrioritarias = [
    'LaLiga',
    'Premier League',
    'Serie A',
    'Bundesliga',
    'Ligue 1',
    'UEFA Champions League',
    'UEFA Europa League',
    'Liga Portugal',
  ];

  String _selectedFilter = 'hoje';
  String? _lastFiltro;
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
    _cacheJogosPorFiltro.remove(_selectedFilter);
    await _loadJogosDoDia();
  }

  @override
  void dispose() {
    _blinkController.dispose();
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

  DateTime _getDateForFilter(String filter) {
    final hoje = DateTime.now();

    switch (filter) {
      case 'ontem':
        return hoje.subtract(const Duration(days: 1));
      case 'amanha':
        return hoje.add(const Duration(days: 1));
      default:
        return hoje;
    }
  }

  int _contarJogosAoVivo() {
    final jogos = _cacheJogosPorFiltro[_selectedFilter];
    if (jogos == null) return 0;
    return jogos.where((jogo) => _isJogoAoVivo(jogo)).length;
  }

  Future<void> _loadJogosDoDia() async {
    if (!mounted) return;

    if (_cacheJogosPorFiltro.containsKey(_selectedFilter)) {
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
    final date = _getDateForFilter(_selectedFilter);

    appState.filtrarJogos(_selectedFilter);

    try {
      final jogos = await appState.carregarJogosDoDia(date);

      if (mounted) {
        setState(() {
          _cacheJogosPorFiltro[_selectedFilter] = jogos;
          _isLoadingNewTab = false;
          _contentKey++;
        });
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar jogos: $e');
      if (mounted) {
        setState(() {
          _isLoadingNewTab = false;
          _cacheJogosPorFiltro[_selectedFilter] = [];
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    _cacheJogosPorFiltro.remove(_selectedFilter);
    await _loadJogosDoDia();
  }

  void _onFilterChanged(String newFilter) {
    if (_selectedFilter == newFilter) return;

    context.read<AppState>().filtrarJogos(newFilter);

    if (_cacheJogosPorFiltro.containsKey(newFilter)) {
      setState(() {
        _selectedFilter = newFilter;
        _contentKey++;
      });
    } else {
      setState(() {
        _selectedFilter = newFilter;
        _isLoadingNewTab = true;
        _contentKey++;
      });
      _loadJogosDoDia();
    }
  }

  int _getPrioridadeLiga(String ligaNome) {
    final index = _ligasPrioritarias.indexWhere(
      (liga) => ligaNome.toLowerCase().contains(liga.toLowerCase())
    );
    return index == -1 ? 999 : index;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildToggleButtons(isDark),
        ),
        Expanded(
          child: _buildContent(appState),
        ),
      ],
    );
  }

  Widget _buildToggleButtons(bool isDark) {
    final aoVivoCount = _contarJogosAoVivo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDark 
              ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6)
              : const Color(0xFFE5E5EA), // Cinza iOS claro
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: _IOSStyleTabButton(
                label: 'Ontem',
                isSelected: _selectedFilter == 'ontem',
                onTap: () => _onFilterChanged('ontem'),
              ),
            ),
            Expanded(
              child: _IOSStyleTabButton(
                label: 'Hoje',
                isSelected: _selectedFilter == 'hoje',
                onTap: () => _onFilterChanged('hoje'),
              ),
            ),
            Expanded(
              child: _IOSStyleTabButton(
                label: aoVivoCount > 0 ? 'Ao Vivo ($aoVivoCount)' : 'Ao Vivo',
                isSelected: _selectedFilter == 'direto',
                onTap: () => _onFilterChanged('direto'),
                isLive: true,
              ),
            ),
            Expanded(
              child: _IOSStyleTabButton(
                label: 'Amanhã',
                isSelected: _selectedFilter == 'amanha',
                onTap: () => _onFilterChanged('amanha'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppState appState) {
    final jogos = _cacheJogosPorFiltro[_selectedFilter];

    if (_isLoadingNewTab && jogos == null) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (jogos == null) {
      return const Center(
        child: Text(
          'Sem ligação à rede\nPor favor, tente mais tarde',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      );
    }

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

  Widget _formatTeamName(String name) {
    final words = name.split(' ');

    if (words.length == 1) {
      return Text(
        name,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    } else if (words.length == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            words[0],
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            words[1],
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    } else {
      final firstLine = words.sublist(0, words.length - 1).join(' ');
      final secondLine = words.last;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstLine,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            secondLine,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    }
  }

  void _showQuickMatchDetails(BuildContext context, dynamic jogo) {
    final homeYellowCards = int.tryParse(jogo['match_hometeam_yellow_cards']?.toString() ?? '0') ?? 0;
    final homeRedCards = int.tryParse(jogo['match_hometeam_red_cards']?.toString() ?? '0') ?? 0;
    final awayYellowCards = int.tryParse(jogo['match_awayteam_yellow_cards']?.toString() ?? '0') ?? 0;
    final awayRedCards = int.tryParse(jogo['match_awayteam_red_cards']?.toString() ?? '0') ?? 0;

    int homePercent = 50;
    int awayPercent = 50;
    int homePasses = 0;
    int awayPasses = 0;

    final status = jogo['match_status'] ?? '';
    final isNotStarted = status == 'Not Started' || 
                         status == '' || 
                         (jogo['match_hometeam_score']?.toString() == '' && 
                          jogo['match_awayteam_score']?.toString() == '');

    if (isNotStarted) {
      homePercent = 0;
      awayPercent = 0;
    } else {
      try {
        final statistics = jogo['statistics'];
        if (statistics != null && statistics is List && statistics.isNotEmpty) {
          for (var stat in statistics) {
            if (stat != null && stat is Map) {
              final type = stat['type']?.toString() ?? '';
              if (type == 'Ball Possession' || type.toLowerCase().contains('possession')) {
                final homeValue = stat['home']?.toString() ?? '';
                final cleanValue = homeValue.replaceAll('%', '').replaceAll(' ', '').trim();
                if (cleanValue.isNotEmpty) {
                  homePercent = int.tryParse(cleanValue) ?? 50;
                  awayPercent = 100 - homePercent;
                }
              } else if (type == 'Passes %' || type.toLowerCase().contains('passes')) {
                final homeValue = stat['home']?.toString() ?? '';
                final awayValue = stat['away']?.toString() ?? '';

                final homeClean = homeValue.replaceAll('%', '').trim();
                final awayClean = awayValue.replaceAll('%', '').trim();

                homePasses = int.tryParse(homeClean) ?? 0;
                awayPasses = int.tryParse(awayClean) ?? 0;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('❌ Erro ao carregar estatísticas: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _QuickMatchDetailsModal(
        jogo: jogo,
        homePercent: homePercent,
        awayPercent: awayPercent,
        homePasses: homePasses,
        awayPasses: awayPasses,
        homeYellowCards: homeYellowCards,
        homeRedCards: homeRedCards,
        awayYellowCards: awayYellowCards,
        awayRedCards: awayRedCards,
        isNotStarted: isNotStarted,
      ),
    );
  }

  Widget _buildJogosList(List<dynamic> jogos) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    ligasOrdenadas.sort((a, b) {
      final prioA = _getPrioridadeLiga(a);
      final prioB = _getPrioridadeLiga(b);
      return prioA.compareTo(prioB);
    });

    return ListView.builder(
      key: ValueKey('lista_$_selectedFilter'),
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
                color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    if (leagueLogo != null && leagueLogo.toString().isNotEmpty) ...[
                      Hero(
                        tag: 'liga_logo_$leagueId',
                        child: CorsImage(
                          imageUrl: leagueLogo,
                          width: 24,
                          height: 24,
                          errorWidget: Icon(
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
              final isFirst = idx == 0;
              final isLast = idx == jogosLiga.length - 1;
              return _buildMatchItem(jogo, isFirst, isLast);
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

  Widget _buildMatchItem(dynamic jogo, bool isFirst, bool isLast) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    final isAoVivoTab = _selectedFilter == 'direto';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
          ),
        );
      },
      onLongPress: () {
        _showQuickMatchDetails(context, jogo);
      },
      child: Column(
        children: [
          Container(
            color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _formatTeamName(jogo['match_hometeam_name'] ?? ''),
                          ),
                          const SizedBox(width: 8),
                          CorsImage(
                            imageUrl: jogo['team_home_badge'] ?? '',
                            width: 32,
                            height: 32,
                            errorWidget: Container(
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
                          CorsImage(
                            imageUrl: jogo['team_away_badge'] ?? '',
                            width: 32,
                            height: 32,
                            errorWidget: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _formatTeamName(jogo['match_awayteam_name'] ?? ''),
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
                    ] else if (isHalfTime) ...[
                      Text(
                        'INT',
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
                if (isPlaying && !isAoVivoTab) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(100),
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
                  ),
                ],
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

class _IOSStyleTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLive;

  const _IOSStyleTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? Theme.of(context).colorScheme.surface : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
              blurRadius: isDark ? 8 : 4,
              offset: const Offset(0, 1),
            ),
          ] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? (isDark ? Theme.of(context).colorScheme.onSurface : Colors.black)
                  : (isDark ? Theme.of(context).colorScheme.onSurfaceVariant : const Color(0xFF3C3C43).withOpacity(0.6)),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _QuickMatchDetailsModal extends StatelessWidget {
  final dynamic jogo;
  final int homePercent;
  final int awayPercent;
  final int homePasses;
  final int awayPasses;
  final int homeYellowCards;
  final int homeRedCards;
  final int awayYellowCards;
  final int awayRedCards;
  final bool isNotStarted;

  const _QuickMatchDetailsModal({
    required this.jogo,
    required this.homePercent,
    required this.awayPercent,
    required this.homePasses,
    required this.awayPasses,
    required this.homeYellowCards,
    required this.homeRedCards,
    required this.awayYellowCards,
    required this.awayRedCards,
    required this.isNotStarted,
  });

   @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalhes Rápidos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Symbols.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          CorsImage(
                            imageUrl: jogo['team_home_badge'] ?? '',
                            width: 56,
                            height: 56,
                            errorWidget: Icon(
                              Symbols.shield_rounded,
                              size: 56,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            jogo['match_hometeam_name'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${jogo['match_hometeam_score'] ?? '0'} : ${jogo['match_awayteam_score'] ?? '0'}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          CorsImage(
                            imageUrl: jogo['team_away_badge'] ?? '',
                            width: 56,
                            height: 56,
                            errorWidget: Icon(
                              Symbols.shield_rounded,
                              size: 56,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            jogo['match_awayteam_name'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (isNotStarted) ...[
                  Text(
                    'Jogo ainda não começou',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  _StatRow(
                    label: 'Posse de Bola',
                    homeValue: homePercent,
                    awayValue: awayPercent,
                    isPercentage: true,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  if (homePasses > 0 || awayPasses > 0)
                    _StatRow(
                      label: 'Passes Certos',
                      homeValue: homePasses,
                      awayValue: awayPasses,
                      isPercentage: true,
                      isDark: isDark,
                    ),
                  if (homePasses > 0 || awayPasses > 0) const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Cartões',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (homeYellowCards > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$homeYellowCards',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                if (homeRedCards > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE53935),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$homeRedCards',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                if (homeYellowCards == 0 && homeRedCards == 0)
                                  const Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Cartões',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (awayYellowCards > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$awayYellowCards',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                if (awayRedCards > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE53935),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$awayRedCards',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                if (awayYellowCards == 0 && awayRedCards == 0)
                                  const Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int homeValue;
  final int awayValue;
  final bool isPercentage;
  final bool isDark;

  const _StatRow({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    this.isPercentage = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final total = homeValue + awayValue;
    final homeProgress = total > 0 ? homeValue / total : 0.5;

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              isPercentage ? '$homeValue%' : '$homeValue',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: homeProgress,
                  backgroundColor: isDark ? const Color(0xFFFF7043) : const Color(0xFFFF6F00),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? const Color(0xFF42A5F5) : const Color(0xFF1976D2),
                  ),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isPercentage ? '$awayValue%' : '$awayValue',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
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