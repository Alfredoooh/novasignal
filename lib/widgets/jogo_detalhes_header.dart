import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:animations/animations.dart';
import '../utils/formatters.dart';
import '../screens/search_page.dart';

class JogoDetalhesHeader extends StatefulWidget {
  final Map<String, dynamic> jogo;
  final int cartoesAmareloCasa;
  final int cartoesVermelhoCasa;
  final int cartoesAmareloFora;
  final int cartoesVermelhoFora;
  final TabController tabController;
  final bool innerScrolled;

  const JogoDetalhesHeader({
    super.key,
    required this.jogo,
    required this.cartoesAmareloCasa,
    required this.cartoesVermelhoCasa,
    required this.cartoesAmareloFora,
    required this.cartoesVermelhoFora,
    required this.tabController,
    required this.innerScrolled,
  });

  @override
  State<JogoDetalhesHeader> createState() => _JogoDetalhesHeaderState();
}

class _JogoDetalhesHeaderState extends State<JogoDetalhesHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getMinutosJogo() {
    final status = widget.jogo['match_status'] ?? '';
    if (status == 'Finished' || status == 'After ET' || status == 'After Pen.') {
      return 'FT';
    } else if (status == 'Half Time') {
      return 'HT';
    } else if (status.contains("'")) {
      return status;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minutosJogo = _getMinutosJogo();

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: cs.surface,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: OpenContainer(
            closedElevation: 0,
            openElevation: 0,
            closedShape: const CircleBorder(),
            closedColor: cs.primaryContainer,
            openColor: cs.surface,
            middleColor: cs.primaryContainer,
            transitionDuration: const Duration(milliseconds: 500),
            closedBuilder: (context, action) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.search_rounded,
                color: cs.onPrimaryContainer,
                size: 22,
              ),
            ),
            openBuilder: (context, action) => const SearchPage(),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: widget.innerScrolled
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.jogo['team_home_badge'] != null)
                    Image.network(
                      widget.jogo['team_home_badge'],
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 24, color: cs.onSurface),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.jogo['team_away_badge'] != null)
                    Image.network(
                      widget.jogo['team_away_badge'],
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 24, color: cs.onSurface),
                    ),
                ],
              )
            : Text(
                widget.jogo['league_name'] ?? 'Liga',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        centerTitle: false,
        background: ClipPath(
          clipper: CurvedBottomClipper(),
          child: Container(
            color: cs.primaryContainer,
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        '${widget.jogo['match_date'] ?? ''} • ${widget.jogo['match_time'] ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onPrimaryContainer.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.jogo['league_name'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onPrimaryContainer.withOpacity(0.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final query = widget.jogo['match_hometeam_name'] ?? '';
                                    if (query.isNotEmpty) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SearchPage(initialQuery: query),
                                        ),
                                      );
                                    }
                                  },
                                  child: AnimatedBadge(
                                    badgeUrl: widget.jogo['team_home_badge'],
                                    delay: 100,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    widget.jogo['match_hometeam_name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onPrimaryContainer,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: [
                                Text(
                                  '${widget.jogo['match_hometeam_score'] ?? '0'} - ${widget.jogo['match_awayteam_score'] ?? '0'}',
                                  style: TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    color: cs.onPrimaryContainer,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (minutosJogo.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(widget.jogo['match_status'] ?? '', context).withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      minutosJogo,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: getStatusColor(widget.jogo['match_status'] ?? '', context),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(widget.jogo['match_status'] ?? '', context).withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    formatarStatus(widget.jogo['match_status'] ?? ''),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: getStatusColor(widget.jogo['match_status'] ?? '', context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final query = widget.jogo['match_awayteam_name'] ?? '';
                                    if (query.isNotEmpty) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SearchPage(initialQuery: query),
                                        ),
                                      );
                                    }
                                  },
                                  child: AnimatedBadge(
                                    badgeUrl: widget.jogo['team_away_badge'],
                                    delay: 200,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    widget.jogo['match_awayteam_name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onPrimaryContainer,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (widget.cartoesAmareloCasa > 0) ...[
                                  Container(
                                    width: 14,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.shade700,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.cartoesAmareloCasa}',
                                    style: TextStyle(
                                      color: cs.onPrimaryContainer,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (widget.cartoesVermelhoCasa > 0) ...[
                                  Container(
                                    width: 14,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.cartoesVermelhoCasa}',
                                    style: TextStyle(
                                      color: cs.onPrimaryContainer,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Row(
                              children: [
                                if (widget.cartoesAmareloFora > 0) ...[
                                  Text(
                                    '${widget.cartoesAmareloFora}',
                                    style: TextStyle(
                                      color: cs.onPrimaryContainer,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                                if (widget.cartoesVermelhoFora > 0) ...[
                                  Text(
                                    '${widget.cartoesVermelhoFora}',
                                    style: TextStyle(
                                      color: cs.onPrimaryContainer,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: cs.surface,
          child: TabBar(
            controller: widget.tabController,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Eventos'),
              Tab(text: 'Formações'),
              Tab(text: 'Classificação'),
              Tab(text: 'Previsões'),
              Tab(text: 'Comentários'),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom clipper para bordas curvas
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    
    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 3 / 4, size.height);
    final secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Widget animado para os escudos
class AnimatedBadge extends StatefulWidget {
  final String? badgeUrl;
  final int delay;
  final Color color;

  const AnimatedBadge({
    super.key,
    this.badgeUrl,
    required this.delay,
    required this.color,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
      child: (widget.badgeUrl ?? '').toString().isNotEmpty
          ? Image.network(
              widget.badgeUrl!,
              width: 60,
              height: 60,
              errorBuilder: (_, __, ___) => Icon(
                Icons.shield,
                size: 60,
                color: widget.color,
              ),
            )
          : Icon(
              Icons.shield,
              size: 60,
              color: widget.color,
            ),
    );
  }
}