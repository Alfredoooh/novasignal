import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'jogo_detalhes_page.dart';
import 'home_config_page.dart';
import 'news_detail_page.dart';
import 'news_expanded_content.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  int _currentPage = 0;
  List<dynamic> _jogosHoje = [];
  List<dynamic> _jogosAmanha = [];
  List<dynamic> _jogosAoVivo = [];
  List<dynamic> _todosJogosHoje = [];
  String? _error;
  Timer? _autoRefreshTimer;
  List<Map<String, dynamic>> _noticias = [];
  bool _loadingNews = false;
  bool _showExpandedNews = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _scrollController.addListener(_onScroll);
    _loadTopMatches();
    _loadAllTodayMatches();
    _loadNews();
    _startAutoRefresh();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = maxScroll * 0.7;

      if (currentScroll > threshold && !_showExpandedNews) {
        setState(() {
          _showExpandedNews = true;
        });
      } else if (currentScroll < threshold * 0.5 && _showExpandedNews) {
        setState(() {
          _showExpandedNews = false;
          _tabController.animateTo(0);
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _loadTopMatches();
        _loadAllTodayMatches();
        _loadNews();
      }
    });
  }

  Future<void> _loadAllTodayMatches() async {
    if (!mounted) return;

    try {
      final appState = context.read<AppState>();
      
      // Carrega todos os jogos e filtra por data de hoje
      final todosJogos = await appState.carregarJogosDestaque([]);
      final hoje = DateTime.now();
      final dataHoje = '${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}';

      final jogosHoje = todosJogos.where((jogo) {
        return jogo['match_date'] == dataHoje;
      }).toList();

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

    setState(() {
      _error = null;
    });

    try {
      final appState = context.read<AppState>();
      final hoje = DateTime.now();
      final amanha = hoje.add(const Duration(days: 1));
      
      final dataHoje = '${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}';
      final dataAmanha = '${amanha.year}-${amanha.month.toString().padLeft(2, '0')}-${amanha.day.toString().padLeft(2, '0')}';

      final todosJogos = await appState.carregarJogosDestaque(appState.topClubs);

      if (!mounted) return;

      // Filtra jogos de hoje
      final jogosHoje = todosJogos.where((jogo) {
        return jogo['match_date'] == dataHoje;
      }).toList();

      // Filtra jogos de amanhã
      final jogosAmanha = todosJogos.where((jogo) {
        return jogo['match_date'] == dataAmanha;
      }).toList();

      final liveMatches = jogosHoje.where((jogo) {
        final status = jogo['match_status'] ?? '';
        final isNumeric = int.tryParse(status.toString()) != null;
        return isNumeric || status.contains("'") || status == 'HT' || status == 'LIVE' || status == '1H' || status == '2H';
      }).toList();

      setState(() {
        _jogosHoje = jogosHoje;
        _jogosAmanha = jogosAmanha;
        _jogosAoVivo = liveMatches;
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_showExpandedNews) {
      return _buildExpandedView();
    }

    return _buildCollapsedView();
  }

  Widget _buildExpandedView() {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              pinned: true,
              floating: true,
              snap: false,
              expandedHeight: 0,
              forceElevated: innerBoxIsScrolled,
              automaticallyImplyLeading: false,
              title: const Text(
                'Atualidades',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Symbols.close_rounded),
                  onPressed: () {
                    setState(() {
                      _showExpandedNews = false;
                    });
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: const [
                  Tab(text: 'Todas'),
                  Tab(text: 'Categorias'),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          NewsExpandedContent(noticias: _noticias),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.category_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Categorias em breve',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedView() {
    final temGrandesClubes = _jogosHoje.isNotEmpty || _jogosAmanha.isNotEmpty;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (temGrandesClubes) ...[
          SliverToBoxAdapter(
            child: Column(
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
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _jogosHoje.length + (_jogosAmanha.isEmpty ? 0 : _jogosAmanha.length + 1),
                itemBuilder: (context, index) {
                  if (index < _jogosHoje.length) {
                    return _buildAppleSportsCard(_jogosHoje[index], index);
                  } else if (index == _jogosHoje.length && _jogosAmanha.isNotEmpty) {
                    return _buildDividerCard();
                  } else {
                    final amanhaIndex = index - _jogosHoje.length - 1;
                    return _buildAppleSportsCard(_jogosAmanha[amanhaIndex], index);
                  }
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _jogosHoje.length + (_jogosAmanha.isEmpty ? 0 : _jogosAmanha.length + 1),
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
            ),
          ),
          if (_jogosAoVivo.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverToBoxAdapter(
              child: Padding(
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
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildLiveMatchCard(_jogosAoVivo[index]),
                childCount: _jogosAoVivo.length,
              ),
            ),
          ],
        ],
        
        if (!temGrandesClubes && _todosJogosHoje.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildMatchCard(_todosJogosHoje[index]),
              childCount: _todosJogosHoje.take(10).length,
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Atualidades',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Icon(
                  Symbols.expand_less_rounded,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        
        if (_loadingNews)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          )
        else if (_noticias.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Symbols.article_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma notícia disponível',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final noticia = _noticias[index];
                return Column(
                  children: [
                    if (index > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    _buildNewsItem(noticia),
                  ],
                );
              },
              childCount: _noticias.take(3).length,
            ),
          ),
          if (_noticias.length > 3)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Deslize para cima para ver mais',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildDividerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.arrow_forward_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Agora estarás vendo os',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Jogos dos Gigantes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Amanhã',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    final isNumeric = int.tryParse(status.toString()) != null;
    final isLive = isNumeric || status.contains("'") || status == 'HT' || status == 'LIVE' || status == '1H' || status == '2H';
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLive 
                ? Colors.red 
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isLive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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

  Widget _buildNewsItem(Map<String, dynamic> noticia) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => _openNewsDetail(noticia),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Symbols.article_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      noticia['subtitle'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                    if (noticia['date'] != null && (noticia['date'] as String).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        noticia['date'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: isLive 
                ? Border.all(color: Colors.red, width: 2) 
                : Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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