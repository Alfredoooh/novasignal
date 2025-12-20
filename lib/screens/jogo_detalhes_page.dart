import 'dart:ui';
import 'dart:math' show cos, sin, pi;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'jogo_detalhes_page.dart'; // caso haja referências cruzadas

class JogoDetalhesPage extends StatefulWidget {
  final String jogoId;

  const JogoDetalhesPage({super.key, required this.jogoId});

  @override
  State<JogoDetalhesPage> createState() => _JogoDetalhesPageState();
}

class _JogoDetalhesPageState extends State<JogoDetalhesPage> with TickerProviderStateMixin {
  Map<String, dynamic>? _jogo;
  bool _isLoading = true;
  late AnimationController _loadingController;
  late TabController _tabController;

  // caches locais
  List<Map<String, dynamic>> _events = [];
  Map<String, double>? _probabilidades; // home, draw, away se existirem
  List<Map<String, dynamic>> _lineupHome = [];
  List<Map<String, dynamic>> _lineupAway = [];

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _tabController = TabController(length: 4, vsync: this);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final dados = await context.read<AppState>().carregarJogoDetalhes(widget.jogoId);
      if (mounted) {
        setState(() {
          _jogo = dados;
          _isLoading = false;
        });
        _extractStructuredData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _extractStructuredData() {
    // extrai eventos reais do payload (_jogo) — procura por várias chaves comuns
    if (_jogo == null) return;

    final tmpEvents = <Map<String, dynamic>>[];

    // 1) se existir 'events' já estruturado, usa
    if (_jogo!['events'] != null && _jogo!['events'] is List) {
      for (var e in _jogo!['events'] as List) {
        tmpEvents.add(Map<String, dynamic>.from(e));
      }
    } else {
      // tenta montar a partir de goals/cards/substitutions (como no teu código anterior)
      if (_jogo!['goalscorer'] != null && _jogo!['goalscorer'] is List) {
        for (var gol in _jogo!['goalscorer']) {
          tmpEvents.add({
            'type': 'goal',
            'time': int.tryParse(gol['time']?.toString() ?? '0') ?? 0,
            'player': gol['home_scorer'] ?? gol['away_scorer'] ?? '',
            'assist': gol['home_assist'] ?? gol['away_assist'] ?? '',
            'isHome': (gol['home_scorer'] != null && gol['home_scorer'].toString().isNotEmpty),
            'score': gol['score'] ?? '',
            'raw': gol,
          });
        }
      }

      if (_jogo!['cards'] != null && _jogo!['cards'] is List) {
        for (var card in _jogo!['cards']) {
          tmpEvents.add({
            'type': (card['card'] == 'yellow card' ? 'yellow' : 'red'),
            'time': int.tryParse(card['time']?.toString() ?? '0') ?? 0,
            'player': card['home_fault'] ?? card['away_fault'] ?? '',
            'isHome': (card['home_fault'] != null && card['home_fault'].toString().isNotEmpty),
            'raw': card,
          });
        }
      }

      if (_jogo!['substitutions'] != null && _jogo!['substitutions'] is List) {
        for (var sub in _jogo!['substitutions']) {
          final substitution = sub['substitution']?.toString() ?? '';
          final parts = substitution.split('|');
          tmpEvents.add({
            'type': 'substitution',
            'time': int.tryParse(sub['time']?.toString() ?? '0') ?? 0,
            'playerOut': parts.isNotEmpty ? parts[0].trim() : '',
            'playerIn': parts.length > 1 ? parts[1].trim() : '',
            'isHome': (sub['home_scorer'] != null && sub['home_scorer'].toString().isNotEmpty),
            'raw': sub,
          });
        }
      }
    }

    // ordena por tempo (se existir)
    tmpEvents.sort((a, b) {
      final ta = (a['time'] ?? 0) as int;
      final tb = (b['time'] ?? 0) as int;
      return ta.compareTo(tb);
    });
    _events = tmpEvents;

    // probabilidades: tenta ler campos frequentemente usados ou 'odds'
    Map<String, double>? probs;
    if (_jogo!['home_win_prob'] != null && _jogo!['away_win_prob'] != null) {
      final h = double.tryParse(_jogo!['home_win_prob'].toString()) ?? 0.0;
      final a = double.tryParse(_jogo!['away_win_prob'].toString()) ?? 0.0;
      final d = double.tryParse(_jogo!['draw_prob']?.toString() ?? '0') ?? 0.0;
      probs = {'home': h, 'draw': d, 'away': a};
    } else if (_jogo!['odds'] != null && _jogo!['odds'] is Map) {
      // odds -> converte em prob = 1/odds (se odds estiverem no formato decimal)
      final o = Map<String, dynamic>.from(_jogo!['odds']);
      double? oh = _tryParseDouble(o['home']);
      double? od = _tryParseDouble(o['draw']);
      double? oa = _tryParseDouble(o['away']);
      if (oh != null && oa != null) {
        // normaliza para percentagens (apenas se ao menos home e away existirem)
        final invH = oh > 0 ? 1.0 / oh : 0.0;
        final invD = (od ?? 0) > 0 ? 1.0 / (od ?? 1) : 0.0;
        final invA = oa > 0 ? 1.0 / oa : 0.0;
        final sum = invH + invD + invA;
        if (sum > 0) {
          probs = {
            'home': (invH / sum) * 100,
            'draw': (invD / sum) * 100,
            'away': (invA / sum) * 100,
          };
        }
      }
    } else {
      // tenta derivar a partir do 'team_home_form' / 'team_away_form' (cadeia tipo "WDLWW")
      final formH = _jogo!['team_home_form']?.toString();
      final formA = _jogo!['team_away_form']?.toString();
      if (formH != null || formA != null) {
        final hScore = _calcFormScore(formH);
        final aScore = _calcFormScore(formA);
        final drawScore = 3.0;
        final sum = hScore + aScore + drawScore;
        if (sum > 0) {
          probs = {
            'home': (hScore / sum) * 100,
            'draw': (drawScore / sum) * 100,
            'away': (aScore / sum) * 100,
          };
        }
      }
    }
    _probabilidades = probs;

    // lineups: tenta ler chaves comuns
    if (_jogo!['lineup_home'] != null && _jogo!['lineup_home'] is List) {
      _lineupHome = List<Map<String, dynamic>>.from(_jogo!['lineup_home']);
    } else if (_jogo!['home_lineup'] != null && _jogo!['home_lineup'] is List) {
      _lineupHome = List<Map<String, dynamic>>.from(_jogo!['home_lineup']);
    }

    if (_jogo!['lineup_away'] != null && _jogo!['lineup_away'] is List) {
      _lineupAway = List<Map<String, dynamic>>.from(_jogo!['lineup_away']);
    } else if (_jogo!['away_lineup'] != null && _jogo!['away_lineup'] is List) {
      _lineupAway = List<Map<String, dynamic>>.from(_jogo!['away_lineup']);
    }

    // força rebuild
    if (mounted) setState(() {});
  }

  double _calcFormScore(String? form) {
    if (form == null) return 0.0;
    // simples heurística: W=3, D=1, L=0 por carácter
    double score = 0;
    for (var ch in form.split('')) {
      if (ch.toUpperCase() == 'W') score += 3;
      if (ch.toUpperCase() == 'D') score += 1;
    }
    return score;
  }

  double? _tryParseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    final s = v.toString().replaceAll(',', '.');
    return double.tryParse(s);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loadingController.dispose();
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

    // header data
    final leagueName = _jogo!['league_name']?.toString() ?? '';
    final leagueLogo = _jogo!['league_logo']?.toString() ?? '';

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
              actions: [
                IconButton(icon: Icon(Symbols.share_rounded, color: cs.onSurface), onPressed: () {}),
                IconButton(icon: Icon(Symbols.star_outline_rounded, color: cs.onSurface), onPressed: () {}),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  leagueName.isNotEmpty ? leagueName : (_jogo!['league']?.toString() ?? 'Liga'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                centerTitle: false,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      // "tom Jader" -> usa primaryContainer -> primary contrast
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
                            // home team
                            Expanded(
                              child: Column(
                                children: [
                                  if ((_jogo!['team_home_badge'] ?? '').toString().isNotEmpty)
                                    Image.network(
                                      _jogo!['team_home_badge'],
                                      width: 64,
                                      height: 64,
                                      errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 64, color: cs.primary),
                                    )
                                  else
                                    Icon(Icons.shield, size: 64, color: cs.primary),
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

                            // score
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
                                      color: (_jogo!['match_status']?.toString().contains("LIVE") ?? false)
                                          ? cs.error.withOpacity(0.14)
                                          : cs.surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      formatarStatus(_jogo!['match_status'] ?? ''),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: (_jogo!['match_status']?.toString().contains("LIVE") ?? false)
                                            ? cs.error
                                            : cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // away team
                            Expanded(
                              child: Column(
                                children: [
                                  if ((_jogo!['team_away_badge'] ?? '').toString().isNotEmpty)
                                    Image.network(
                                      _jogo!['team_away_badge'],
                                      width: 64,
                                      height: 64,
                                      errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 64, color: cs.primary),
                                    )
                                  else
                                    Icon(Icons.shield, size: 64, color: cs.primary),
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
                        const SizedBox(height: 16),
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
                    tabs: const [
                      Tab(text: 'Eventos'),
                      Tab(text: 'Pré-via'),
                      Tab(text: 'Formações'),
                      Tab(text: 'Estatísticas'),
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
            _buildPreviaTab(),
            _buildFormacoesTab(),
            _buildEstatisticasTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cs.surface, border: Border(top: BorderSide(color: cs.surfaceVariant))),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Começar Aposta', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: cs.onPrimary)),
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
        leading: IconButton(icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
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
      child: Stack(
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [cs.surface.withOpacity(0.6), cs.surfaceVariant.withOpacity(0.35)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.onSurface.withOpacity(0.06)),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 130,
              padding: const EdgeInsets.all(14),
              color: Colors.transparent,
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: AnimatedBuilder(
                      animation: _loadingController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _ExpressiveProgressPainter(progress: _loadingController.value, color: cs.primary),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.06), borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 8),
                      Container(height: 10, width: MediaQuery.of(context).size.width * 0.5, decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.05), borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 8),
                      Container(height: 8, width: MediaQuery.of(context).size.width * 0.3, decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.04), borderRadius: BorderRadius.circular(6))),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tabs ----------

  Widget _buildEventosTab() {
    final cs = Theme.of(context).colorScheme;
    if (_events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Nenhum evento disponível', style: TextStyle(color: cs.onSurfaceVariant)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final e = _events[idx];
        final type = (e['type'] ?? '').toString();
        final time = e['time']?.toString() ?? '';
        final isHome = e['isHome'] == true;
        final title = (e['player'] ?? e['playerIn'] ?? e['playerOut'] ?? '').toString();
        final subtitleParts = <String>[];
        if (e['assist'] != null && e['assist'].toString().isNotEmpty) subtitleParts.add('Assistência: ${e['assist']}');
        if (e['score'] != null && e['score'].toString().isNotEmpty) subtitleParts.add('Placar: ${e['score']}');
        final subtitle = subtitleParts.join(' • ');

        Color cardColor;
        Widget leading;
        if (type == 'goal') {
          cardColor = Colors.green.withOpacity(0.08);
          leading = Icon(Symbols.sports_soccer_rounded, color: Colors.green, size: 28);
        } else if (type == 'yellow') {
          cardColor = Colors.yellow.withOpacity(0.08);
          leading = Container(width: 28, height: 20, decoration: BoxDecoration(color: Colors.yellow.shade600, borderRadius: BorderRadius.circular(3)));
        } else if (type == 'red') {
          cardColor = Colors.red.withOpacity(0.08);
          leading = Container(width: 28, height: 20, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(3)));
        } else {
          cardColor = Theme.of(context).colorScheme.surfaceVariant;
          leading = Icon(Symbols.swap_horiz_rounded, color: Theme.of(context).colorScheme.primary);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: cardColor,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(width: 52, child: Center(child: leading)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface))),
                        Text(time.isNotEmpty ? "$time'" : '', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (subtitle.isNotEmpty) const SizedBox(height: 6),
                    if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                    if (e['raw'] != null) const SizedBox(height: 6),
                    if (e['raw'] != null)
                      Text('Fonte: raw', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviaTab() {
    final cs = Theme.of(context).colorScheme;

    // mostra probabilidades reais se existirem
    if (_probabilidades != null) {
      final home = _probabilidades!['home'] ?? 0.0;
      final draw = _probabilidades!['draw'] ?? 0.0;
      final away = _probabilidades!['away'] ?? 0.0;

      final winner = home > away ? (_jogo!['match_hometeam_name'] ?? 'Casa') : (_jogo!['match_awayteam_name'] ?? 'Fora');

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Pré-via (probabilidades)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
                  Text('Favorito: $winner', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 12),
                _probBar('Casa', home, Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                _probBar('Empate', draw, Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 8),
                _probBar('Fora', away, const Color(0xFF34C759)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Fonte: dados do jogo', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                  Text('Últ. atualização: ${_jogo!['last_update'] ?? '-'}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            // previsões detalhadas (se existir)
            if (_jogo!['prediction'] != null)
              Container(
                decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
                child: Text(_jogo!['prediction'].toString(), style: TextStyle(color: cs.onSurface)),
              ),
            if (_jogo!['prediction'] == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Sem previsão textual disponível', style: TextStyle(color: cs.onSurfaceVariant)),
              ),
          ],
        ),
      );
    }

    // se não existirem probabilidades, tenta exibir indicadores reais presentes (odds etc.)
    if (_jogo!['odds'] != null || _jogo!['bookmakers'] != null) {
      // mostra rácio de odds se existir
      final odds = _jogo!['odds'] ?? _jogo!['bookmakers'];
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text('Odds / Bookmakers (dados disponíveis)', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(odds.toString(), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            ]),
          ),
        ]),
      );
    }

    // fallback: tentar derivar com base na forma (sem inventar)
    final formH = _jogo!['team_home_form']?.toString();
    final formA = _jogo!['team_away_form']?.toString();
    if ((formH ?? '').isNotEmpty || (formA ?? '').isNotEmpty) {
      final hScore = _calcFormScore(formH);
      final aScore = _calcFormScore(formA);
      final total = hScore + aScore + 3.0;
      final homePct = total > 0 ? (hScore / total) * 100 : 0.0;
      final drawPct = total > 0 ? (3.0 / total) * 100 : 0.0;
      final awayPct = total > 0 ? (aScore / total) * 100 : 0.0;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text('Pré-via derivada a partir da forma recente', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _probBar('Casa', homePct, cs.primary),
              const SizedBox(height: 8),
              _probBar('Empate', drawPct, cs.onSurfaceVariant),
              const SizedBox(height: 8),
              _probBar('Fora', awayPct, const Color(0xFF34C759)),
              const SizedBox(height: 8),
              Text('Dados derivados das strings: home_form="$formH", away_form="$formA"', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ]),
          ),
        ]),
      );
    }

    // sem dados reais disponíveis
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Sem dados de pré-via (odds / probabilidades) disponíveis para este jogo', style: TextStyle(color: cs.onSurfaceVariant)),
      ),
    );
  }

  Widget _probBar(String label, double percent, Color color) {
    final cs = Theme.of(context).colorScheme;
    final p = percent.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: cs.onSurface)), Text('${p.toStringAsFixed(1)}%', style: TextStyle(color: cs.onSurface))]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 10,
            color: cs.surfaceVariant,
            child: FractionallySizedBox(
              widthFactor: p / 100,
              alignment: Alignment.centerLeft,
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormacoesTab() {
    final cs = Theme.of(context).colorScheme;

    if (_lineupHome.isEmpty && _lineupAway.isEmpty) {
      // tenta procurar pela estrutura antiga do teu payload (players em match_home_players etc)
      final homePlayers = _jogo!['match_hometeam_players'] ?? _jogo!['home_players'];
      final awayPlayers = _jogo!['match_awayteam_players'] ?? _jogo!['away_players'];

      if ((homePlayers is List && homePlayers.isNotEmpty) || (awayPlayers is List && awayPlayers.isNotEmpty)) {
        final homeList = (homePlayers is List) ? List<Map<String, dynamic>>.from(homePlayers.map((p) => p is Map ? Map<String, dynamic>.from(p) : {'name': p.toString()})) : <Map<String, dynamic>>[];
        final awayList = (awayPlayers is List) ? List<Map<String, dynamic>>.from(awayPlayers.map((p) => p is Map ? Map<String, dynamic>.from(p) : {'name': p.toString()})) : <Map<String, dynamic>>[];
        _lineupHome = homeList;
        _lineupAway = awayList;
      }
    }

    if (_lineupHome.isEmpty && _lineupAway.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Formações não disponíveis', style: TextStyle(color: cs.onSurfaceVariant))));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Container(
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Text('Formação — ${_jogo!['match_hometeam_name'] ?? 'Casa'}', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ..._lineupHome.map((p) => ListTile(leading: const Icon(Icons.person), title: Text(p['name']?.toString() ?? p['player']?.toString() ?? '-', style: TextStyle(color: cs.onSurface)), subtitle: p['position'] != null ? Text(p['position'].toString(), style: TextStyle(color: cs.onSurfaceVariant)) : null)),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Text('Formação — ${_jogo!['match_awayteam_name'] ?? 'Fora'}', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ..._lineupAway.map((p) => ListTile(leading: const Icon(Icons.person_outline), title: Text(p['name']?.toString() ?? p['player']?.toString() ?? '-', style: TextStyle(color: cs.onSurface)), subtitle: p['position'] != null ? Text(p['position'].toString(), style: TextStyle(color: cs.onSurfaceVariant)) : null)),
          ]),
        ),
        const SizedBox(height: 16),
        // Se houver formação em string (ex: "4-3-3"), mostramos um preview visual básico (não inventa jogadores)
        if ((_jogo!['match_hometeam_system'] ?? '').toString().isNotEmpty || (_jogo!['match_awayteam_system'] ?? '').toString().isNotEmpty)
          Column(children: [
            const SizedBox(height: 8),
            Text('Formações táticas', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _buildFormationPreview((_jogo!['match_hometeam_system'] ?? '4-4-2').toString(), true),
            const SizedBox(height: 12),
            _buildFormationPreview((_jogo!['match_awayteam_system'] ?? '4-4-2').toString(), false),
          ]),
      ]),
    );
  }

  Widget _buildFormationPreview(String formation, bool isHome) {
    final parts = formation.split('-').map((s) => int.tryParse(s) ?? 1).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).colorScheme.surface),
      child: Column(children: parts.reversed.map((count) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(count, (i) {
            return CircleAvatar(radius: 16, backgroundColor: isHome ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)));
          })),
        );
      }).toList()),
    );
  }

  Widget _buildEstatisticasTab() {
    final cs = Theme.of(context).colorScheme;
    final stats = _jogo!['statistics'] ?? _jogo!['stats'];
    if (stats == null || (stats is List && stats.isEmpty)) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Estatísticas não disponíveis', style: TextStyle(color: cs.onSurfaceVariant))));
    }

    // se stats for List de maps
    final List<Map<String, dynamic>> statList = [];
    if (stats is List) {
      for (var s in stats) {
        if (s is Map) statList.add(Map<String, dynamic>.from(s));
      }
    } else if (stats is Map) {
      statList.addAll((stats as Map).entries.map((e) => {'type': e.key, 'home': e.value['home'] ?? e.value[0], 'away': e.value['away'] ?? e.value[1]}));
    }

    // fallback: tenta calcular a partir de jogos passados cacheados se existirem (não inventa)
    if (statList.isEmpty && _jogo!['past_matches'] != null && _jogo!['past_matches'] is List) {
      // não preenche estatísticas inventadas — apenas avisa
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Existem dados históricos — tratar cálculo separado', style: TextStyle(color: cs.onSurfaceVariant))));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: statList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final s = statList[idx];
        final type = s['type']?.toString() ?? 'Stat';
        final home = double.tryParse(s['home']?.toString().replaceAll('%', '') ?? '0') ?? 0;
        final away = double.tryParse(s['away']?.toString().replaceAll('%', '') ?? '0') ?? 0;
        final total = (home + away) > 0 ? (home + away) : 1;
        final homePct = (home / total) * 100;
        final awayPct = (away / total) * 100;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(type, style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)), Text('${home.toInt()} - ${away.toInt()}', style: TextStyle(color: cs.onSurfaceVariant))]),
            const SizedBox(height: 8),
            _probBar('Casa', homePct, cs.primary),
            const SizedBox(height: 6),
            _probBar('Fora', awayPct, const Color(0xFF34C759)),
          ]),
        );
      },
    );
  }
}

