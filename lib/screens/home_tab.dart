import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/cors_image.dart';
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
  final PageController _grandesClubesController = PageController(viewportFraction: 0.92);
  final PageController _jogosHojeController = PageController(viewportFraction: 0.92);

  List<dynamic> _jogosHoje = [];
  List<dynamic> _jogosAmanha = [];
  List<dynamic> _todosJogosHoje = [];
  String? _error;
  Timer? _autoRefreshTimer;
  List<Map<String, dynamic>> _noticias = [];
  bool _loadingNews = false;
  bool _isLoading = true;

  int _grandesClubesCurrentPage = 0;
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
    _jogosHojeController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadTopMatches();
        _loadAllTodayMatches();
        _loadNews();
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
        return (jogo['match_date']?.toString() ?? '') == dataHoje;
      }).toList();

      final jogosAmanha = todosJogos.where((jogo) {
        return (jogo['match_date']?.toString() ?? '') == dataAmanha;
      }).toList();

      // Ordenar: Real Madrid sempre primeiro
      jogosHoje.sort((a, b) {
        final aIsRealMadrid = (a['match_hometeam_name']?.toString().toLowerCase().contains('real madrid') ?? false) ||
                              (a['match_awayteam_name']?.toString().toLowerCase().contains('real madrid') ?? false);
        final bIsRealMadrid = (b['match_hometeam_name']?.toString().toLowerCase().contains('real madrid') ?? false) ||
                              (b['match_awayteam_name']?.toString().toLowerCase().contains('real madrid') ?? false);
        
        if (aIsRealMadrid && !bIsRealMadrid) return -1;
        if (!aIsRealMadrid && bIsRealMadrid) return 1;
        return 0;
      });

      jogosAmanha.sort((a, b) {
        final aIsRealMadrid = (a['match_hometeam_name']?.toString().toLowerCase().contains('real madrid') ?? false) ||
                              (a['match_awayteam_name']?.toString().toLowerCase().contains('real madrid') ?? false);
        final bIsRealMadrid = (b['match_hometeam_name']?.toString().toLowerCase().contains('real madrid') ?? false) ||
                              (b['match_awayteam_name']?.toString().toLowerCase().contains('real madrid') ?? false);
        
        if (aIsRealMadrid && !bIsRealMadrid) return -1;
        if (!aIsRealMadrid && bIsRealMadrid) return 1;
        return 0;
      });

      debugPrint('🏆 Jogos hoje: ${jogosHoje.length}, Amanhã: ${jogosAmanha.length}');

      setState(() {
        _jogosHoje = jogosHoje;
        _jogosAmanha = jogosAmanha;
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

      final safeList = <Map<String, dynamic>>[];
      for (var n in noticias) {
        if (n is Map<String, dynamic>) {
          safeList.add(n);
        } else if (n is Map) {
          safeList.add(Map<String, dynamic>.from(n));
        }
      }

      setState(() {
        _noticias = safeList;
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

  bool _isJogoAoVivo(dynamic jogo) {
    final status = (jogo['match_status']?.toString() ?? '').toLowerCase();
    if (status.isEmpty) return false;
    
    final isNumeric = int.tryParse(status.replaceAll(RegExp(r'\D'), '')) != null && status.trim().isNotEmpty;
    return RegExp(r"live|1h|2h|'|\bminute\b", caseSensitive: false).hasMatch(status) || 
           isNumeric ||
           status.contains("'");
  }

  Map<String, int> _extractPossession(dynamic statistics) {
    int home = 0;
    int away = 0;

    try {
      if (statistics == null) {
        return {'home': 0, 'away': 0};
      }

      if (statistics is List) {
        for (var stat in statistics) {
          if (stat is Map) {
            final type = (stat['type']?.toString() ?? '').toLowerCase();
            if (type.contains('possession') || type.contains('ball')) {
              final homeVal = stat['home']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
              final awayVal = stat['away']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
              
              home = int.tryParse(homeVal) ?? 0;
              away = int.tryParse(awayVal) ?? 0;
              
              if (home > 0 || away > 0) break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao extrair posse: $e');
    }

    home = home.clamp(0, 100);
    away = away.clamp(0, 100);

    // Se não tem dados válidos, retorna 0
    if (home == 0 && away == 0) {
      return {'home': 0, 'away': 0};
    }

    // Normalizar para somar 100
    final sum = home + away;
    if (sum != 100 && sum > 0) {
      home = ((home / sum) * 100).round();
      away = 100 - home;
    }

    return {'home': home, 'away': away};
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
                  'Ainda Hoje',
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
            height: 190,
            child: PageView.builder(
              controller: _grandesClubesController,
              itemCount: todosJogos.length,
              itemBuilder: (context, index) {
                return _buildHorizontalGameCard(todosJogos[index], _grandesClubesController, index);
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  todosJogos.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _grandesClubesCurrentPage == index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _grandesClubesCurrentPage == index
                          ? const Color(0xFF007AFF)
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(3),
                    ),
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

    final itens = _todosJogosHoje.take(10).toList();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Ainda Hoje',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _jogosHojeController,
              itemCount: itens.length,
              itemBuilder: (context, index) {
                return _buildHorizontalGameCard(itens[index], _jogosHojeController, index);
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  itens.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _jogosHojeCurrentPage == index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _jogosHojeCurrentPage == index
                          ? const Color(0xFF007AFF)
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(3),
                    ),
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
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Notícias',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          if (_loadingNews)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          else if (_noticias.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Symbols.article_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma notícia disponível',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: List.generate(_noticias.take(10).length, (i) {
                final noticia = _noticias.take(10).toList()[i];
                final isLast = i == _noticias.take(10).length - 1;
                return _buildNewsItem(noticia, isLast);
              }),
            ),
        ],
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
                      color: const Color(0xFF007AFF).withOpacity(0.1),
                      child: noticia['imageUrl'] != null && noticia['imageUrl'].toString().isNotEmpty
                          ? CorsImage(
                              imageUrl: noticia['imageUrl'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorWidget: const Icon(
                                Symbols.article_rounded,
                                color: Color(0xFF007AFF),
                                size: 32,
                              ),
                            )
                          : const Icon(
                              Symbols.article_rounded,
                              color: Color(0xFF007AFF),
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          noticia['description'] ?? noticia['subtitle'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (noticia['date'] != null && (noticia['date'] as String).isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                noticia['subtitle']?.toString() ?? 'Fonte',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                ' · ${noticia['date']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
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
            color: Colors.grey.shade200,
          ),
      ],
    );
  }

  Widget _buildHorizontalGameCard(dynamic jogo, PageController controller, int index) {
    final statusRaw = (jogo['match_status']?.toString() ?? '');
    final statusLower = statusRaw.toLowerCase();
    final matchTime = jogo['match_time']?.toString() ?? '';

    final isNumeric = int.tryParse(statusRaw.replaceAll(RegExp(r'\D'), '')) != null && statusRaw.trim().isNotEmpty;
    final isLive = _isJogoAoVivo(jogo);
    final isHT = statusLower == 'ht' || statusLower == 'interval' || statusLower == 'ht.';
    final isFinished = statusLower.contains('finished') || statusLower == 'ft' || statusLower == 'aet' || statusLower == 'ap';
    final isNotStarted = statusLower.isEmpty || statusLower == 'ns' || statusLower.contains('not started') || matchTime.isNotEmpty;

    final homeYellowCards = int.tryParse(jogo['match_hometeam_yellow_cards']?.toString() ?? '0') ?? 0;
    final homeRedCards = int.tryParse(jogo['match_hometeam_red_cards']?.toString() ?? '0') ?? 0;
    final awayYellowCards = int.tryParse(jogo['match_awayteam_yellow_cards']?.toString() ?? '0') ?? 0;
    final awayRedCards = int.tryParse(jogo['match_awayteam_red_cards']?.toString() ?? '0') ?? 0;

    final homeScore = int.tryParse(jogo['match_hometeam_score']?.toString() ?? '0') ?? 0;
    final awayScore = int.tryParse(jogo['match_awayteam_score']?.toString() ?? '0') ?? 0;

    final possession = _extractPossession(jogo['statistics']);
    final homePercent = possession['home']!;
    final awayPercent = possession['away']!;
    final hasPossession = homePercent > 0 || awayPercent > 0;

    final homeWon = isFinished && homeScore > awayScore;
    final awayWon = isFinished && awayScore > homeScore;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value = 1.0;
        double scale = 1.0;

        if (controller.position.haveDimensions) {
          value = ((controller.page ?? controller.initialPage.toDouble()) - index).toDouble();
          scale = (1 - (value.abs() * 0.05)).clamp(0.95, 1.0);
        }

        return Center(
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header com badge ao vivo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isLive)
                    Row(
                      children: [
                        _BlinkingDot(),
                        const SizedBox(width: 6),
                        const Text(
                          'AO VIVO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.red,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                  else if (isNotStarted && matchTime.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Symbols.schedule_rounded,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          matchTime,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(),
                  if (isFinished)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'FINALIZADO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Placar e times
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CorsImage(
                              imageUrl: (jogo['team_home_badge'] ?? '').toString(),
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                              errorWidget: Icon(
                                Symbols.shield_rounded,
                                size: 44,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            if (homeWon)
                              Image.asset(
                                'assets/winner.gif',
                                width: 65,
                                height: 65,
                                errorBuilder: (_, __, ___) => const SizedBox(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          jogo['match_hometeam_name'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (homeYellowCards > 0 || homeRedCards > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (homeYellowCards > 0) ...[
                                Container(
                                  width: 13,
                                  height: 17,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$homeYellowCards',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                              ],
                              if (homeRedCards > 0)
                                Container(
                                  width: 13,
                                  height: 17,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$homeRedCards',
                                      style: const TextStyle(
                                        fontSize: 10,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          '$homeScore : $awayScore',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (!isNotStarted && !isFinished && !isHT)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusRaw,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF007AFF),
                              ),
                            ),
                          )
                        else if (isHT)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'INTERVALO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CorsImage(
                              imageUrl: (jogo['team_away_badge'] ?? '').toString(),
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                              errorWidget: Icon(
                                Symbols.shield_rounded,
                                size: 44,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            if (awayWon)
                              Image.asset(
                                'assets/winner.gif',
                                width: 65,
                                height: 65,
                                errorBuilder: (_, __, ___) => const SizedBox(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          jogo['match_awayteam_name'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (awayYellowCards > 0 || awayRedCards > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (awayYellowCards > 0) ...[
                                Container(
                                  width: 13,
                                  height: 17,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$awayYellowCards',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                              ],
                              if (awayRedCards > 0)
                                Container(
                                  width: 13,
                                  height: 17,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$awayRedCards',
                                      style: const TextStyle(
                                        fontSize: 10,
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
              if (hasPossession) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$homePercent%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: homePercent / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$awayPercent%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: awayPercent / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                              minHeight: 5,
                            ),
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
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}