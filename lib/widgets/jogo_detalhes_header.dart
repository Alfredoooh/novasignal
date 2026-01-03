import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  String _getProxiedImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    if (kIsWeb) {
      return 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
    }
    
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minutosJogo = _getMinutosJogo();

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
            closedColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F3F3),
            openColor: cs.surface,
            middleColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F3F3),
            transitionDuration: const Duration(milliseconds: 500),
            closedBuilder: (context, action) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F3F3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.search_rounded,
                color: cs.onSurface,
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
                  if (widget.jogo['team_home_badge'] != null && widget.jogo['team_home_badge'].toString().isNotEmpty)
                    Image.network(
                      _getProxiedImageUrl(widget.jogo['team_home_badge']),
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.shield, size: 24, color: cs.onSurface);
                      },
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.jogo['match_hometeam_score'] ?? '-'} - ${widget.jogo['match_awayteam_score'] ?? '-'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.jogo['team_away_badge'] != null && widget.jogo['team_away_badge'].toString().isNotEmpty)
                    Image.network(
                      _getProxiedImageUrl(widget.jogo['team_away_badge']),
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.shield, size: 24, color: cs.onSurface);
                      },
                    ),
                ],
              )
            : null,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        centerTitle: false,
        background: ClipPath(
          clipper: CurvedTopAndBottomClipper(),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
            ),
            child: SafeArea(
              bottom: false,
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
                          fontSize: 13,
                          color: cs.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.jogo['league_name'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withOpacity(0.8),
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
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    widget.jogo['match_hometeam_name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
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
                                  '${widget.jogo['match_hometeam_score'] ?? '-'} - ${widget.jogo['match_awayteam_score'] ?? '-'}',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: cs.onSurface,
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
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    widget.jogo['match_awayteam_name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
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
                                      color: cs.onSurface,
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
                                      color: cs.onSurface,
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
                                      color: cs.onSurface,
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
                                      color: cs.onSurface,
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
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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

class CurvedTopAndBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    path.moveTo(0, 30);
    
    final topControlPoint1 = Offset(size.width * 0.25, 5);
    final topEndPoint1 = Offset(size.width * 0.5, 0);
    path.quadraticBezierTo(
      topControlPoint1.dx,
      topControlPoint1.dy,
      topEndPoint1.dx,
      topEndPoint1.dy,
    );
    
    final topControlPoint2 = Offset(size.width * 0.75, -5);
    final topEndPoint2 = Offset(size.width, 30);
    path.quadraticBezierTo(
      topControlPoint2.dx,
      topControlPoint2.dy,
      topEndPoint2.dx,
      topEndPoint2.dy,
    );
    
    path.lineTo(size.width, size.height - 40);

    final bottomControlPoint1 = Offset(size.width * 0.75, size.height - 10);
    final bottomEndPoint1 = Offset(size.width * 0.5, size.height - 15);
    path.quadraticBezierTo(
      bottomControlPoint1.dx,
      bottomControlPoint1.dy,
      bottomEndPoint1.dx,
      bottomEndPoint1.dy,
    );

    final bottomControlPoint2 = Offset(size.width * 0.25, size.height - 20);
    final bottomEndPoint2 = Offset(0, size.height - 40);
    path.quadraticBezierTo(
      bottomControlPoint2.dx,
      bottomControlPoint2.dy,
      bottomEndPoint2.dx,
      bottomEndPoint2.dy,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

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

  String _getProxiedImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    if (kIsWeb) {
      return 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
    }
    
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final proxiedUrl = _getProxiedImageUrl(widget.badgeUrl);
    final hasValidUrl = proxiedUrl.isNotEmpty && 
                        Uri.tryParse(proxiedUrl)?.hasAbsolutePath == true;

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
      child: hasValidUrl
          ? Image.network(
              proxiedUrl,
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: widget.color.withOpacity(0.5),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('❌ Erro ao carregar badge: ${widget.badgeUrl}');
                debugPrint('❌ URL proxied: $proxiedUrl');
                debugPrint('❌ Erro: $error');
                return Icon(
                  Icons.shield,
                  size: 60,
                  color: widget.color,
                );
              },
            )
          : Icon(
              Icons.shield,
              size: 60,
              color: widget.color,
            ),
    );
  }
}