import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/jogo_detalhes_betting_modal.dart';
import 'search_page.dart';

class JogoDetalhesPage extends StatefulWidget {
  final String jogoId;

  const JogoDetalhesPage({super.key, required this.jogoId});

  @override
  State<JogoDetalhesPage> createState() => _JogoDetalhesPageState();
}

class _JogoDetalhesPageState extends State<JogoDetalhesPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _jogo;
  bool _isLoading = true;
  int _cartoesAmareloCasa = 0;
  int _cartoesVermelhoCasa = 0;
  int _cartoesAmareloFora = 0;
  int _cartoesVermelhoFora = 0;
  
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
    
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;

    try {
      final dados = await context.read<AppState>().carregarJogoDetalhes(widget.jogoId);
      if (!mounted) return;

      setState(() {
        _jogo = dados;
        _isLoading = false;
      });
      
      _extractCardData();
      _animationController.forward();
    } catch (e) {
      debugPrint('Erro ao carregar detalhes do jogo: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _jogo == null) {
        _carregarDados();
      }
    }
  }

  void _extractCardData() {
    if (_jogo == null) return;

    _cartoesAmareloCasa = 0;
    _cartoesVermelhoCasa = 0;
    _cartoesAmareloFora = 0;
    _cartoesVermelhoFora = 0;

    if (_jogo!['cards'] != null && _jogo!['cards'] is List) {
      for (var card in _jogo!['cards']) {
        final homeFault = card['home_fault']?.toString() ?? '';
        final awayFault = card['away_fault']?.toString() ?? '';
        final isHome = homeFault.isNotEmpty;
        final isYellow = card['card'] == 'yellow card';

        if (isHome) {
          if (isYellow) _cartoesAmareloCasa++;
          else _cartoesVermelhoCasa++;
        } else if (awayFault.isNotEmpty) {
          if (isYellow) _cartoesAmareloFora++;
          else _cartoesVermelhoFora++;
        }
      }
    }

    if (mounted) setState(() {});
  }

  void _showBettingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JogoDetalhesBettingModal(),
    );
  }

  String _getMinutosJogo() {
    final status = _jogo?['match_status'] ?? '';
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScaffold();
    }

    if (_jogo == null) {
      return _buildErrorScaffold();
    }

    final minutosJogo = _getMinutosJogo();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(minutosJogo),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height - 400,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.sports_soccer_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Detalhes do Jogo',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Informações completas sobre a partida',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Botões fixos no topo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Symbols.arrow_back_rounded,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  OpenContainer(
                    closedElevation: 0,
                    openElevation: 0,
                    closedShape: const CircleBorder(),
                    closedColor: Colors.white,
                    openColor: Colors.white,
                    middleColor: Colors.white,
                    transitionDuration: const Duration(milliseconds: 500),
                    closedBuilder: (context, action) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Symbols.search_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                    openBuilder: (context, action) => const SearchPage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
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
            onPressed: _showBettingModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Começar Aposta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String minutosJogo) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ClipPath(
          clipper: _CurvedTopAndBottomClipper(),
          child: Container(
            padding: const EdgeInsets.only(top: 80, bottom: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${_jogo!['match_date'] ?? ''} • ${_jogo!['match_time'] ?? ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _jogo!['league_name'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final query = _jogo!['match_hometeam_name'] ?? '';
                              if (query.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(initialQuery: query),
                                  ),
                                );
                              }
                            },
                            child: _AnimatedBadge(
                              badgeUrl: _jogo!['team_home_badge'],
                              delay: 100,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              _jogo!['match_hometeam_name'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            '${_jogo!['match_hometeam_score'] ?? '-'} - ${_jogo!['match_awayteam_score'] ?? '-'}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (minutosJogo.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: getStatusColor(_jogo!['match_status'] ?? '', context).withOpacity(0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                minutosJogo,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: getStatusColor(_jogo!['match_status'] ?? '', context),
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: getStatusColor(_jogo!['match_status'] ?? '', context).withOpacity(0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              formatarStatus(_jogo!['match_status'] ?? ''),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: getStatusColor(_jogo!['match_status'] ?? '', context),
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
                              final query = _jogo!['match_awayteam_name'] ?? '';
                              if (query.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(initialQuery: query),
                                  ),
                                );
                              }
                            },
                            child: _AnimatedBadge(
                              badgeUrl: _jogo!['team_away_badge'],
                              delay: 200,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              _jogo!['match_awayteam_name'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (_cartoesAmareloCasa > 0) ...[
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
                              '$_cartoesAmareloCasa',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (_cartoesVermelhoCasa > 0) ...[
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
                              '$_cartoesVermelhoCasa',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          if (_cartoesAmareloFora > 0) ...[
                            Text(
                              '$_cartoesAmareloFora',
                              style: const TextStyle(
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
                          if (_cartoesVermelhoFora > 0) ...[
                            Text(
                              '$_cartoesVermelhoFora',
                              style: const TextStyle(
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
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: const Color(0xFF007AFF),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.error_rounded,
              size: 64,
              color: Colors.red.withOpacity(0.8),
            ),
            const SizedBox(height: 12),
            const Text('Erro ao carregar detalhes'),
          ],
        ),
      ),
    );
  }
}

class _CurvedTopAndBottomClipper extends CustomClipper<Path> {
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

class _AnimatedBadge extends StatefulWidget {
  final String? badgeUrl;
  final int delay;

  const _AnimatedBadge({
    this.badgeUrl,
    required this.delay,
  });

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
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
    final hasValidUrl = proxiedUrl.isNotEmpty;

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
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.shield,
                  size: 60,
                  color: Colors.grey.shade400,
                );
              },
            )
          : Icon(
              Icons.shield,
              size: 60,
              color: Colors.grey.shade400,
            ),
    );
  }
}