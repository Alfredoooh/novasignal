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
    
    // Animação de fade para os cards
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    // Criar controladores para cada estatística
    _statControllers = List.generate(
      widget.statistics.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 100)),
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
    
    // Iniciar animações
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      for (var i = 0; i < _statControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 80), () {
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
                key: ValueKey('statistics'),
                margin: const EdgeInsets.only(bottom: 16),
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
                    ...widget.statistics.take(8).asMap().entries.map((entry) {
                      final index = entry.key;
                      final stat = entry.value;
                      return index < _statAnimations.length
                          ? _buildStatRow(stat, cs, isDark, _statAnimations[index])
                          : _buildStatRow(stat, cs, isDark, null);
                    }),
                  ],
                ),
              ),
            ),
          ],
          if (widget.events.isEmpty)
            PageTransitionSwitcher(
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
                key: ValueKey('empty'),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? cs.surfaceContainerHighest : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? null : Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Icon(Symbols.event_busy_rounded, size: 48, color: cs.onSurfaceVariant.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum evento disponível',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...widget.events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              return AnimatedEventCard(
                key: ValueKey('event_$index'),
                event: event,
                homeTeamBadge: widget.homeTeamBadge,
                awayTeamBadge: widget.awayTeamBadge,
                delay: index * 60,
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
    final displayHome = isPercentage ? home : home.toInt();
    final displayAway = isPercentage ? away : away.toInt();
    final suffix = isPercentage ? '%' : '';

    final total = home + away;
    final homeFlex = total > 0 ? ((home / total) * 100).toInt().clamp(1, 100) : 50;
    final awayFlex = total > 0 ? ((away / total) * 100).toInt().clamp(1, 100) : 50;

    Widget progressBar = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Expanded(
            flex: homeFlex,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                ),
              ),
            ),
          ),
          Expanded(
            flex: awayFlex,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                ),
              ),
            ),
          ),
        ],
      ),
    );

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
                  final currentHome = (displayHome * (animation?.value ?? 1.0));
                  final displayValue = isPercentage ? currentHome : currentHome.toInt();
                  return Text(
                    '$displayValue$suffix',
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
                  final currentAway = (displayAway * (animation?.value ?? 1.0));
                  final displayValue = isPercentage ? currentAway : currentAway.toInt();
                  return Text(
                    '$displayValue$suffix',
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
          if (animation != null)
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // Fundo cinza
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Progressbars animadas
                      Row(
                        children: [
                          Expanded(
                            flex: (homeFlex * animation.value).toInt().clamp(1, 100),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: (awayFlex * animation.value).toInt().clamp(1, 100),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange.shade400, Colors.orange.shade600],
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
            )
          else
            progressBar,
        ],
      ),
    );
  }
}

// Widget animado para Event Cards
class AnimatedEventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final String? homeTeamBadge;
  final String? awayTeamBadge;
  final int delay;

  const AnimatedEventCard({
    super.key,
    required this.event,
    this.homeTeamBadge,
    this.awayTeamBadge,
    this.delay = 0,
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

  const EventCard({
    super.key,
    required this.event,
    this.homeTeamBadge,
    this.awayTeamBadge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = (event['type'] ?? '').toString();
    final time = event['time']?.toString() ?? '';
    final isHome = event['isHome'] == true;

    Widget eventIcon = _buildEventIcon(type, cs);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? null : Border.all(color: cs.outlineVariant.withOpacity(0.5)),
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
          // Coluna do time da casa
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

          // Coluna central com minutos (sem container)
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

          // Coluna do time visitante
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
                // Avatar do jogador
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
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/icons/player_placeholder.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Symbols.person_rounded,
                                size: 20,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/icons/player_placeholder.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Symbols.person_rounded,
                              size: 20,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                // Badge do clube no topo com animação
                if (teamBadge != null && teamBadge.isNotEmpty)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, badgeValue, child) {
                        return Transform.scale(
                          scale: badgeValue,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
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

  Widget _buildPlayerInfo({
    required String player,
    required String assist,
    required String method,
    required bool isHome,
    required ColorScheme cs,
    required String type,
  }) {
    final playerImageUrl = event['player_image']?.toString();
    final teamBadge = isHome ? homeTeamBadge : awayTeamBadge;

    return Column(
      crossAxisAlignment: isHome ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nome do jogador com foto (para gols e cartões)
        if (type == 'goal' || type == 'yellow' || type == 'red')
          Row(
            mainAxisSize: MainAxisSize.min,
            children: isHome
                ? [
                    _buildPlayerAvatar(
                      playerImageUrl: playerImageUrl,
                      teamBadge: teamBadge,
                      cs: cs,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        player.isNotEmpty ? player : 'Jogador',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          fontSize: 15,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]
                : [
                    Flexible(
                      child: Text(
                        player.isNotEmpty ? player : 'Jogador',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          fontSize: 15,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildPlayerAvatar(
                      playerImageUrl: playerImageUrl,
                      teamBadge: teamBadge,
                      cs: cs,
                    ),
                  ],
          )
        else
          Text(
            player.isNotEmpty ? player : 'Jogador',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              fontSize: 15,
              height: 1.3,
            ),
            textAlign: isHome ? TextAlign.left : TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        
        // Assistência
        if (assist.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: isHome
                  ? [
                      Image.asset(
                        'assets/icons/assist.png',
                        width: 14,
                        height: 14,
                        errorBuilder: (_, __, ___) => Icon(Symbols.sports_rounded, size: 14, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          assist,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]
                  : [
                      Flexible(
                        child: Text(
                          assist,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Image.asset(
                        'assets/icons/assist.png',
                        width: 14,
                        height: 14,
                        errorBuilder: (_, __, ___) => Icon(Symbols.sports_rounded, size: 14, color: cs.onSurfaceVariant),
                      ),
                    ],
            ),
          ),
        
        // VAR ou método
        if (method.isNotEmpty && method.toLowerCase().contains('var'))
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: isHome
                  ? [
                      Image.asset(
                        'assets/icons/var.png',
                        width: 16,
                        height: 16,
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          method,
                          style: TextStyle(
                            color: Colors.purple.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]
                  : [
                      Flexible(
                        child: Text(
                          method,
                          style: TextStyle(
                            color: Colors.purple.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Image.asset(
                        'assets/icons/var.png',
                        width: 16,
                        height: 16,
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
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
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              method,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: isHome ? TextAlign.left : TextAlign.right,
            ),
          ),
        
        // Substituições
        if (type == 'substitution' && event['playerIn'] != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: isHome
                ? [
                    Icon(Symbols.arrow_upward_rounded, size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        event['playerIn'].toString(),
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]
                : [
                    Flexible(
                      child: Text(
                        event['playerIn'].toString(),
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(Symbols.arrow_upward_rounded, size: 16, color: Colors.green.shade600),
                  ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: isHome
                ? [
                    Icon(Symbols.arrow_downward_rounded, size: 16, color: Colors.red.shade400),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        event['playerOut']?.toString() ?? '',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]
                : [
                    Flexible(
                      child: Text(
                        event['playerOut']?.toString() ?? '',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(Symbols.arrow_downward_rounded, size: 16, color: Colors.red.shade400),
                  ],
          ),
        ],
      ],
    );
  }
}