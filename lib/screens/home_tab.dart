import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'dart:math' show cos, sin, pi;

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Future<List<dynamic>>? _futureJogos;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTopMatches();
    });

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _loadTopMatches() {
    final appState = context.read<AppState>();
    setState(() {
      _futureJogos = appState.carregarJogosDestaque(appState.topClubs);
    });
  }

  void _showMatchModal(dynamic jogo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMatchModal(jogo),
    );
  }

  Map<String, List<dynamic>> _categorizeMatches(List<dynamic> jogos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final liveAndToday = <dynamic>[];
    final upcoming = <dynamic>[];

    for (var jogo in jogos) {
      try {
        final matchDateStr = jogo['match_date'] ?? '';
        if (matchDateStr.isEmpty) {
          // Se não tem data, considera como upcoming
          upcoming.add(jogo);
          continue;
        }

        final parts = matchDateStr.split('-');
        if (parts.length != 3) {
          upcoming.add(jogo);
          continue;
        }

        final matchDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        final status = jogo['match_status'] ?? '';
        final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

        if (isLive || matchDate.isAtSameMomentAs(today)) {
          liveAndToday.add(jogo);
        } else if (matchDate.isAfter(today)) {
          upcoming.add(jogo);
        }
      } catch (e) {
        // Em caso de erro, adiciona aos upcoming
        upcoming.add(jogo);
      }
    }

    return {
      'liveAndToday': liveAndToday,
      'upcoming': upcoming,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureJogos,
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
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.error_rounded, size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('Erro ao carregar jogos: ${snapshot.error}'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadTopMatches,
                  icon: const Icon(Symbols.refresh_rounded),
                  label: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.sports_soccer_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('Nenhum jogo em destaque no momento'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadTopMatches,
                  icon: const Icon(Symbols.refresh_rounded),
                  label: const Text('Recarregar'),
                ),
              ],
            ),
          );
        }

        final jogos = snapshot.data!;
        
        // Se tiver jogos, mostra mesmo sem categorizar corretamente
        final categorized = _categorizeMatches(jogos);
        final featured = categorized['liveAndToday']!.isNotEmpty 
            ? categorized['liveAndToday']! 
            : (categorized['upcoming']!.isNotEmpty 
                ? categorized['upcoming']!.take(5).toList() 
                : jogos.take(5).toList());
        final upcoming = categorized['upcoming']!.isNotEmpty 
            ? categorized['upcoming']! 
            : jogos;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Jogos em Destaque',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),
              if (featured.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: featured.length,
                    itemBuilder: (context, index) {
                      return _buildFeaturedCard(featured[index]);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      featured.length,
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
              if (upcoming.isNotEmpty) ...[
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Próximos Jogos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                const SizedBox(height: 12),
                _buildMatchesList(upcoming),
              ],
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCard(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

    return GestureDetector(
      onTap: () {
        final appState = context.read<AppState>();
        appState.setJogoDetalhes(jogo['match_id'], '');
        appState.navegarPara('jogo-detalhes');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (isLive) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        formatarStatus(status),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    jogo['league_name'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Image.network(
                        jogo['team_home_badge'] ?? '',
                        width: 48,
                        height: 48,
                        errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        jogo['match_hometeam_name'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${jogo['match_hometeam_score'] ?? '0'} : ${jogo['match_awayteam_score'] ?? '0'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Image.network(
                        jogo['team_away_badge'] ?? '',
                        width: 48,
                        height: 48,
                        errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        jogo['match_awayteam_name'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 1,
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
    );
  }

  Widget _buildMatchesList(List<dynamic> jogos) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: jogos.take(8).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final jogo = entry.value;
          final isLast = index == jogos.take(8).length - 1;
          return _buildMatchListItem(jogo, isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildMatchListItem(dynamic jogo, bool isLast) {
    final status = jogo['match_status'] ?? '';

    return InkWell(
      onTap: () => _showMatchModal(jogo),
      borderRadius: BorderRadius.vertical(
        top: Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: !isLast ? Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 0.5,
            ),
          ) : null,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jogo['match_time'] ?? '',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  formatarStatus(status),
                  style: TextStyle(fontSize: 10, color: getStatusColor(status, context), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.network(jogo['team_home_badge'] ?? '', width: 24, height: 24, errorBuilder: (_, __, ___) => Container(width: 24, height: 24)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(jogo['match_hometeam_name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Text(jogo['match_hometeam_score'] ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Image.network(jogo['team_away_badge'] ?? '', width: 24, height: 24, errorBuilder: (_, __, ___) => Container(width: 24, height: 24)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(jogo['match_awayteam_name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Text(jogo['match_awayteam_score'] ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchModal(dynamic jogo) {
    final status = jogo['match_status'] ?? '';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header com Liga
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  if (jogo['league_logo'] != null && jogo['league_logo'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.network(
                        jogo['league_logo'],
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      jogo['league_name'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: getStatusColor(status, context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      formatarStatus(status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: getStatusColor(status, context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Conteúdo Principal
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                            const SizedBox(height: 12),
                            Text(
                              jogo['match_hometeam_name'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              '${jogo['match_hometeam_score'] ?? '0'} : ${jogo['match_awayteam_score'] ?? '0'}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                            const SizedBox(height: 12),
                            Text(
                              jogo['match_awayteam_name'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        final appState = context.read<AppState>();
                        appState.setJogoDetalhes(jogo['match_id'], '');
                        appState.navegarPara('jogo-detalhes');
                      },
                      icon: const Icon(Symbols.info_rounded),
                      label: const Text('Ver Detalhes Completos'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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