import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'dart:math' show cos, sin, pi;
import 'jogo_detalhes_page.dart';

// ==================== LIGAS PAGE ====================
class LigasPage extends StatefulWidget {
  const LigasPage({super.key});

  @override
  State<LigasPage> createState() => _LigasPageState();
}

class _LigasPageState extends State<LigasPage> with SingleTickerProviderStateMixin {
  Future<List<dynamic>>? _futureLigas;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _futureLigas = context.read<AppState>().carregarLigas();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureLigas,
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
                Icon(Symbols.error_rounded, size: 64, color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('Erro ao carregar ligas'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final ligas = snapshot.data!;
          Map<String, List<dynamic>> ligasPorPais = {};
          for (var liga in ligas) {
            String pais = liga['country_name'] ?? 'Outros';
            ligasPorPais.putIfAbsent(pais, () => []);
            ligasPorPais[pais]!.add(liga);
          }
          final sortedPaises = ligasPorPais.keys.toList()..sort();

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: sortedPaises.length,
            itemBuilder: (context, index) {
              final pais = sortedPaises[index];
              final ligasDoPais = ligasPorPais[pais]!;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          Icon(Symbols.location_on_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(pais, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                          Text(
                            '${ligasDoPais.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: ligasDoPais.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final liga = entry.value;
                          final isLast = idx == ligasDoPais.length - 1;
                          return _buildLeagueItem(liga, context, isLast);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('Sem ligas'));
        }
      },
    );
  }

  Widget _buildLeagueItem(dynamic liga, BuildContext context, bool isLast) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LigaDetalhesPage(
              ligaId: liga['league_id'],
              ligaData: liga,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.vertical(
        top: Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                liga['league_logo'] ?? '',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Symbols.emoji_events_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                liga['league_name'] ?? 'Unknown',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Symbols.chevron_right_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ==================== LIGA DETALHES PAGE ====================
class LigaDetalhesPage extends StatefulWidget {
  final String ligaId;
  final dynamic ligaData;

  const LigaDetalhesPage({
    super.key,
    required this.ligaId,
    required this.ligaData,
  });

  @override
  State<LigaDetalhesPage> createState() => _LigaDetalhesPageState();
}

class _LigaDetalhesPageState extends State<LigaDetalhesPage> with TickerProviderStateMixin {
  Future<List<dynamic>>? _futureClassificacao;
  Future<List<dynamic>>? _futureJogos;
  late TabController _tabController;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _loadData() {
    final appState = context.read<AppState>();
    _futureClassificacao = appState.carregarClassificacao(widget.ligaId);
    _futureJogos = appState.carregarUltimosJogosLiga(widget.ligaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.ligaData['league_name'] ?? 'Liga',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.ligaData['league_logo'] ?? '',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Symbols.emoji_events_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ligaData['league_name'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        widget.ligaData['country_name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Classificação'),
                Tab(text: 'Últimos Jogos'),
              ],
            ),
          ),
          Container(height: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.3)),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildClassificacaoTab(),
                _buildJogosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificacaoTab() {
    return FutureBuilder<List<dynamic>>(
      future: _futureClassificacao,
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
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.leaderboard_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'Classificação não disponível',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final classificacao = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: classificacao.length,
          itemBuilder: (context, index) {
            final equipa = classificacao[index];
            Color? indicatorColor;
            if (index < 4) indicatorColor = const Color(0xFF4CAF50);
            else if (index < 6) indicatorColor = const Color(0xFF2196F3);
            else if (index >= classificacao.length - 3) indicatorColor = const Color(0xFFF44336);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: indicatorColor != null 
                    ? Border(left: BorderSide(color: indicatorColor, width: 4))
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      equipa['overall_league_position'] ?? '?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Image.network(
                    equipa['team_badge'] ?? '',
                    width: 28,
                    height: 28,
                    errorBuilder: (_, __, ___) => Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      equipa['team_name'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${equipa['overall_league_payed'] ?? 0}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${equipa['overall_league_PTS'] ?? 0}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJogosTab() {
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
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.sports_soccer_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'Nenhum jogo recente',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final jogos = snapshot.data!.take(15).toList();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jogos.length,
          itemBuilder: (context, index) {
            final jogo = jogos[index];
            return _buildMatchItem(jogo);
          },
        );
      },
    );
  }

  Widget _buildMatchItem(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${jogo['match_date']} • ${jogo['match_time']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isLive 
                          ? Colors.red.withOpacity(0.15)
                          : getStatusColor(status, context).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      formatarStatus(status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isLive ? Colors.red : getStatusColor(status, context),
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
                          errorBuilder: (_, __, ___) => Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            jogo['match_hometeam_name'] ?? 'Home',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${jogo['match_hometeam_score'] ?? '-'} : ${jogo['match_awayteam_score'] ?? '-'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            jogo['match_awayteam_name'] ?? 'Away',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.network(
                          jogo['team_away_badge'] ?? '',
                          width: 32,
                          height: 32,
                          errorBuilder: (_, __, ___) => Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
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