// ---------- Reused painters (loader/pie/field) ----------

class _ExpressiveProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ExpressiveProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 3.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final path = Path();
    final phase = (progress * 3) % 3;

    double startAngle = -pi / 2 + (progress * 2 * pi);
    double sweepAngle;

    if (phase < 1) {
      sweepAngle = phase * pi * 1.5;
    } else if (phase < 2) {
      sweepAngle = pi * 1.5;
      startAngle += (phase - 1) * pi * 2;
    } else {
      sweepAngle = (3 - phase) * pi * 1.5;
      startAngle += pi * 2;
    }

    final segments = 60;
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final angle = startAngle + (sweepAngle * t);
      final wave = sin(angle * 3 + progress * pi * 4) * 2;
      final r = radius + wave;

      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final rect = Rect.fromCircle(center: center, radius: radius);
    paint.shader = SweepGradient(
      colors: [color.withOpacity(0.2), color, color, color.withOpacity(0.2)],
      stops: const [0.0, 0.3, 0.7, 1.0],
      transform: GradientRotation(startAngle),
    ).createShader(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ExpressiveProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _PieChartPainter extends CustomPainter {
  final double homeValue;
  final double awayValue;
  final Color homeColor;
  final Color awayColor;
  final Color backgroundColor;

  _PieChartPainter({
    required this.homeValue,
    required this.awayValue,
    required this.homeColor,
    required this.awayColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final total = homeValue + awayValue;

    if (total == 0) return;

    final homeSweep = (homeValue / total) * 2 * pi;

    final homePaint = Paint()..color = homeColor..style = PaintingStyle.fill;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, homeSweep, true, homePaint);

    final awayPaint = Paint()..color = awayColor..style = PaintingStyle.fill;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2 + homeSweep, 2 * pi - homeSweep, true, awayPaint);

    final centerPaint = Paint()..color = backgroundColor..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.65, centerPaint);
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) => true;
}

class _FootballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 2..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, 50, paint);
    canvas.drawCircle(center, 2, Paint()..color = Colors.white);

    final areaWidth = size.width * 0.6;
    final areaHeight = size.height * 0.15;

    canvas.drawRect(Rect.fromCenter(center: Offset(size.width / 2, areaHeight / 2), width: areaWidth, height: areaHeight), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(size.width / 2, size.height - areaHeight / 2), width: areaWidth, height: areaHeight), paint);

    final smallAreaWidth = size.width * 0.35;
    final smallAreaHeight = size.height * 0.08;

    canvas.drawRect(Rect.fromCenter(center: Offset(size.width / 2, smallAreaHeight / 2), width: smallAreaWidth, height: smallAreaHeight), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(size.width / 2, size.height - smallAreaHeight / 2), width: smallAreaWidth, height: smallAreaHeight), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}