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

      // Garantir que cada notícia é um Map<String, dynamic>
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

  Color _getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const Color(0xFF2C2C2E);
    }
    return const Color(0xFFF3F3F3);
  }

  // --- possession parsing helpers ---
  int _parseFirstInt(String input) {
    try {
      final match = RegExp(r'(\d{1,3})').firstMatch(input);
      if (match != null) {
        final v = int.tryParse(match.group(1) ?? '') ?? 0;
        return v.clamp(0, 100);
      }
    } catch (_) {}
    return 0;
  }

  /// Recebe estatísticas (pode ser List/Map/null) e tenta extrair posse (home/away).
  /// Retorna um Map {'home': int, 'away': int}.
  Map<String, int> _extractPossession(dynamic statistics) {
    int home = 0;
    int away = 0;

    try {
      if (statistics == null) {
        return {'home': 50, 'away': 50};
      }

      if (statistics is Map) {
        // procura chaves possíveis
        if (statistics.containsKey('possession')) {
          final val = statistics['possession'];
          if (val is Map) {
            home = _parseFirstInt(val['home']?.toString() ?? '');
            away = _parseFirstInt(val['away']?.toString() ?? '');
          } else {
            final s = val?.toString() ?? '';
            home = _parseFirstInt(s);
          }
        } else {
          // tentar varrer o map por um valor que contenha 'possession'
          for (var e in statistics.entries) {
            final k = e.key.toString().toLowerCase();
            if (k.contains('possession') || k.contains('ball')) {
              final entryVal = e.value;
              if (entryVal is Map) {
                home = _parseFirstInt(entryVal['home']?.toString() ?? '');
                away = _parseFirstInt(entryVal['away']?.toString() ?? '');
              } else {
                home = _parseFirstInt(entryVal?.toString() ?? '');
              }
              break;
            }
          }
        }
      } else if (statistics is List) {
        for (var stat in statistics) {
          if (stat == null) continue;
          if (stat is Map) {
            final type = (stat['type'] ?? stat['stat'] ?? '').toString().toLowerCase();
            if (type.contains('possession') || type.contains('ball')) {
              // APIs diferentes têm formatos diferentes: home/away ou single home value
              if (stat.containsKey('home') && stat.containsKey('away')) {
                home = _parseFirstInt(stat['home']?.toString() ?? '');
                away = _parseFirstInt(stat['away']?.toString() ?? '');
              } else if (stat.containsKey('value')) {
                final v = stat['value']?.toString() ?? '';
                home = _parseFirstInt(v);
              } else if (stat.containsKey('homeValue')) {
                home = _parseFirstInt(stat['homeValue']?.toString() ?? '');
                away = _parseFirstInt(stat['awayValue']?.toString() ?? '');
              } else {
                // tentar detectar em qualquer campo
                final combined = stat.values.map((v) => v?.toString() ?? '').join(' ');
                final m = RegExp(r'(\d{1,3})%?').allMatches(combined).toList();
                if (m.length >= 2) {
                  home = _parseFirstInt(m[0].group(1) ?? '');
                  away = _parseFirstInt(m[1].group(1) ?? '');
                } else if (m.length == 1) {
                  home = _parseFirstInt(m[0].group(1) ?? '');
                }
              }
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao extrair posse: $e');
    }

    // Sanitizar resultados e aplicar fallback
    home = home.clamp(0, 100);
    away = away.clamp(0, 100);

    if (home == 0 && away == 0) {
      // fallback: 50/50
      return {'home': 50, 'away': 50};
    } else if (home > 0 && away == 0) {
      away = (100 - home).clamp(0, 100);
    } else if (away > 0 && home == 0) {
      home = (100 - away).clamp(0, 100);
    } else {
      final sum = home + away;
      if (sum != 100 && sum > 0) {
        // normalizar proporcionalmente para garantir soma 100
        home = ((home / sum) * 100).round();
        away = 100 - home;
      }
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

    // Verifica se tem jogos ao vivo (mais robusto)
    final temJogosAoVivo = todosJogos.any((jogo) {
      final status = (jogo['match_status']?.toString() ?? '').toLowerCase();
      return RegExp(r"live|ht|1h|2h|'|\bminute\b|\b'\b").hasMatch(status) || int.tryParse(status.replaceAll(RegExp(r'\D'), '')) != null;
    });

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
                Row(
                  children: [
                    const Text(
                      'Grandes Clubes',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    if (temJogosAoVivo) ...[
                      const SizedBox(width: 12),
                      _BlinkingDot(),
                    ],
                  ],
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
            height: 170,
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
              'Hoje',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: PageView.builder(
              controller: _jogosHojeController,
              itemCount: itens.length,
              itemBuilder: (context, index) {
                return _buildHorizontalGameCard(itens[index], _jogosHojeController, index);
              },
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                itens.length,
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
    // Sempre mostra a seção de notícias
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
            // Render por índice para controlar isLast corretamente
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
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: noticia['imageUrl'] != null && noticia['imageUrl'].toString().isNotEmpty
                          ? CorsImage(
                              imageUrl: noticia['imageUrl'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorWidget: Icon(
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
                          noticia['description'] ?? noticia['subtitle'] ?? '',
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
                                noticia['subtitle']?.toString() ?? 'Fonte',
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
    final statusRaw = (jogo['match_status']?.toString() ?? '');
    final statusLower = statusRaw.toLowerCase();

    final isNumeric = int.tryParse(statusRaw.replaceAll(RegExp(r'\D'), '')) != null && statusRaw.trim().isNotEmpty;
    final isLive = RegExp(r"live|ht|1h|2h|'|\bminute\b", caseSensitive: false).hasMatch(statusLower) || isNumeric;
    final isHT = statusLower == 'ht' || statusLower == 'interval' || statusLower == 'ht.';
    final isFinished = statusLower.contains('finished') || statusLower == 'ft' || statusLower == 'aet' || statusLower == 'ap';
    final isNotStarted = statusLower.isEmpty || statusLower == 'ns' || statusLower.contains('not started');

    final homeYellowCards = int.tryParse(jogo['match_hometeam_yellow_cards']?.toString() ?? '0') ?? 0;
    final homeRedCards = int.tryParse(jogo['match_hometeam_red_cards']?.toString() ?? '0') ?? 0;
    final awayYellowCards = int.tryParse(jogo['match_awayteam_yellow_cards']?.toString() ?? '0') ?? 0;
    final awayRedCards = int.tryParse(jogo['match_awayteam_red_cards']?.toString() ?? '0') ?? 0;

    final homeScore = int.tryParse(jogo['match_hometeam_score']?.toString() ?? '0') ?? 0;
    final awayScore = int.tryParse(jogo['match_awayteam_score']?.toString() ?? '0') ?? 0;

    // extrair posse de forma robusta
    final possession = _extractPossession(jogo['statistics']);
    final homePercent = possession['home']!;
    final awayPercent = possession['away']!;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeWon = isFinished && homeScore > awayScore;
    final awayWon = isFinished && awayScore > homeScore;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value = 1.0;
        double scale = 1.0;

        if (controller.position.haveDimensions) {
          // CORREÇÃO LINHA 707: Converter para double explicitamente
          value = ((controller.page ?? controller.initialPage.toDouble()) - index).toDouble();
          scale = (1 - (value.abs() * 0.12)).clamp(0.88, 1.0);
        }

        final elevation = ((scale - 0.88) / (1 - 0.88)) * 8; // 0..8
        return Center(
          child: Transform.scale(
            scale: scale,
            child: Material(
              color: Colors.transparent,
              elevation: elevation,
              borderRadius: BorderRadius.circular(28),
              child: child,
            ),
          ),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _getCardColor(context),
            borderRadius: BorderRadius.circular(28),
            // sombra leve extra para quando Material elevation não for suficiente
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 3),
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
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // usa CorsImage para garantir que PNGs com CORS carreguem
                            CorsImage(
                              imageUrl: (jogo['team_home_badge'] ?? '').toString(),
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                              errorWidget: Icon(
                                Symbols.shield_rounded,
                                size: 48,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (homeWon)
                              Image.asset(
                                'assets/winner.gif',
                                width: 70,
                                height: 70,
                                errorBuilder: (_, __, ___) => const SizedBox(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          jogo['match_hometeam_name'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.green.shade500,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Casa',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (homeYellowCards > 0 || homeRedCards > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (homeYellowCards > 0) ...[
                                Container(
                                  width: 14,
                                  height: 18,
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
                                  width: 14,
                                  height: 18,
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
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text(
                        '$homeScore : $awayScore',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Ao Vivo',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isHT ? 'INT' : statusRaw,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isLive && !isHT
                                ? const Color(0xFF00C853)
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CorsImage(
                              imageUrl: (jogo['team_away_badge'] ?? '').toString(),
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                              errorWidget: Icon(
                                Symbols.shield_rounded,
                                size: 48,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (awayWon)
                              Image.asset(
                                'assets/winner.gif',
                                width: 70,
                                height: 70,
                                errorBuilder: (_, __, ___) => const SizedBox(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          jogo['match_awayteam_name'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade500,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Fora',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (awayYellowCards > 0 || awayRedCards > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (awayYellowCards > 0) ...[
                                Container(
                                  width: 14,
                                  height: 18,
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
                                  width: 14,
                                  height: 18,
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
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${homePercent}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          tween: Tween(begin: 0.0, end: homePercent / 100),
                          builder: (context, value, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: value.isNaN ? 0 : value,
                                backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? const Color(0xFF42A5F5) : const Color(0xFF1976D2),
                                ),
                                minHeight: 6,
                              ),
                            );
                          },
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
                          '${awayPercent}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          tween: Tween(begin: 0.0, end: awayPercent / 100),
                          builder: (context, value, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: value.isNaN ? 0 : value,
                                backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? const Color(0xFFFF7043) : const Color(0xFFFF6F00),
                                ),
                                minHeight: 6,
                              ),
                            );
                          },
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