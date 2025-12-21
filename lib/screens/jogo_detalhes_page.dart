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
  Map<String, double>? _probabilidades;
  List<Map<String, dynamic>> _lineupHome = [];
  List<Map<String, dynamic>> _lineupAway = [];
  int _cartoesAmareloCasa = 0;
  int _cartoesVermelhoCasa = 0;
  int _cartoesAmareloFora = 0;
  int _cartoesVermelhoFora = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        });
      }
    }

    // Extrair cartões e contar corretamente
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

    if (mounted) setState(() {});
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
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Conteúdo do modal
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
                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Confirmar'),
                          ),
                        ),
                      ],
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
                title: Text(
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
                            // Casa
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

                            // Placar
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

                            // Fora
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
                        // Cartões nas laterais
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Cartões Casa
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
                              // Cartões Fora
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
                      Tab(text: 'Odds'),
                      Tab(text: 'Formações'),
                      Tab(text: 'Estatísticas'),
                      Tab(text: 'Notícias'),
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
            _buildOddsTab(),
            _buildFormacoesTab(),
            _buildEstatisticasTab(),
            _buildNoticiasTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cs.surface, border: Border(top: BorderSide(color: cs.surfaceVariant))),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _showBettingModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.06), borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 8),
                  Container(height: 10, width: MediaQuery.of(context).size.width * 0.5, decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.05), borderRadius: BorderRadius.circular(6))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        final player = (e['player'] ?? '').toString();
        final assist = (e['assist'] ?? '').toString();
        final info = (e['info'] ?? '').toString();

        Widget eventIcon;
        if (type == 'goal') {
          eventIcon = Icon(Symbols.sports_soccer_rounded, color: Colors.green, size: 20);
        } else if (type == 'yellow') {
          eventIcon = Container(width: 14, height: 20, decoration: BoxDecoration(color: Colors.yellow.shade700, borderRadius: BorderRadius.circular(2)));
        } else if (type == 'red') {
          eventIcon = Container(width: 14, height: 20, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2)));
        } else {
          eventIcon = Icon(Symbols.swap_horiz_rounded, color: cs.primary, size: 20);
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lado esquerdo (casa)
              if (isHome)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(player, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface, fontSize: 14)),
                      if (assist.isNotEmpty) Text('Assist: $assist', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                      if (info.isNotEmpty) Text(info, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                      if (type == 'substitution' && e['playerIn'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Symbols.arrow_upward_rounded, size: 12, color: Colors.green),
                                const SizedBox(width: 4),
                                Expanded(child: Text(e['playerIn'], style: TextStyle(color: Colors.green, fontSize: 11))),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Symbols.arrow_downward_rounded, size: 12, color: Colors.red),
                                const SizedBox(width: 4),
                                Expanded(child: Text(e['playerOut'], style: TextStyle(color: Colors.red, fontSize: 11))),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              else
                const Expanded(child: SizedBox()),

              // Minuto e ícone (sem container)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("$time'", style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(width: 12),
                    eventIcon,
                  ],
                ),
              ),

              // Lado direito (fora)
              if (!isHome)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (type == 'yellow' || type == 'red') ...[
                        Text(player, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface, fontSize: 14), textAlign: TextAlign.right),
                        if (info.isNotEmpty) Text(info, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11), textAlign: TextAlign.right),
                      ] else if (type == 'goal') ...[
                        Text(player, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface, fontSize: 14), textAlign: TextAlign.right),
                        if (assist.isNotEmpty) Text('Assist: $assist', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11), textAlign: TextAlign.right),
                      ] else if (type == 'substitution' && e['playerIn'] != null) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(child: Text(e['playerIn'], style: TextStyle(color: Colors.green, fontSize: 11), textAlign: TextAlign.right)),
                                const SizedBox(width: 4),
                                Icon(Symbols.arrow_upward_rounded, size: 12, color: Colors.green),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(child: Text(e['playerOut'], style: TextStyle(color: Colors.red, fontSize: 11), textAlign: TextAlign.right)),
                                const SizedBox(width: 4),
                                Icon(Symbols.arrow_downward_rounded, size: 12, color: Colors.red),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOddsTab() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Odds em breve', style: TextStyle(color: cs.onSurfaceVariant)),
      ),
    );
  }

  Widget _buildFormacoesTab() {
    final cs = Theme.of(context).colorScheme;

    if (_lineupHome.isEmpty && _lineupAway.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Formações não disponíveis', style: TextStyle(color: cs.onSurfaceVariant))));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        if (_lineupHome.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Text(_jogo!['match_hometeam_name'] ?? 'Casa', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ..._lineupHome.map((p) => ListTile(
                leading: CircleAvatar(child: Text(p['lineup_number']?.toString() ?? '0', style: TextStyle(fontSize: 12))),
                title: Text(p['lineup_player']?.toString() ?? '-', style: TextStyle(color: cs.onSurface)),
                subtitle: p['lineup_position'] != null ? Text(p['lineup_position'].toString(), style: TextStyle(color: cs.onSurfaceVariant)) : null,
              )),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        if (_lineupAway.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Text(_jogo!['match_awayteam_name'] ?? 'Fora', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ..._lineupAway.map((p) => ListTile(
                leading: CircleAvatar(child: Text(p['lineup_number']?.toString() ?? '0', style: TextStyle(fontSize: 12))),
                title: Text(p['lineup_player']?.toString() ?? '-', style: TextStyle(color: cs.onSurface)),
                subtitle: p['lineup_position'] != null ? Text(p['lineup_position'].toString(), style: TextStyle(color: cs.onSurfaceVariant)) : null,
              )),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        if ((_jogo!['match_hometeam_system'] ?? '').toString().isNotEmpty || (_jogo!['match_awayteam_system'] ?? '').toString().isNotEmpty)
          Column(children: [
            Text('Formações Táticas', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            if ((_jogo!['match_hometeam_system'] ?? '').toString().isNotEmpty) ...[
              Text('${_jogo!['match_hometeam_name']}: ${_jogo!['match_hometeam_system']}', style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
            ],
            if ((_jogo!['match_awayteam_system'] ?? '').toString().isNotEmpty) ...[
              Text('${_jogo!['match_awayteam_name']}: ${_jogo!['match_awayteam_system']}', style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ]),
      ]),
    );
  }

  Widget _buildEstatisticasTab() {
    final cs = Theme.of(context).colorScheme;
    final stats = _jogo!['statistics'];
    if (stats == null || (stats is List && stats.isEmpty)) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Estatísticas não disponíveis', style: TextStyle(color: cs.onSurfaceVariant))));
    }

    final List<Map<String, dynamic>> statList = [];
    if (stats is List) {
      for (var s in stats) {
        if (s is Map) statList.add(Map<String, dynamic>.from(s));
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: statList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final s = statList[idx];
        final type = s['type']?.toString() ?? 'Stat';
        final homeStr = s['home']?.toString().replaceAll('%', '') ?? '0';
        final awayStr = s['away']?.toString().replaceAll('%', '') ?? '0';
        
        final home = double.tryParse(homeStr) ?? 0;
        final away = double.tryParse(awayStr) ?? 0;
        
        // Para posse de bola, mostrar em percentagem
        final isPercentage = type.toLowerCase().contains('possession') || type.toLowerCase().contains('posse');
        final displayHome = isPercentage ? home : home.toInt();
        final displayAway = isPercentage ? away : away.toInt();
        final suffix = isPercentage ? '%' : '';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('$displayHome$suffix', style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
              Text(type, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
              Text('$displayAway$suffix', style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Expanded(
                    flex: home.toInt().clamp(1, 100),
                    child: Container(height: 8, color: cs.primary),
                  ),
                  Expanded(
                    flex: away.toInt().clamp(1, 100),
                    child: Container(height: 8, color: Colors.green),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildNoticiasTab() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Notícias em breve', style: TextStyle(color: cs.onSurfaceVariant)),
      ),
    );
  }
}