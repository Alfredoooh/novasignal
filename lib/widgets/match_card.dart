import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/cors_image.dart';

class MatchCard extends StatefulWidget {
  final dynamic jogo;
  final bool showLeague;
  final int index;
  final bool isFirst;
  final bool isLast;

  const MatchCard({
    super.key,
    required this.jogo,
    this.showLeague = false,
    this.index = 0,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
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

    Future.delayed(Duration(milliseconds: widget.index * 50), () {
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

  BorderRadius _getBorderRadius() {
    if (widget.isFirst && widget.isLast) {
      return BorderRadius.circular(16);
    } else if (widget.isFirst) {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(4),
      );
    } else if (widget.isLast) {
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
    final appState = context.read<AppState>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = widget.jogo['match_status'] ?? '';

    Color badgeColor;
    String badgeText = formatarStatus(status);

    if (status.contains('Finished') || status == 'FT' || status == 'AET') {
      badgeColor = isDark ? cs.tertiary.withOpacity(0.8) : cs.tertiary;
    } else if (status.contains("'") || status == 'HT' || status == 'LIVE') {
      badgeColor = isDark ? cs.error.withOpacity(0.9) : cs.error;
    } else {
      badgeColor = isDark ? cs.secondary.withOpacity(0.8) : cs.secondary;
    }

    final homeTeamLogo = widget.jogo['team_home_badge']?.toString() ?? '';
    final awayTeamLogo = widget.jogo['team_away_badge']?.toString() ?? '';
    final homeTeamName = widget.jogo['match_hometeam_name']?.toString() ?? 'Unknown';
    final awayTeamName = widget.jogo['match_awayteam_name']?.toString() ?? 'Unknown';
    final homeScore = widget.jogo['match_hometeam_score']?.toString() ?? '-';
    final awayScore = widget.jogo['match_awayteam_score']?.toString() ?? '-';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 2),
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
            child: OpenContainer(
              closedElevation: 0,
              openElevation: 0,
              closedShape: RoundedRectangleBorder(
                borderRadius: _getBorderRadius(),
              ),
              closedColor: Colors.transparent,
              openColor: cs.surface,
              middleColor: cs.surfaceContainerHigh,
              transitionDuration: const Duration(milliseconds: 400),
              transitionType: ContainerTransitionType.fade,
              closedBuilder: (context, action) => InkWell(
                onTap: action,
                borderRadius: _getBorderRadius(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Cabeçalho: Hora e Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Symbols.schedule_rounded,
                                size: 14,
                                color: cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.jogo['match_time'] ?? '--:--',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withOpacity(isDark ? 0.25 : 0.15),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: badgeColor.withOpacity(isDark ? 0.5 : 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: badgeColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Corpo: Times e Placar
                      Row(
                        children: [
                          // Time da Casa
                          Expanded(
                            child: Row(
                              children: [
                                _buildTeamLogo(homeTeamLogo, cs, isDark, 0),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    homeTeamName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Placar com animação
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: 0.8 + (0.2 * value),
                                  child: Text(
                                    '$homeScore : $awayScore',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Time Visitante
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    awayTeamName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildTeamLogo(awayTeamLogo, cs, isDark, 100),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Rodapé: Liga
                      if (widget.showLeague) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Symbols.emoji_events_rounded,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${widget.jogo['league_name'] ?? ''} • ${widget.jogo['country_name'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              openBuilder: (context, action) {
                // Navegar para detalhes do jogo
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  appState.setJogoDetalhes(
                    widget.jogo['match_id'],
                    '$homeTeamName vs $awayTeamName',
                  );
                  appState.navegarPara('jogo-detalhes');
                  Navigator.of(context).pop();
                });
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String logoUrl, ColorScheme cs, bool isDark, int delay) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: cs.surfaceContainerHighest,
              border: Border.all(
                color: cs.outlineVariant.withOpacity(isDark ? 0.3 : 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: logoUrl.isNotEmpty
                  ? CorsImage(
                      imageUrl: logoUrl,
                      width: 40,
                      height: 40,
                      errorWidget: _buildPlaceholderLogo(cs),
                    )
                  : _buildPlaceholderLogo(cs),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderLogo(ColorScheme cs) {
    return Container(
      width: 40,
      height: 40,
      color: cs.surfaceContainerHighest,
      child: Icon(
        Symbols.shield_rounded,
        size: 24,
        color: cs.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }
}