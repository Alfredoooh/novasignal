import 'dart:ui';
import 'dart:math' show cos, sin, pi;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'search_page.dart';

class JogoDetalhesPage extends StatefulWidget {
  final String jogoId;

  const JogoDetalhesPage({super.key, required this.jogoId});

  @override
  State<JogoDetalhesPage> createState() => _JogoDetalhesPageState();
}

class _JogoDetalhesPageState extends State<JogoDetalhesPage> with TickerProviderStateMixin {
  Map<String, dynamic>? _jogo;
  bool _isLoading = true;
  late TabController _tabController;

  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _lineupHome = [];
  List<Map<String, dynamic>> _lineupAway = [];
  List<Map<String, dynamic>> _statistics = [];
  List<Map<String, dynamic>> _comentarios = [];
  int _cartoesAmareloCasa = 0;
  int _cartoesVermelhoCasa = 0;
  int _cartoesAmareloFora = 0;
  int _cartoesVermelhoFora = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    
    try {
      final dados = await context.read<AppState>().carregarJogoDetalhes(widget.jogoId);
      if (!mounted) return;
      
      setState(() {
        _jogo = dados;
        _isLoading = false;
      });
      _extractStructuredData();
    } catch (e) {
      debugPrint('Erro ao carregar detalhes do jogo: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      // Tentar novamente após 1 segundo
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _jogo == null) {
        _carregarDados();
      }
    }
  }

  void _extractStructuredData() {
    if (_jogo == null) return;

    final tmpEvents = <Map<String, dynamic>>[];

    // Extrair gols
    if (_jogo!['goalscorer'] != null && _jogo!['goalscorer'] is List) {
      for (var gol in _jogo!['goalscorer']) {
        tmpEvents.add({
          'type': 'goal',
          'time': int.tryParse(gol['time']?.toString() ?? '0') ?? 0,
          'player': gol['home_scorer'] ?? gol['away_scorer'] ?? '',
          'assist': gol['home_assist'] ?? gol['away_assist'] ?? '',
          'isHome': (gol['home_scorer'] != null && gol['home_scorer'].toString().isNotEmpty),
          'score': gol['score'] ?? '',
          'method': gol['info']?.toString() ?? '',
        });
      }
    }

    // Extrair cartões
    _cartoesAmareloCasa = 0;
    _cartoesVermelhoCasa = 0;
    _cartoesAmareloFora = 0;
    _cartoesVermelhoFora = 0;

    if (_jogo!['cards'] != null && _jogo!['cards'] is List) {
      for (var card in _jogo!['cards']) {
        final homeFault = card['home_fault']?.toString() ?? '';
        final awayFault = card['away_fault']?.toString() ?? '';
        final isHome = homeFault.isNotEmpty;
        final isYellow = card['card'] == 'yellow card';

        if (isHome) {
          if (isYellow) _cartoesAmareloCasa++;
          else _cartoesVermelhoCasa++;
        } else if (awayFault.isNotEmpty) {
          if (isYellow) _cartoesAmareloFora++;
          else _cartoesVermelhoFora++;
        }

        tmpEvents.add({
          'type': isYellow ? 'yellow' : 'red',
          'time': int.tryParse(card['time']?.toString() ?? '0') ?? 0,
          'player': isHome ? homeFault : awayFault,
          'isHome': isHome,
          'info': card['info']?.toString() ?? '',
        });
      }
    }

    // Extrair substituições
    if (_jogo!['substitutions'] != null && _jogo!['substitutions'] is List) {
      for (var sub in _jogo!['substitutions']) {
        final substitution = sub['substitution']?.toString() ?? '';
        final parts = substitution.split('|');
        tmpEvents.add({
          'type': 'substitution',
          'time': int.tryParse(sub['time']?.toString() ?? '0') ?? 0,
          'substitution': substitution,
          'playerOut': parts.isNotEmpty ? parts[0].trim() : '',
          'playerIn': parts.length > 1 ? parts[1].trim() : '',
          'isHome': (sub['home_scorer'] != null && sub['home_scorer'].toString().isNotEmpty),
        });
      }
    }

    tmpEvents.sort((a, b) => (a['time'] ?? 0).compareTo(b['time'] ?? 0));
    _events = tmpEvents;

    // Estatísticas
    final stats = _jogo!['statistics'];
    if (stats != null && stats is List) {
      final tmpStats = <Map<String, dynamic>>[];
      for (var s in stats) {
        if (s is Map) tmpStats.add(Map<String, dynamic>.from(s));
      }
      
      tmpStats.sort((a, b) {
        final aType = (a['type']?.toString() ?? '').toLowerCase();
        final bType = (b['type']?.toString() ?? '').toLowerCase();
        if (aType.contains('possession') || aType.contains('posse')) return -1;
        if (bType.contains('possession') || bType.contains('posse')) return 1;
        return 0;
      });
      
      _statistics = tmpStats;
    }

    // Lineup
    if (_jogo!['lineup'] != null && _jogo!['lineup'] is Map) {
      final lineup = _jogo!['lineup'] as Map;
      if (lineup['home'] != null && lineup['home']['starting_lineups'] is List) {
        _lineupHome = List<Map<String, dynamic>>.from(lineup['home']['starting_lineups']);
      }
      if (lineup['away'] != null && lineup['away']['starting_lineups'] is List) {
        _lineupAway = List<Map<String, dynamic>>.from(lineup['away']['starting_lineups']);
      }
    }

    // Comentários
    if (_jogo!['comments'] != null && _jogo!['comments'] is List) {
      _comentarios = List<Map<String, dynamic>>.from(_jogo!['comments']);
    }

    if (mounted) setState(() {});
  }

  String _translateStatType(String type) {
    final translations = {
      'Ball Possession': 'Posse de Bola',
      'Shots Total': 'Finalizações',
      'Shots On Goal': 'Finalizações no Gol',
      'Shots Off Goal': 'Finalizações para Fora',
      'Shots Blocked': 'Finalizações Bloqueadas',
      'Corner Kicks': 'Escanteios',
      'Offsides': 'Impedimentos',
      'Fouls': 'Faltas',
      'Yellow Cards': 'Cartões Amarelos',
      'Red Cards': 'Cartões Vermelhos',
      'Goalkeeper Saves': 'Defesas do Goleiro',
      'Total Passes': 'Passes Totais',
      'Passes Accurate': 'Passes Certos',
    };
    return translations[type] ?? type;
  }

  void _showBettingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBettingModal(),
    );
  }

  Widget _buildBettingModal() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Começar Aposta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Selecione suas opções de aposta',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Fechar',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return _buildLoadingScaffold(cs);
    }

    if (_jogo == null) {
      return Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(
          backgroundColor: cs.surface,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Detalhes', style: TextStyle(color: cs.onSurface)),
          elevation: 0,
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Symbols.error_rounded, size: 64, color: cs.error.withOpacity(0.8)),
            const SizedBox(height: 12),
            Text('Erro ao carregar detalhes', style: TextStyle(color: cs.onSurface)),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              stretch: true,
              backgroundColor: cs.surface,
              leading: IconButton(
                icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: innerScrolled
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_jogo!['team_home_badge'] != null)
                            Image.network(
                              _jogo!['team_home_badge'],
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 24, color: cs.onSurface),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_jogo!['team_away_badge'] != null)
                            Image.network(
                              _jogo!['team_away_badge'],
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 24, color: cs.onSurface),
                            ),
                        ],
                      )
                    : Text(
                        _jogo!['league_name'] ?? 'Liga',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                centerTitle: false,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [cs.primaryContainer, cs.surface],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Text(
                          _jogo!['league_name'] ?? '',
                          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      final query = _jogo!['match_hometeam_name'] ?? '';
                                      if (query.isNotEmpty) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => SearchPage(initialQuery: query),
                                          ),
                                        );
                                      }
                                    },
                                    child: (_jogo!['team_home_badge'] ?? '').toString().isNotEmpty
                                        ? Image.network(
                                            _jogo!['team_home_badge'],
                                            width: 64,
                                            height: 64,
                                            errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 64, color: cs.primary),
                                          )
                                        : Icon(Icons.shield, size: 64, color: cs.primary),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _jogo!['match_hometeam_name'] ?? '',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  Text(
                                    '${_jogo!['match_hometeam_score'] ?? '0'} - ${_jogo!['match_awayteam_score'] ?? '0'}',
                                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: cs.onSurface),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(_jogo!['match_status'] ?? '', context).withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      formatarStatus(_jogo!['match_status'] ?? ''),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: getStatusColor(_jogo!['match_status'] ?? '', context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      final query = _jogo!['match_awayteam_name'] ?? '';
                                      if (query.isNotEmpty) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => SearchPage(initialQuery: query),
                                          ),
                                        );
                                      }
                                    },
                                    child: (_jogo!['team_away_badge'] ?? '').toString().isNotEmpty
                                        ? Image.network(
                                            _jogo!['team_away_badge'],
                                            width: 64,
                                            height: 64,
                                            errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 64, color: cs.primary),
                                          )
                                        : Icon(Icons.shield, size: 64, color: cs.primary),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _jogo!['match_awayteam_name'] ?? '',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (_cartoesAmareloCasa > 0) ...[
                                    Container(
                                      width: 14,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow.shade700,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('$_cartoesAmareloCasa', style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                  ],
                                  if (_cartoesVermelhoCasa > 0) ...[
                                    Container(
                                      width: 14,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('$_cartoesVermelhoCasa', style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ],
                              ),
                              Row(
                                children: [
                                  if (_cartoesAmareloFora > 0) ...[
                                    Text('$_cartoesAmareloFora', style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 14,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow.shade700,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (_cartoesVermelhoFora > 0) ...[
                                    Text('$_cartoesVermelhoFora', style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 14,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('${_jogo!['match_date'] ?? ''} • ${_jogo!['match_time'] ?? ''}',
                            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: cs.surface,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: cs.primary,
                    unselectedLabelColor: cs.onSurfaceVariant,
                    indicatorColor: cs.primary,
                    indicatorWeight: 3,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Eventos'),
                      Tab(text: 'Formações'),
                      Tab(text: 'Comentários'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildEventosTab(),
            _buildFormacoesTab(),
            _buildComentariosTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.surfaceVariant)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _showBettingModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Começar Aposta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScaffold(ColorScheme cs) {
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detalhes', style: TextStyle(color: cs.onSurface)),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildGlassLoadingCard(cs),
      ),
    );
  }

  Widget _buildGlassLoadingCard(ColorScheme cs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cs.onSurface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        color: cs.onSurface.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventosTab() {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_statistics.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Symbols.bar_chart_rounded, color: cs.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Estatísticas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._statistics.take(5).map((s) => _buildStatRow(s, cs)),
              ],
            ),
          ),
        ],
        
        if (_events.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Nenhum evento disponível', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
          )
        else
          ..._events.map((e) => _buildEventCard(e, cs)),
      ],
    );
  }

  Widget _buildStatRow(Map<String, dynamic> s, ColorScheme cs) {
    final type = _translateStatType(s['type']?.toString() ?? 'Stat');
    final homeStr = s['home']?.toString().replaceAll('%', '') ?? '0';
    final awayStr = s['away']?.toString().replaceAll('%', '') ?? '0';

    final home = double.tryParse(homeStr) ?? 0;
    final away = double.tryParse(awayStr) ?? 0;

    final isPercentage = type.toLowerCase().contains('posse');
    final displayHome = isPercentage ? home : home.toInt();
    final displayAway = isPercentage ? away : away.toInt();
    final suffix = isPercentage ? '%' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$displayHome$suffix', style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
              Text(type, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              Text('$displayAway$suffix', style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  flex: home.toInt().clamp(1, 100),
                  child: Container(height: 6, color: cs.primary),
                ),
                Expanded(
                  flex: away.toInt().clamp(1, 100),
                  child: Container(height: 6, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> e, ColorScheme cs) {
    final type = (e['type'] ?? '').toString();
    final time = e['time']?.toString() ?? '';
    final isHome = e['isHome'] == true;
    final player = (e['player'] ?? '').toString();
    final assist = (e['assist'] ?? '').toString();
    final info = (e['info'] ?? '').toString();
    final method = (e['method'] ?? '').toString();

    Widget eventIcon;
    if (type == 'goal') {
      // Usar PNG de assets para bola
      eventIcon = Image.asset(
        'assets/icons/soccer_ball.png',
        width: 24,
        height: 24,
        errorBuilder: (_, __, ___) => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Symbols.sports_soccer_rounded, color: Colors.green, size: 16),
        ),
      );
    } else if (type == 'yellow') {
      eventIcon = Container(
        width: 14,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.yellow.shade700,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.shade900.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    } else if (type == 'red') {
      eventIcon = Container(
        width: 14,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade900.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    } else {
      // Substituição - ícone de setas circulares
      eventIcon = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(Symbols.sync_alt_rounded, color: cs.primary, size: 18),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isHome) ...[
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            fontSize: 15,
                          ),
                        ),
                  if (assist.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/assist.png',
                            width: 14,
                            height: 14,
                            errorBuilder: (_, __, ___) => Icon(
                              Symbols.sports_rounded,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              assist,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (method.isNotEmpty && method.toLowerCase().contains('var'))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/var.png',
                            width: 16,
                            height: 16,
                            errorBuilder: (_, __, ___) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'VAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              method,
                              style: TextStyle(
                                color: Colors.purple.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (method.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        method,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (type == 'substitution' && e['playerIn'] != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Symbols.arrow_upward_rounded, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            e['playerIn'],
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Symbols.arrow_downward_rounded, size: 14, color: Colors.red.shade400),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            e['playerOut'],
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            eventIcon,
          ] else
            const Expanded(child: SizedBox()),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$time'",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          if (!isHome) ...[
            eventIcon,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    player,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  if (assist.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              assist,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Image.asset(
                            'assets/icons/assist.png',
                            width: 14,
                            height: 14,
                            errorBuilder: (_, __, ___) => Icon(
                              Symbols.sports_rounded,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (method.isNotEmpty && method.toLowerCase().contains('var'))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              method,
                              style: TextStyle(
                                color: Colors.purple.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Image.asset(
                            'assets/icons/var.png',
                            width: 16,
                            height: 16,
                            errorBuilder: (_, __, ___) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'VAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (method.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        method,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  if (type == 'substitution' && e['playerIn'] != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            e['playerIn'],
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Symbols.arrow_upward_rounded, size: 14, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            e['playerOut'],
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Symbols.arrow_downward_rounded, size: 14, color: Colors.red.shade400),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ] else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildFormacoesTab() {
    final cs = Theme.of(context).colorScheme;

    if (_lineupHome.isEmpty && _lineupAway.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Formações não disponíveis',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if ((_jogo!['match_hometeam_system'] ?? '').toString().isNotEmpty ||
              (_jogo!['match_awayteam_system'] ?? '').toString().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Formações Táticas',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if ((_jogo!['match_hometeam_system'] ?? '').toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _jogo!['match_hometeam_name'] ?? '',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _jogo!['match_hometeam_system'],
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if ((_jogo!['match_awayteam_system'] ?? '').toString().isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _jogo!['match_awayteam_name'] ?? '',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _jogo!['match_awayteam_system'],
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_lineupHome.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (_jogo!['team_home_badge'] != null)
                        Image.network(
                          _jogo!['team_home_badge'],
                          width: 32,
                          height: 32,
                          errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 32, color: cs.primary),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        _jogo!['match_hometeam_name'] ?? 'Casa',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._lineupHome.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              p['lineup_number']?.toString() ?? '0',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['lineup_player']?.toString() ?? '-',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (p['lineup_position'] != null)
                                Text(
                                  p['lineup_position'].toString(),
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_lineupAway.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (_jogo!['team_away_badge'] != null)
                        Image.network(
                          _jogo!['team_away_badge'],
                          width: 32,
                          height: 32,
                          errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 32, color: Colors.green),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        _jogo!['match_awayteam_name'] ?? 'Fora',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._lineupAway.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              p['lineup_number']?.toString() ?? '0',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['lineup_player']?.toString() ?? '-',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (p['lineup_position'] != null)
                                Text(
                                  p['lineup_position'].toString(),
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComentariosTab() {
    final cs = Theme.of(context).colorScheme;

    if (_comentarios.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.article_rounded,
                size: 64,
                color: cs.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum comentário disponível',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _comentarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final comentario = _comentarios[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comentario['comment_minute'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${comentario['comment_minute']}'",
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                comentario['comment']?.toString() ?? '',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}