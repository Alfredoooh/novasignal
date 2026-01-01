import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:animations/animations.dart';

class StandingsTab extends StatefulWidget {
  final List<Map<String, dynamic>> standings;
  final Map<String, dynamic> jogo;

  const StandingsTab({
    super.key,
    required this.standings,
    required this.jogo,
  });

  @override
  State<StandingsTab> createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _teamKeys = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late List<AnimationController> _rowControllers;
  late List<Animation<double>> _rowAnimations;

  @override
  void initState() {
    super.initState();
    
    // Criar keys para cada time
    _teamKeys.addAll(List.generate(widget.standings.length, (_) => GlobalKey()));
    
    // Animação de fade geral
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    // Criar animações para cada linha
    _rowControllers = List.generate(
      widget.standings.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 500 + (index * 30)),
        vsync: this,
      ),
    );
    
    _rowAnimations = _rowControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );
    }).toList();
    
    // Iniciar animações
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      for (var i = 0; i < _rowControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 40), () {
          if (mounted) {
            _rowControllers[i].forward();
          }
        });
      }
    });
    
    // Scroll automático para as equipas em jogo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToHighlightedTeams();
    });
  }

  void _scrollToHighlightedTeams() {
    if (!mounted || widget.standings.isEmpty) return;
    
    // Encontrar índice da primeira equipa destacada
    int? firstHighlightedIndex;
    for (int i = 0; i < widget.standings.length; i++) {
      final team = widget.standings[i];
      final isHomeTeam = team['team_name'] == widget.jogo['match_hometeam_name'];
      final isAwayTeam = team['team_name'] == widget.jogo['match_awayteam_name'];
      
      if (isHomeTeam || isAwayTeam) {
        firstHighlightedIndex = i;
        break;
      }
    }
    
    if (firstHighlightedIndex != null && firstHighlightedIndex > 2) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        
        final keyContext = _teamKeys[firstHighlightedIndex!].currentContext;
        if (keyContext != null) {
          Scrollable.ensureVisible(
            keyContext,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            alignment: 0.2, // Scroll para que fique mais no topo
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    for (var controller in _rowControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.standings.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.leaderboard_rounded,
                  size: 64,
                  color: cs.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Classificação não disponível',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          PageTransitionSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: Container(
              key: ValueKey('standings_table'),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? cs.surfaceContainerHighest : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isDark ? null : Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Symbols.leaderboard_rounded, color: cs.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.jogo['league_name'] ?? 'Classificação',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTableHeader(cs, isDark),
                  const SizedBox(height: 8),
                  ...widget.standings.asMap().entries.map((entry) {
                    final index = entry.key;
                    final team = entry.value;
                    final isHomeTeam = team['team_name'] == widget.jogo['match_hometeam_name'];
                    final isAwayTeam = team['team_name'] == widget.jogo['match_awayteam_name'];
                    final isHighlighted = isHomeTeam || isAwayTeam;

                    return AnimatedBuilder(
                      animation: index < _rowAnimations.length 
                          ? _rowAnimations[index] 
                          : AlwaysStoppedAnimation(1.0),
                      builder: (context, child) {
                        final animation = index < _rowAnimations.length 
                            ? _rowAnimations[index] 
                            : AlwaysStoppedAnimation(1.0);
                        
                        return Opacity(
                          opacity: animation.value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - animation.value)),
                            child: _buildStandingRow(
                              key: _teamKeys[index],
                              team: team,
                              position: index + 1,
                              isHighlighted: isHighlighted,
                              isHomeTeam: isHomeTeam,
                              cs: cs,
                              isDark: isDark,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(cs, isDark),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Time',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              'J',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              'V',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              'E',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              'D',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              'Pts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingRow({
    Key? key,
    required Map<String, dynamic> team,
    required int position,
    required bool isHighlighted,
    required bool isHomeTeam,
    required ColorScheme cs,
    required bool isDark,
  }) {
    final teamName = team['team_name']?.toString() ?? 'Time';
    final played = team['overall_league_payed']?.toString() ?? '0';
    final wins = team['overall_league_W']?.toString() ?? '0';
    final draws = team['overall_league_D']?.toString() ?? '0';
    final losses = team['overall_league_L']?.toString() ?? '0';
    final points = team['overall_league_PTS']?.toString() ?? '0';

    Color? positionColor;
    if (position <= 4) {
      positionColor = const Color(0xFF00C853);
    } else if (position <= 6) {
      positionColor = Colors.blue;
    } else if (position >= (widget.standings.length - 2)) {
      positionColor = Colors.red;
    }

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 6),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? (isHomeTeam 
                      ? cs.primary.withOpacity(isDark ? 0.15 : 0.1)
                      : Colors.orange.withOpacity(isDark ? 0.15 : 0.1))
                  : (isDark ? cs.surface : cs.surfaceContainerLow),
              borderRadius: BorderRadius.circular(10),
              border: isHighlighted
                  ? Border.all(
                      color: isHomeTeam ? cs.primary : Colors.orange,
                      width: 2,
                    )
                  : null,
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: (isHomeTeam ? cs.primary : Colors.orange).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Row(
                    children: [
                      if (positionColor != null)
                        Container(
                          width: 3,
                          height: 24,
                          decoration: BoxDecoration(
                            color: positionColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        '$position',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: isHighlighted ? Curves.elasticOut : Curves.easeOut,
                        builder: (context, logoValue, child) {
                          return Transform.scale(
                            scale: isHighlighted ? (0.8 + (0.4 * logoValue)) : logoValue,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: isHighlighted
                                  ? BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isHomeTeam ? cs.primary : Colors.orange)
                                              .withOpacity(0.4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    )
                                  : null,
                              child: team['team_badge'] != null && 
                                     team['team_badge'].toString().isNotEmpty
                                  ? Image.network(
                                      team['team_badge'],
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Symbols.shield_rounded,
                                        size: 24,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    )
                                  : Icon(
                                      Symbols.shield_rounded,
                                      size: 24,
                                      color: cs.onSurfaceVariant,
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          teamName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                            color: cs.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    played,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    wins,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    draws,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    losses,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    points,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend(ColorScheme cs, bool isDark) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
      child: Container(
        key: ValueKey('legend'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? null : Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legenda',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildLegendItem('Champions League', const Color(0xFF00C853), cs),
            const SizedBox(height: 8),
            _buildLegendItem('Europa League', Colors.blue, cs),
            const SizedBox(height: 8),
            _buildLegendItem('Rebaixamento', Colors.red, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, ColorScheme cs) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}