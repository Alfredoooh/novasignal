import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'jogo_detalhes_page.dart';
import 'home_config_page.dart';
import 'news_detail_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _grandesClubesController = PageController(viewportFraction: 0.88);
  final PageController _aoVivoController = PageController(viewportFraction: 0.88);
  final PageController _jogosHojeController = PageController(viewportFraction: 0.88);
  
  List<dynamic> _jogosHoje = [];
  List<dynamic> _jogosAmanha = [];
  List<dynamic> _jogosAoVivo = [];
  List<dynamic> _todosJogosHoje = [];
  String? _error;
  Timer? _autoRefreshTimer;
  List<Map<String, dynamic>> _noticias = [];
  bool _loadingNews = false;
  bool _isLoading = true;
  
  int _grandesClubesCurrentPage = 0;
  int _aoVivoCurrentPage = 0;
  int _jogosHojeCurrentPage = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startAutoRefresh();
    _setupPageControllers();
  }

  void _setupPageControllers() {
    _grandesClubesController.addListener(() {
      if (_grandesClubesController.page != null) {
        final newPage = _grandesClubesController.page!.round();
        if (_grandesClubesCurrentPage != newPage) {
          setState(() {
            _grandesClubesCurrentPage = newPage;
          });
        }
      }
    });

    _aoVivoController.addListener(() {
      if (_aoVivoController.page != null) {
        final newPage = _aoVivoController.page!.round();
        if (_aoVivoCurrentPage != newPage) {
          setState(() {
            _aoVivoCurrentPage = newPage;
          });
        }
      }
    });

    _jogosHojeController.addListener(() {
      if (_jogosHojeController.page != null) {
        final newPage = _jogosHojeController.page!.round();
        if (_jogosHojeCurrentPage != newPage) {
          setState(() {
            _jogosHojeCurrentPage = newPage;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _grandesClubesController.dispose();
    _aoVivoController.dispose();
    _jogosHojeController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadTopMatches();
        _loadAllTodayMatches();
      }
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      _loadTopMatches(),
      _loadAllTodayMatches(),
      _loadNews(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllTodayMatches() async {
    if (!mounted) return;

    try {
      final appState = context.read<AppState>();
      final hoje = DateTime.now();
      final jogosHoje = await appState.carregarJogosDoDia(hoje);

      debugPrint('📅 Jogos de hoje carregados: ${jogosHoje.length}');

      if (!mounted) return;

      setState(() {
        _todosJogosHoje = jogosHoje;
      });
    } catch (e) {
      debugPrint('❌ Erro ao carregar jogos de hoje: $e');
    }
  }

  Future<void> _loadTopMatches() async {
    if (!mounted) return;

    try {
      final appState = context.read<AppState>();
      final todosJogos = await appState.carregarJogosDestaque(appState.topClubs);

      debugPrint('⭐ Jogos destaque carregados: ${todosJogos.length}');

      if (!mounted) return;

      final hoje = DateTime.now();
      final amanha = hoje.add(const Duration(days: 1));

      final dataHoje = '${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}';
      final dataAmanha = '${amanha.year}-${amanha.month.toString().padLeft(2, '0')}-${amanha.day.toString().padLeft(2, '0')}';

      final jogosHoje = todosJogos.where((jogo) {
        return jogo['match_date'] == dataHoje;
      }).toList();

      final jogosAmanha = todosJogos.where((jogo) {
        return jogo['match_date'] == dataAmanha;
      }).toList();

      final liveMatches = jogosHoje.where((jogo) {
        final status = jogo['match_status'] ?? '';
        final isNumeric = int.tryParse(status.toString()) != null;
        return isNumeric || status.contains("'") || status == 'HT' || status == 'LIVE' || status == '1H' || status == '2H';
      }).toList();

      debugPrint('🏆 Jogos hoje: ${jogosHoje.length}, Amanhã: ${jogosAmanha.length}, Ao vivo: ${liveMatches.length}');

      setState(() {
        _jogosHoje = jogosHoje;
        _jogosAmanha = jogosAmanha;
        _jogosAoVivo = liveMatches;
        _error = null;
      });
    } catch (e) {
      debugPrint('❌ Erro ao carregar jogos destaque: $e');
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _loadNews() async {
    if (!mounted) return;

    setState(() {
      _loadingNews = true;
    });

    try {
      final appState = context.read<AppState>();
      final noticias = await appState.carregarNoticias();

      debugPrint('📰 Notícias carregadas: ${noticias.length}');

      if (!mounted) return;

      setState(() {
        _noticias = noticias;
        _loadingNews = false;
      });
    } catch (e) {
      debugPrint('❌ Erro ao carregar notícias: $e');
      if (!mounted) return;

      setState(() {
        _loadingNews = false;
      });
    }
  }

  void _openHomeConfig() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HomeConfigPage(),
      ),
    );
  }

  void _openNewsDetail(Map<String, dynamic> noticia) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewsDetailPage(noticia: noticia),
      ),
    );
  }

  Color _getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const Color(0xFF2C2C2E);
    }
    return const Color(0xFFF3F3F3);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildGrandesClubesSection(),
          _buildJogosAoVivoSection(),
          _buildJogosDeHojeSection(),
          _buildNewsSection(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildGrandesClubesSection() {
    final temGrandesClubes = _jogosHoje.isNotEmpty || _jogosAmanha.isNotEmpty;
    
    if (!temGrandesClubes) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final todosJogos = [..._jogosHoje, ..._jogosAmanha];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  icon: const Icon(Symbols.more_horiz_rounded),
                  padding: const EdgeInsets.all(12),
                  tooltip: 'Configurar Tela Inicial',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _grandesClubesController,
              itemCount: todosJogos.length,
              itemBuilder: (context, index) {
                return _buildHorizontalGameCard(todosJogos[index], _grandesClubesController, index);
              },
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                todosJogos.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _grandesClubesCurrentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _grandesClubesCurrentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildJogosAoVivoSection() {
    if (_jogosAoVivo.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _BlinkingDot(),
                const SizedBox(width: 8),
                const Text('Em Direto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _aoVivoController,
              itemCount: _jogosAoVivo.length,
              itemBuilder: (context, index) {
                return _buildHorizontalGameCard(_jogosAoVivo[index], _aoVivoController, index);
              },
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _jogosAoVivo.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _aoVivoCurrentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _aoVivoCurrentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildJogosDeHojeSection() {
    final temGrandesClubes = _jogosHoje.isNotEmpty || _jogosAmanha.isNotEmpty;
    
    if (temGrandesClubes || _todosJogosHoje.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Symbols.sports_soccer_rounded,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Jogos de Hoje',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _jogosHojeController,
              itemCount: _todosJogosHoje.take(10).length,
              itemBuilder: (context, index) {
                return _buildHorizontalGameCard(_todosJogosHoje[index], _jogosHojeController, index);
              },
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _todosJogosHoje.take(10).length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _jogosHojeCurrentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _jogosHojeCurrentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    if (_loadingNews) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (_noticias.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final noticia = _noticias[index];
          final isLast = index == _noticias.length - 1;
          return _buildNewsItem(noticia, isLast);
        },
        childCount: _noticias.take(10).length,
      ),
    );
  }

  Widget _buildNewsItem(Map<String, dynamic> noticia, bool isLast) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openNewsDetail(noticia),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: noticia['image'] != null && noticia['image'].toString().isNotEmpty
                          ? Image.network(
                              noticia['image'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Symbols.article_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 32,
                              ),
                            )
                          : Icon(
                              Symbols.article_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 32,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noticia['title'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          noticia['subtitle'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (noticia['date'] != null && (noticia['date'] as String).isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Euronews.com',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                ),
                              ),
                              Text(
                                ' · ${noticia['date']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
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
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          ),
      ],
    );
  }

  Widget _buildHorizontalGameCard(dynamic jogo, PageController controller, int index) {
    final status = jogo['match_status'] ?? '';
    final isNumeric = int.tryParse(status.toString()) != null;
    final isLive = isNumeric || status.contains("'") || status == 'HT' || status == 'LIVE' || status == '1H' || status == '2H';
    final isHT = status == 'HT';
    final isNotStarted = status == '' || status == 'NS' || status.contains('Not Started');
    
    final homeYellowCards = int.tryParse(jogo['match_hometeam_yellow_cards']?.toString() ?? '0') ?? 0;
    final homeRedCards = int.tryParse(jogo['match_hometeam_red_cards']?.toString() ?? '0') ?? 0;
    final awayYellowCards = int.tryParse(jogo['match_awayteam_yellow_cards']?.toString() ?? '0') ?? 0;
    final awayRedCards = int.tryParse(jogo['match_awayteam_red_cards']?.toString() ?? '0') ?? 0;

    final homeScore = int.tryParse(jogo['match_hometeam_score']?.toString() ?? '0') ?? 0;
    final awayScore = int.tryParse(jogo['match_awayteam_score']?.toString() ?? '0') ?? 0;

    int homePercent = isNotStarted ? 0 : 50;
    int awayPercent = isNotStarted ? 0 : 50;
    
    try {
      if (!isNotStarted) {
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
                  debugPrint('✅ Posse de bola encontrada: Casa $homePercent% - Fora $awayPercent%');
                  break;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar estatísticas: $e');
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value = 1.0;
        double scale = 1.0;
        
        if (controller.position.haveDimensions) {
          value = controller.page! - index;
          scale = (1 - (value.abs() * 0.12)).clamp(0.88, 1.0);
        }

        return Center(
          child: Transform.scale(
            scale: scale,
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
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _getCardColor(context),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          jogo['team_home_badge'] ?? '',
                          width: 56,
                          height: 56,
                          errorBuilder: (_, __, ___) => Icon(
                            Symbols.shield_rounded,
                            size: 56,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.green.shade500,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Casa',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (homeYellowCards > 0 || homeRedCards > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (homeYellowCards > 0) ...[
                                Container(
                                  width: 18,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$homeYellowCards',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              if (homeRedCards > 0)
                                Container(
                                  width: 18,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$homeRedCards',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(
                        '$homeScore : $awayScore',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Ao Vivo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isHT ? 'INT' : status,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isLive && !isHT
                                ? const Color(0xFF00C853)
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          jogo['team_away_badge'] ?? '',
                          width: 56,
                          height: 56,
                          errorBuilder: (_, __, ___) => Icon(
                            Symbols.shield_rounded,
                            size: 56,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade500,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Fora',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (awayYellowCards > 0 || awayRedCards > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (awayYellowCards > 0) ...[
                                Container(
                                  width: 18,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$awayYellowCards',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              if (awayRedCards > 0)
                                Container(
                                  width: 18,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$awayRedCards',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$homePercent%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: isNotStarted ? 0 : (homePercent / 100),
                            backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? const Color(0xFF42A5F5) : const Color(0xFF1976D2),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$awayPercent%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: isNotStarted ? 0 : (awayPercent / 100),
                            backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? const Color(0xFFFF7043) : const Color(0xFFFF6F00),
                            ),
                            minHeight: 8,
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
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}