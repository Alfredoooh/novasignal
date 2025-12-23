import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'search_page.dart';
import 'widgets/jogo_detalhes_header.dart';
import 'widgets/jogo_detalhes_tabs.dart';
import 'widgets/jogo_detalhes_betting_modal.dart';

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
  List<Map<String, dynamic>> _standings = [];
  Map<String, dynamic>? _predictions;
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

    // Standings
    if (_jogo!['standings'] != null && _jogo!['standings'] is List) {
      _standings = List<Map<String, dynamic>>.from(_jogo!['standings']);
    }

    // Predictions
    if (_jogo!['predictions'] != null && _jogo!['predictions'] is Map) {
      _predictions = Map<String, dynamic>.from(_jogo!['predictions']);
    }

    if (mounted) setState(() {});
  }

  void _showBettingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JogoDetalhesBettingModal(),
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
            JogoDetalhesHeader(
              jogo: _jogo!,
              cartoesAmareloCasa: _cartoesAmareloCasa,
              cartoesVermelhoCasa: _cartoesVermelhoCasa,
              cartoesAmareloFora: _cartoesAmareloFora,
              cartoesVermelhoFora: _cartoesVermelhoFora,
              tabController: _tabController,
              innerScrolled: innerScrolled,
            ),
          ];
        },
        body: JogoDetalhesTabs(
          tabController: _tabController,
          events: _events,
          statistics: _statistics,
          lineupHome: _lineupHome,
          lineupAway: _lineupAway,
          comentarios: _comentarios,
          standings: _standings,
          predictions: _predictions,
          jogo: _jogo!,
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
}