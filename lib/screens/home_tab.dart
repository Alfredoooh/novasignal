import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'jogo_detalhes_page.dart';
import 'home_config_page.dart';
import 'news_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  List<dynamic> _jogos = [];
  List<dynamic> _jogosAoVivo = [];
  bool _isLoading = true;
  String? _error;
  Timer? _liveUpdateTimer;
  final List<Map<String, dynamic>> _noticias = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        int next = _pageController.page!.round();
        if (_currentPage != next) {
          setState(() {
            _currentPage = next;
          });
        }
      }
    });
    _loadTopMatches();
    _startLiveUpdates();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _liveUpdateTimer?.cancel();
    super.dispose();
  }

  void _startLiveUpdates() {
    _liveUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadTopMatches();
      }
    });
  }

  Future<void> _loadTopMatches() async {
    if (!mounted) return;

    setState(() {
      _isLoading = _jogos.isEmpty;
      _error = null;
    });

    try {
      final appState = context.read<AppState>();
      final jogos = await appState.carregarJogosDestaque(appState.topClubs);

      if (!mounted) return;

      final liveMatches = jogos.where((jogo) {
        final status = jogo['match_status'] ?? '';
        final isNumeric = int.tryParse(status.toString()) != null;
        return isNumeric || status.contains("'") || status == 'HT' || status == 'LIVE' || status == '1H' || status == '2H';
      }).toList();

      setState(() {
        _jogos = jogos;
        _jogosAoVivo = liveMatches;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openNewsPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => NewsPage(noticias: _noticias),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _openHomeConfig() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HomeConfigPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading && _jogos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _jogos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.error_rounded, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            const Text('Erro ao carregar jogos'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadTopMatches,
              icon: const Icon(Symbols.refresh_rounded),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_jogos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.sports_soccer_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('Nenhum jogo de grandes clubes'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadTopMatches,
              icon: const Icon(Symbols.refresh_rounded),
              label: const Text('Recarregar'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadTopMatches,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grandes Clubes',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: _openHomeConfig,
                      icon: const Icon(Symbols.tune_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                        padding: const EdgeInsets.all(12),
                      ),
                      tooltip: 'Configurar Tela Inicial',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_jogos.isNotEmpty) ...[
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _jogos.take(10).length,
                    itemBuilder: (context, index) => _buildAppleSportsCard(_jogos[index], index),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _jogos.take(10).length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (_jogosAoVivo.isNotEmpty) ...[
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Em Direto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ..._jogosAoVivo.map((jogo) => _buildLiveMatchCard(jogo)),
              ],
              const SizedBox(height: 180),
            ],
          ),
        ),
        // Área de Notícias Inferior - Estilo Modal
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -10) {
                _openNewsPage();
              }
            },
            onTap: _openNewsPage,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 14, bottom: 10),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.article_rounded,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Atualidades',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Symbols.expand_less_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Divider(
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _noticias.isEmpty 
                          ? 'Sem conteúdo ainda • Deslize para cima'
                          : '${_noticias.length} ${_noticias.length == 1 ? 'notícia disponível' : 'notícias disponíveis'} • Deslize para cima',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppleSportsCard(dynamic jogo, int index) {
    final status = jogo['match_status'] ?? '';
    final isNumeric = int.tryParse(status.toString()) != null;
    final isLive = isNumeric || status.contains("'") || status == 'HT' || status == 'LIVE' || status == '1H' || status == '2H';
    final leagueName = jogo['league_name'] ?? '';
    final leagueLogo = jogo['league_logo'];

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.12)).clamp(0.88, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 160,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: isLive ? Border.all(color: Colors.red, width: 2) : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  if (leagueLogo != null && leagueLogo.toString().isNotEmpty) ...[
                    Image.network(
                      leagueLogo,
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      leagueName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AO VIVO',
                        style: TextStyle(
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
                    child: Column(
                      children: [
                        Image.network(
                          jogo['team_home_badge'] ?? '',
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          jogo['match_hometeam_name'] ?? '',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _LiveTimeIndicator(status: status),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${jogo['match_hometeam_score'] ?? '0'}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '-',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${jogo['match_awayteam_score'] ?? '0'}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.primary,
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
                        Image.network(
                          jogo['team_away_badge'] ?? '',
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          jogo['match_awayteam_name'] ?? '',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildLiveMatchCard(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    final leagueName = jogo['league_name'] ?? '';
    final leagueLogo = jogo['league_logo'];

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                if (leagueLogo != null && leagueLogo.toString().isNotEmpty) ...[
                  Image.network(
                    leagueLogo,
                    width: 18,
                    height: 18,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    leagueName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                      _LiveTimeIndicator(status: status, compact: true),
                      const SizedBox(height: 4),
                      Text(
                        '${jogo['match_hometeam_score'] ?? '0'} - ${jogo['match_awayteam_score'] ?? '0'}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
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
}

class _LiveTimeIndicator extends StatefulWidget {
  final String status;
  final bool compact;

  const _LiveTimeIndicator({required this.status, this.compact = false});

  @override
  State<_LiveTimeIndicator> createState() => _LiveTimeIndicatorState();
}

class _LiveTimeIndicatorState extends State<_LiveTimeIndicator> {
  late Timer _timer;
  bool _showApostrophe = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _showApostrophe = !_showApostrophe;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNumeric = int.tryParse(widget.status.toString()) != null;
    final isLive = isNumeric || widget.status.contains("'") || widget.status == 'LIVE' || widget.status == '1H' || widget.status == '2H';
    final isHT = widget.status == 'HT';

    Color timeColor = isHT 
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : isLive 
            ? const Color(0xFF00C853)
            : Theme.of(context).colorScheme.onSurfaceVariant;

    String displayText = widget.status;
    if (isNumeric) {
      displayText = isLive && _showApostrophe ? "${widget.status}'" : widget.status;
    } else if (isLive && !isHT) {
      displayText = _showApostrophe ? "${widget.status}'" : widget.status;
    }

    return Text(
      displayText,
      style: TextStyle(
        fontSize: widget.compact ? 11 : 13,
        fontWeight: FontWeight.w700,
        color: timeColor,
      ),
    );
  }
}