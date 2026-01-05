import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:animations/animations.dart';

class EventosTab extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> statistics;
  final String? homeTeamBadge;
  final String? awayTeamBadge;

  const EventosTab({
    super.key,
    required this.events,
    required this.statistics,
    this.homeTeamBadge,
    this.awayTeamBadge,
  });

  @override
  State<EventosTab> createState() => _EventosTabState();
}

class _EventosTabState extends State<EventosTab> with TickerProviderStateMixin {
  late List<AnimationController> _statControllers;
  late List<Animation<double>> _statAnimations;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _statControllers = List.generate(
      widget.statistics.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1200 + (index * 100)),
        vsync: this,
      ),
    );

    _statAnimations = _statControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );
    }).toList();

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      for (var i = 0; i < _statControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 100), () {
          if (mounted) {
            _statControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (var controller in _statControllers) {
      controller.dispose();
    }
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.statistics.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(isDark ? 0.3 : 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
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
                      Icon(Symbols.bar_chart_rounded, color: cs.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Estatísticas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...widget.statistics.take(8).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final stat = entry.value;
                    return index < _statAnimations.length
                        ? _buildStatRow(stat, cs, isDark, _statAnimations[index])
                        : _buildStatRow(stat, cs, isDark, null);
                  }),
                ],
              ),
            ),
          ],
          if (widget.events.isEmpty && widget.statistics.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(isDark ? 0.3 : 0.5),
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/animations/no_data.gif',
                    width: 120,
                    height: 120,
                    errorBuilder: (_, __, ___) => Icon(
                      Symbols.event_busy_rounded,
                      size: 64,
                      color: cs.onSurfaceVariant.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum evento disponível',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Os eventos aparecerão aqui quando disponíveis',
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...widget.events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isFirst = index == 0;
              final isLast = index == widget.events.length - 1;
              return AnimatedEventCard(
                key: ValueKey('event_$index'),
                event: event,
                homeTeamBadge: widget.homeTeamBadge,
                awayTeamBadge: widget.awayTeamBadge,
                delay: index * 60,
                isFirst: isFirst,
                isLast: isLast,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatRow(Map<String, dynamic> s, ColorScheme cs, bool isDark, Animation<double>? animation) {
    final type = _translateStatType(s['type']?.toString() ?? 'Stat');
    final homeStr = s['home']?.toString().replaceAll('%', '') ?? '0';
    final awayStr = s['away']?.toString().replaceAll('%', '') ?? '0';

    final home = double.tryParse(homeStr) ?? 0;
    final away = double.tryParse(awayStr) ?? 0;

    final isPercentage = type.toLowerCase().contains('posse');

    String formatValue(double value, bool isPercentage) {
      if (isPercentage) {
        return value.toStringAsFixed(0);
      } else {
        return value.toInt().toString();
      }
    }

    final total = home + away;
    final homeFlex = total > 0 ? ((home / total) * 100).toInt().clamp(1, 100) : 50;
    final awayFlex = total > 0 ? ((away / total) * 100).toInt().clamp(1, 100) : 50;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedBuilder(
                animation: animation ?? AlwaysStoppedAnimation(1.0),
                builder: (context, child) {
                  final currentHome = (home * (animation?.value ?? 1.0));
                  return Text(
                    '${formatValue(currentHome, isPercentage)}${isPercentage ? '%' : ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      fontSize: 15,
                    ),
                  );
                },
              ),
              Text(
                type,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AnimatedBuilder(
                animation: animation ?? AlwaysStoppedAnimation(1.0),
                builder: (context, child) {
                  final currentAway = (away * (animation?.value ?? 1.0));
                  return Text(
                    '${formatValue(currentAway, isPercentage)}${isPercentage ? '%' : ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      fontSize: 15,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: animation ?? AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              final animValue = animation?.value ?? 1.0;
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: (homeFlex * animValue).toInt().clamp(1, 100),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [Colors.blue.shade400, Colors.blue.shade600]
                                    : [Colors.blue.shade600, Colors.blue.shade400],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: (awayFlex * animValue).toInt().clamp(1, 100),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [Colors.orange.shade400, Colors.orange.shade600]
                                    : [Colors.orange.shade400, Colors.orange.shade600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnimatedEventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final String? homeTeamBadge;
  final String? awayTeamBadge;
  final int delay;
  final bool isFirst;
  final bool isLast;

  const AnimatedEventCard({
    super.key,
    required this.event,
    this.homeTeamBadge,
    this.awayTeamBadge,
    this.delay = 0,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<AnimatedEventCard> createState() => _AnimatedEventCardState();
}

class _AnimatedEventCardState extends State<AnimatedEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: EventCard(
            event: widget.event,
            homeTeamBadge: widget.homeTeamBadge,
            awayTeamBadge: widget.awayTeamBadge,
            isFirst: widget.isFirst,
            isLast: widget.isLast,
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String? homeTeamBadge;
  final String? awayTeamBadge;
  final bool isFirst;
  final bool isLast;

  const EventCard({
    super.key,
    required this.event,
    this.homeTeamBadge,
    this.awayTeamBadge,
    this.isFirst = false,
    this.isLast = false,
  });

  BorderRadius _getBorderRadius() {
    if (isFirst && isLast) {
      return BorderRadius.circular(16);
    } else if (isFirst) {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(4),
      );
    } else if (isLast) {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    } else {
      return BorderRadius.circular(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = (event['type'] ?? '').toString();
    final time = event['time']?.toString() ?? '';
    final isHome = event['isHome'] == true;

    Widget eventIcon = _buildEventIcon(type, cs);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: _getBorderRadius(),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(isDark ? 0.3 : 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: isHome
                ? _buildEventDetails(
                    isHome: true,
                    cs: cs,
                    type: type,
                    icon: eventIcon,
                  )
                : const SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "$time'",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: cs.onSurfaceVariant,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: !isHome
                ? _buildEventDetails(
                    isHome: false,
                    cs: cs,
                    type: type,
                    icon: eventIcon,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventIcon(String type, ColorScheme cs) {
    if (type == 'goal') {
      return Image.asset(
        'assets/icons/soccer_ball.png',
        width: 22,
        height: 22,
        errorBuilder: (_, __, ___) => Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Symbols.sports_soccer_rounded, color: Colors.green, size: 16),
        ),
      );
    } else if (type == 'yellow') {
      return Container(
        width: 14,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.yellow.shade700,
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.shade900.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    } else if (type == 'red') {
      return Container(
        width: 14,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade900.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(Symbols.sync_alt_rounded, color: cs.primary, size: 16),
      );
    }
  }

  Widget _buildPlayerAvatar({
    required String? playerImageUrl,
    required String? teamBadge,
    required ColorScheme cs,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surfaceContainer,
                    border: Border.all(
                      color: cs.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: playerImageUrl != null && playerImageUrl.isNotEmpty
                        ? Image.network(
                            playerImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Symbols.person_rounded,
                              size: 20,
                              color: cs.onSurfaceVariant,
                            ),
                          )
                        : Icon(
                            Symbols.person_rounded,
                            size: 20,
                            color: cs.onSurfaceVariant,
                          ),
                  ),
                ),
                if (teamBadge != null && teamBadge.isNotEmpty)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, badgeValue, child) {
                        return Transform.scale(
                          scale: badgeValue,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.surface,
                              border: Border.all(
                                color: cs.surface,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                teamBadge,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: cs.surfaceContainer,
                                  child: Icon(
                                    Symbols.shield_rounded,
                                    size: 10,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventDetails({
    required bool isHome,
    required ColorScheme cs,
    required String type,
    required Widget icon,
  }) {
    final player = (event['player'] ?? '').toString();
    final assist = (event['assist'] ?? '').toString();
    final method = (event['method'] ?? '').toString();

    return Row(
      mainAxisAlignment: isHome ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isHome) ...[
          Flexible(
            child: _buildPlayerInfo(
              player: player,
              assist: assist,
              method: method,
              isHome: isHome,
              cs: cs,
              type: type,
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: icon,
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: icon,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: _buildPlayerInfo(
              player: player,
              assist: assist,
              method: method,
              isHome: isHome,
              cs: cs,
              type: type,
            ),
          ),
        ],
      ],
    );
  }