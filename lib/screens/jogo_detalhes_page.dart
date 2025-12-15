import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'dart:math' show cos, sin, pi;

class JogoDetalhesPage extends StatefulWidget {
  final String jogoId;

  const JogoDetalhesPage({super.key, required this.jogoId});

  @override
  State<JogoDetalhesPage> createState() => _JogoDetalhesPageState();
}

class _JogoDetalhesPageState extends State<JogoDetalhesPage> with TickerProviderStateMixin {
  Future<dynamic>? _futureJogo;
  late AnimationController _loadingController;
  final DraggableScrollableController _scrollController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _futureJogo = context.read<AppState>().carregarJogoDetalhes(widget.jogoId);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<dynamic>(
        future: _futureJogo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ExpressiveProgressPainter(
                        progress: _loadingController.value,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.error_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text('Erro ao carregar detalhes'),
                ],
              ),
            );
          }

          final jogo = snapshot.data!;
          return _buildDetalhes(jogo);
        },
      ),
    );
  }

  Widget _buildDetalhes(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

    return Stack(
      children: [
        // Header fixo
        Container(
          height: 280,
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
          child: Column(
            children: [
              Text(
                jogo['league_name'] ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Time Casa
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          jogo['team_home_badge'] ?? '',
                          width: 64,
                          height: 64,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.shield,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jogo['match_hometeam_name'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
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
                          '${jogo['match_hometeam_score'] ?? '0'} - ${jogo['match_awayteam_score'] ?? '0'}',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isLive 
                                ? getStatusColor(status, context).withOpacity(0.15)
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLive) ...[
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: getStatusColor(status, context),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                formatarStatus(status),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isLive 
                                      ? getStatusColor(status, context)
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time Visitante
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          jogo['team_away_badge'] ?? '',
                          width: 64,
                          height: 64,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.shield,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jogo['match_awayteam_name'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${jogo['match_date']} • ${jogo['match_time']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Modal draggable com conteúdo
        DraggableScrollableSheet(
          controller: _scrollController,
          initialChildSize: 0.65,
          minChildSize: 0.65,
          maxChildSize: 1.0,
          snap: true,
          snapSizes: const [0.65, 1.0],
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle do drag
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Conteúdo scrollável
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 100),
                      children: [
                        // Gols
                        if (jogo['goalscorer'] != null && jogo['goalscorer'].isNotEmpty) ...[
                          _buildGoalsSection(jogo),
                          const SizedBox(height: 16),
                        ],

                        // Cartões
                        if (jogo['cards'] != null && jogo['cards'].isNotEmpty) ...[
                          _buildCardsSection(jogo),
                          const SizedBox(height: 16),
                        ],

                        // Substituições
                        if (jogo['substitutions'] != null && jogo['substitutions'].isNotEmpty) ...[
                          _buildSubstitutionsSection(jogo),
                          const SizedBox(height: 16),
                        ],

                        // Estatísticas
                        if (jogo['statistics'] != null && jogo['statistics'].isNotEmpty) ...[
                          _buildStatisticsSection(jogo),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Bottom bar fixo
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OddsSelectionPage(jogoId: widget.jogoId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Começar Aposta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection(dynamic jogo) {
    final allGoals = <Map<String, dynamic>>[];
    
    for (var gol in jogo['goalscorer']) {
      allGoals.add({
        'time': int.tryParse(gol['time']?.toString() ?? '0') ?? 0,
        'scorer': gol['home_scorer'] ?? gol['away_scorer'] ?? '',
        'assist': gol['home_assist'] ?? gol['away_assist'] ?? '',
        'isHome': gol['home_scorer'] != null,
      });
    }
    
    // Ordenar por minuto crescente
    allGoals.sort((a, b) => a['time'].compareTo(b['time']));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Symbols.sports_soccer_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Gols', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          ...allGoals.map((gol) => _buildTimelineGoalItem(gol)).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTimelineGoalItem(Map<String, dynamic> gol) {
    final isHome = gol['isHome'] as bool;
    final time = gol['time'] as int;
    final scorer = gol['scorer'] as String;
    final assist = gol['assist'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (isHome) ...[
            // Time casa: nome à esquerda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scorer,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 2,
                  ),
                  if (assist.isNotEmpty)
                    Text(
                      assist,
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          // Minuto centralizado
          Container(
            width: 60,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHome 
                  ? const Color(0xFF1E88E5).withOpacity(0.15)
                  : const Color(0xFF43A047).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$time\'',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isHome ? const Color(0xFF1E88E5) : const Color(0xFF43A047),
              ),
            ),
          ),
          if (!isHome) ...[
            const SizedBox(width: 12),
            // Time visitante: nome à direita
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    scorer,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    textAlign: TextAlign.right,
                  ),
                  if (assist.isNotEmpty)
                    Text(
                      assist,
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardsSection(dynamic jogo) {
    final allCards = <Map<String, dynamic>>[];
    
    for (var card in jogo['cards']) {
      allCards.add({
        'time': int.tryParse(card['time']?.toString() ?? '0') ?? 0,
        'player': card['home_fault'] ?? card['away_fault'] ?? '',
        'isHome': card['home_fault'] != null,
        'isYellow': card['card'] == 'yellow card',
      });
    }
    
    allCards.sort((a, b) => a['time'].compareTo(b['time']));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Symbols.style_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Cartões', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          ...allCards.map((card) => _buildTimelineCardItem(card)).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTimelineCardItem(Map<String, dynamic> card) {
    final isHome = card['isHome'] as bool;
    final time = card['time'] as int;
    final player = card['player'] as String;
    final isYellow = card['isYellow'] as bool;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (isHome) ...[
            Expanded(
              child: Text(
                player,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Container(
            width: 60,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isYellow ? const Color(0xFFFFD700) : const Color(0xFFDC143C),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$time\'',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (!isHome) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                player,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubstitutionsSection(dynamic jogo) {
    final allSubs = <Map<String, dynamic>>[];
    
    for (var sub in jogo['substitutions']) {
      allSubs.add({
        'time': int.tryParse(sub['time']?.toString() ?? '0') ?? 0,
        'substitution': sub['substitution'] ?? '',
        'isHome': sub['home_scorer'] != null,
      });
    }
    
    allSubs.sort((a, b) => a['time'].compareTo(b['time']));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Symbols.swap_horiz_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Substituições', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          ...allSubs.map((sub) => _buildTimelineSubItem(sub)).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTimelineSubItem(Map<String, dynamic> sub) {
    final isHome = sub['isHome'] as bool;
    final time = sub['time'] as int;
    final substitution = sub['substitution'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (isHome) ...[
            Expanded(
              child: Text(
                substitution,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Container(
            width: 60,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.swap_horiz_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$time\'',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (!isHome) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                substitution,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(dynamic jogo) {
    final stats = jogo['statistics'] as List;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Symbols.bar_chart_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Estatísticas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: stats.map<Widget>((stat) {
                final type = stat['type'] ?? '';
                if (type.toLowerCase().contains('posse') || type.toLowerCase().contains('ball possession')) {
                  return _buildPossessionStat(stat);
                }
                return _buildAnimatedBarStat(stat);
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPossessionStat(Map<String, dynamic> stat) {
    final home = double.tryParse(stat['home']?.toString().replaceAll('%', '') ?? '0') ?? 0;
    final away = double.tryParse(stat['away']?.toString().replaceAll('%', '') ?? '0') ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Text(
            stat['type'] ?? '',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: _PieChartPainter(
                homeValue: home,
                awayValue: away,
                homeColor: const Color(0xFF1E88E5),
                awayColor: const Color(0xFF43A047),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${home.toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${away.toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF43A047),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBarStat(Map<String, dynamic> stat) {
    final home = double.tryParse(stat['home']?.toString() ?? '0') ?? 0;
    final away = double.tryParse(stat['away']?.toString() ?? '0') ?? 0;
    final total = home + away > 0 ? home + away : 1;
    final homePercent = home / total;

    return _AnimatedStatBar(
      home: home,
      away: away,
      homePercent: homePercent,
      type: stat['type'] ?? '',
    );
  }
}

class _AnimatedStatBar extends StatefulWidget {
  final double home;
  final double away;
  final double homePercent;
  final String type;

  const _AnimatedStatBar({
    required this.home,
    required this.away,
    required this.homePercent,
    required this.type,
  });

  @override
  State<_AnimatedStatBar> createState() => _AnimatedStatBarState();
}

class _AnimatedStatBarState extends State<_AnimatedStatBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.home.toInt()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  Text(
                    widget.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${widget.away.toInt()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF43A047),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: [
                    Expanded(
                      flex: ((widget.homePercent * _animation.value) * 100).toInt().clamp(1, 100),
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E88E5),
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: (((1 - widget.homePercent) * _animation.value) * 100).toInt().clamp(1, 100),
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF43A047),
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExpressiveProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ExpressiveProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

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
      colors: [
        color.withOpacity(0.2),
        color,
        color,
        color.withOpacity(0.2),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      transform: GradientRotation(startAngle),
    ).createShader(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ExpressiveProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PieChartPainter extends CustomPainter {
  final double homeValue;
  final double awayValue;
  final Color homeColor;
  final Color awayColor;

  _PieChartPainter({
    required this.homeValue,
    required this.awayValue,
    required this.homeColor,
    required this.awayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final total = homeValue + awayValue;

    if (total == 0) return;

    final homeSweep = (homeValue / total) * 2 * pi;

    final homePaint = Paint()
      ..color = homeColor
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      homeSweep,
      true,
      homePaint,
    );

    final awayPaint = Paint()
      ..color = awayColor
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + homeSweep,
      2 * pi - homeSweep,
      true,
      awayPaint,
    );

    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.65, centerPaint);
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) => true;
}

// Página de seleção de odds (placeholder)
class OddsSelectionPage extends StatelessWidget {
  final String jogoId;

  const OddsSelectionPage({super.key, required this.jogoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Odds'),
      ),
      body: const Center(
        child: Text('Tela de Odds em construção'),
      ),
    );
  }
}