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

class _JogoDetalhesPageState extends State<JogoDetalhesPage> with SingleTickerProviderStateMixin {
  Future<dynamic>? _futureJogo;
  late AnimationController _loadingController;

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

    return CustomScrollView(
      slivers: [
        // Header limpo sem gradient
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            color: Theme.of(context).colorScheme.surface,
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
        ),

        // Conteúdo
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Gols separados por time
              if (jogo['goalscorer'] != null && jogo['goalscorer'].isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildGoalsSection(jogo),
              ],

              // Cartões separados por time
              if (jogo['cards'] != null && jogo['cards'].isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCardsSection(jogo),
              ],

              // Estatísticas melhoradas
              if (jogo['statistics'] != null && jogo['statistics'].isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildStatisticsSection(jogo),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection(dynamic jogo) {
    final homeGoals = <Map<String, dynamic>>[];
    final awayGoals = <Map<String, dynamic>>[];

    for (var gol in jogo['goalscorer']) {
      if (gol['home_scorer'] != null) {
        homeGoals.add(gol);
      } else if (gol['away_scorer'] != null) {
        awayGoals.add(gol);
      }
    }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gols Casa
              Expanded(
                child: Column(
                  children: homeGoals.map((gol) => _buildGoalItem(gol, true, jogo)).toList(),
                ),
              ),
              Container(width: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
              // Gols Visitante
              Expanded(
                child: Column(
                  children: awayGoals.map((gol) => _buildGoalItem(gol, false, jogo)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(Map<String, dynamic> gol, bool isHome, dynamic jogo) {
    final scorer = isHome ? (gol['home_scorer'] ?? '') : (gol['away_scorer'] ?? '');
    final assist = isHome ? (gol['home_assist'] ?? '') : (gol['away_assist'] ?? '');
    final time = gol['time'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (isHome) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scorer,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (assist.isNotEmpty)
                    Text(
                      assist,
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$time\'',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$time\'',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    scorer,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                  if (assist.isNotEmpty)
                    Text(
                      assist,
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    final homeCards = <Map<String, dynamic>>[];
    final awayCards = <Map<String, dynamic>>[];

    for (var card in jogo['cards']) {
      if (card['home_fault'] != null) {
        homeCards.add(card);
      } else if (card['away_fault'] != null) {
        awayCards.add(card);
      }
    }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: homeCards.map((card) => _buildCardItem(card, true)).toList(),
                ),
              ),
              Container(width: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
              Expanded(
                child: Column(
                  children: awayCards.map((card) => _buildCardItem(card, false)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, bool isHome) {
    final isYellow = card['card'] == 'yellow card';
    final player = isHome ? (card['home_fault'] ?? '') : (card['away_fault'] ?? '');
    final time = card['time'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (isHome) ...[
            Expanded(
              child: Text(
                player,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 28,
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
          ] else ...[
            Text(
              '$time\'',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            Container(
              width: 20,
              height: 28,
              decoration: BoxDecoration(
                color: isYellow ? const Color(0xFFFFD700) : const Color(0xFFDC143C),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                player,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                
                // Usar pizza chart para posse de bola
                if (type.toLowerCase().contains('posse') || type.toLowerCase().contains('ball possession')) {
                  return _buildPossessionStat(stat);
                }
                
                // Usar barras para outras estatísticas
                return _buildBarStat(stat);
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
            height: 120,
            child: CustomPaint(
              painter: _PieChartPainter(
                homeValue: home,
                awayValue: away,
                homeColor: Theme.of(context).colorScheme.primary,
                awayColor: Theme.of(context).colorScheme.tertiary,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${home.toInt()}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${away.toInt()}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.tertiary,
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

  Widget _buildBarStat(Map<String, dynamic> stat) {
    final home = double.tryParse(stat['home']?.toString() ?? '0') ?? 0;
    final away = double.tryParse(stat['away']?.toString() ?? '0') ?? 0;
    final total = home + away > 0 ? home + away : 1;
    final homePercent = home / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${home.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                stat['type'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${away.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.tertiary,
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
                  flex: (homePercent * 100).toInt().clamp(1, 100),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                    ),
                  ),
                ),
                Expanded(
                  flex: ((1 - homePercent) * 100).toInt().clamp(1, 100),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Material Design 3 Expressive Progress Indicator
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

// Pie Chart Painter para estatísticas
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
    
    // Home slice
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
    
    // Away slice
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
    
    // Center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.6, centerPaint);
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) => true;
}