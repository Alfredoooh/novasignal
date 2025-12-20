import 'dart:math' show cos, sin, pi;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';

class JogoDetalhesPage extends StatefulWidget {
  final String jogoId;

  const JogoDetalhesPage({super.key, required this.jogoId});

  @override
  State<JogoDetalhesPage> createState() => _JogoDetalhesPageState();
}

class _JogoDetalhesPageState extends State<JogoDetalhesPage> with TickerProviderStateMixin {
  Map<String, dynamic>? _jogo;
  bool _isLoading = true;
  late AnimationController _loadingController;
  String _selectedTab = 'overview';

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final dados = await context.read<AppState>().carregarJogoDetalhes(widget.jogoId);
      if (mounted) {
        setState(() {
          _jogo = dados;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Adotamos as cores do tema para garantir que a página muda com o app
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_isLoading) {
      return _buildLoadingScaffold(cs);
    }

    if (_jogo == null) {
      return Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(
          backgroundColor: cs.surface,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Detalhes', style: TextStyle(color: cs.onSurface)),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.error_rounded,
                size: 64,
                color: cs.error.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text('Erro ao carregar detalhes', style: TextStyle(color: cs.onSurface)),
            ],
          ),
        ),
      );
    }

    return _buildDetalhes(_jogo!);
  }

  Widget _buildLoadingScaffold(ColorScheme cs) {
    // Lista de cards com glassmorphism e o loader expressivo no centro de cada card.
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detalhes', style: TextStyle(color: cs.onSurface)),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildGlassLoadingCard(cs);
        },
      ),
    );
  }

  Widget _buildGlassLoadingCard(ColorScheme cs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // fundo translúcido
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.surface.withOpacity(0.55),
                  cs.surfaceVariant.withOpacity(0.35),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.onSurface.withOpacity(0.06)),
            ),
          ),
          // blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: AnimatedBuilder(
                      animation: _loadingController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _ExpressiveProgressPainter(
                            progress: _loadingController.value,
                            color: cs.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cs.onSurface.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: cs.onSurface.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                            color: cs.onSurface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalhes(Map<String, dynamic> jogo) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

    return Scaffold(
      backgroundColor: cs.background,
      body: CustomScrollView(
        slivers: [
          // App Bar com Header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: cs.surface,
            leading: IconButton(
              icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Symbols.share_rounded, color: cs.onSurface),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Symbols.star_outline_rounded, color: cs.onSurface),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cs.primaryContainer,
                      cs.surface.withOpacity(0.9),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        jogo['league_name'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
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
                                    color: cs.primary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  jogo['match_hometeam_name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
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
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isLive
                                        ? cs.error.withOpacity(0.14)
                                        : cs.surfaceVariant,
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
                                            color: cs.error,
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
                                          color: isLive ? cs.error : cs.onSurfaceVariant,
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
                                    color: cs.primary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  jogo['match_awayteam_name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${jogo['match_date']} • ${jogo['match_time']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tabs de navegação (custom buttons - sem indicator separado)
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              child: Container(
                color: cs.surface,
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      color: cs.surfaceVariant.withOpacity(0.6),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _buildTabButton('overview', 'Overview'),
                          const SizedBox(width: 8),
                          _buildTabButton('stats', 'Estatísticas'),
                          const SizedBox(width: 8),
                          _buildTabButton('lineups', 'Formações'),
                          const SizedBox(width: 8),
                          _buildTabButton('h2h', 'H2H'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Container(
              color: cs.background,
              child: _buildTabContent(jogo),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.surfaceVariant, width: 1)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Começar Aposta',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: cs.onPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String value, String label) {
    final isSelected = _selectedTab == value;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.06)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> jogo) {
    switch (_selectedTab) {
      case 'stats':
        return _buildStatsTab(jogo);
      case 'lineups':
        return _buildLineupsTab(jogo);
      case 'h2h':
        return _buildH2HTab(jogo);
      default:
        return _buildOverviewTab(jogo);
    }
  }

  Widget _buildOverviewTab(Map<String, dynamic> jogo) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Stream / Match Live
          if (jogo['match_live'] == '1') ...[
            _buildLiveStreamCard(),
            const SizedBox(height: 16),
          ],

          // Timeline de eventos
          _buildTimelineSection(jogo),
          const SizedBox(height: 16),

          // Informações do estádio
          _buildInfoCard(jogo),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLiveStreamCard() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1459865264687-595d652de67e?w=800'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Symbols.play_arrow_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              'Live Stream',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(Map<String, dynamic> jogo) {
    final cs = Theme.of(context).colorScheme;
    final events = <Map<String, dynamic>>[];

    // Adicionar gols
    if (jogo['goalscorer'] != null) {
      for (var gol in jogo['goalscorer'] as List) {
        events.add({
          'type': 'goal',
          'time': int.tryParse(gol['time']?.toString() ?? '0') ?? 0,
          'player': gol['home_scorer'] ?? gol['away_scorer'] ?? '',
          'assist': gol['home_assist'] ?? gol['away_assist'] ?? '',
          'isHome': gol['home_scorer'] != null && gol['home_scorer'].toString().isNotEmpty,
          'score': gol['score'] ?? '',
        });
      }
    }

    // Adicionar cartões
    if (jogo['cards'] != null) {
      for (var card in jogo['cards'] as List) {
        events.add({
          'type': card['card'] == 'yellow card' ? 'yellow' : 'red',
          'time': int.tryParse(card['time']?.toString() ?? '0') ?? 0,
          'player': card['home_fault'] ?? card['away_fault'] ?? '',
          'isHome': card['home_fault'] != null && card['home_fault'].toString().isNotEmpty,
        });
      }
    }

    // Adicionar substituições
    if (jogo['substitutions'] != null) {
      for (var sub in jogo['substitutions'] as List) {
        final substitution = sub['substitution']?.toString() ?? '';
        final parts = substitution.split('|');
        events.add({
          'type': 'substitution',
          'time': int.tryParse(sub['time']?.toString() ?? '0') ?? 0,
          'playerOut': parts.isNotEmpty ? parts[0].trim() : '',
          'playerIn': parts.length > 1 ? parts[1].trim() : '',
          'isHome': sub['home_scorer'] != null && sub['home_scorer'].toString().isNotEmpty,
        });
      }
    }

    events.sort((a, b) => a['time'].compareTo(b['time']));

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...events.map((event) => _buildTimelineEvent(event)),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(Map<String, dynamic> event) {
    final type = event['type'];
    final time = event['time'];
    final isHome = event['isHome'];

    Widget eventIcon;
    Color eventColor;

    if (type == 'goal') {
      eventIcon = Icon(Symbols.sports_soccer_rounded, size: 20, color: Colors.white);
      eventColor = const Color(0xFF34C759);
    } else if (type == 'yellow') {
      eventIcon = Container(
        width: 16,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700),
          borderRadius: BorderRadius.circular(3),
        ),
      );
      eventColor = const Color(0xFFFFD700);
    } else if (type == 'red') {
      eventIcon = Container(
        width: 16,
        height: 20,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(3),
        ),
      );
      eventColor = Theme.of(context).colorScheme.error;
    } else {
      eventIcon = Icon(Symbols.swap_horiz_rounded, size: 20, color: Theme.of(context).colorScheme.primary);
      eventColor = Theme.of(context).colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha do tempo (esquerda)
          if (isHome) ...[
            Expanded(
              child: _buildEventContent(event, true),
            ),
            const SizedBox(width: 12),
            _buildTimelineDot(time, eventIcon, eventColor),
            const Expanded(child: SizedBox()),
          ] else ...[
            const Expanded(child: SizedBox()),
            _buildTimelineDot(time, eventIcon, eventColor),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEventContent(event, false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineDot(int time, Widget icon, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(child: icon),
        ),
        const SizedBox(height: 4),
        Text(
          '$time\'',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEventContent(Map<String, dynamic> event, bool isHome) {
    final type = event['type'];

    if (type == 'goal') {
      return Column(
        crossAxisAlignment: isHome ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            event['player'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: isHome ? TextAlign.right : TextAlign.left,
          ),
          if (event['assist'].toString().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Assistência: ${event['assist']}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: isHome ? TextAlign.right : TextAlign.left,
            ),
          ],
          const SizedBox(height: 2),
          Text(
            event['score'],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF34C759),
            ),
            textAlign: isHome ? TextAlign.right : TextAlign.left,
          ),
        ],
      );
    } else if (type == 'substitution') {
      return Column(
        crossAxisAlignment: isHome ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isHome) ...[
                Icon(Symbols.arrow_upward_rounded, size: 16, color: const Color(0xFF34C759)),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  event['playerIn'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF34C759),
                  ),
                  textAlign: isHome ? TextAlign.right : TextAlign.left,
                ),
              ),
              if (isHome) ...[
                const SizedBox(width: 4),
                const Icon(Symbols.arrow_upward_rounded, size: 16, color: Color(0xFF34C759)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isHome) ...[
                Icon(Symbols.arrow_downward_rounded, size: 16, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  event['playerOut'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: isHome ? TextAlign.right : TextAlign.left,
                ),
              ),
              if (isHome) ...[
                const SizedBox(width: 4),
                Icon(Symbols.arrow_downward_rounded, size: 16, color: Theme.of(context).colorScheme.error),
              ],
            ],
          ),
        ],
      );
    } else {
      return Text(
        event['player'],
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        textAlign: isHome ? TextAlign.right : TextAlign.left,
      );
    }
  }

  Widget _buildInfoCard(Map<String, dynamic> jogo) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Symbols.stadium_rounded, 'Estádio', jogo['match_stadium'] ?? 'N/A'),
          _buildInfoRow(Symbols.sports_rounded, 'Árbitro', jogo['match_referee'] ?? 'N/A'),
          _buildInfoRow(Symbols.grid_view_rounded, 'Formação Casa', jogo['match_hometeam_system'] ?? 'N/A'),
          _buildInfoRow(Symbols.grid_view_rounded, 'Formação Fora', jogo['match_awayteam_system'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(Map<String, dynamic> jogo) {
    final cs = Theme.of(context).colorScheme;
    if (jogo['statistics'] == null || (jogo['statistics'] as List).isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Estatísticas não disponíveis',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: (jogo['statistics'] as List).map<Widget>((stat) {
                if (stat['type'].toString().toLowerCase().contains('posse') ||
                    stat['type'].toString().toLowerCase().contains('ball possession')) {
                  return _buildPossessionStat(stat);
                }
                return _buildAnimatedStatBar(stat);
              }).toList(),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPossessionStat(Map<String, dynamic> stat) {
    final home = double.tryParse(stat['home']?.toString().replaceAll('%', '') ?? '0') ?? 0;
    final away = double.tryParse(stat['away']?.toString().replaceAll('%', '') ?? '0') ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Text(
            stat['type'] ?? '',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: _PieChartPainter(
                homeValue: home,
                awayValue: away,
                homeColor: Theme.of(context).colorScheme.primary,
                awayColor: const Color(0xFF34C759),
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${home.toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${away.toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF34C759),
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

  Widget _buildAnimatedStatBar(Map<String, dynamic> stat) {
    final home = double.tryParse(stat['home']?.toString() ?? '0') ?? 0;
    final away = double.tryParse(stat['away']?.toString() ?? '0') ?? 0;
    final total = home + away > 0 ? home + away : 1;
    final homePercent = home / total;

    return _AnimatedStatBar(
      home: home,
      away: away,
      homePercent: homePercent,
      type: stat['type'] ?? '',
    );
  }

  Widget _buildLineupsTab(Map<String, dynamic> jogo) {
    final homeFormation = jogo['match_hometeam_system'] ?? '4-4-2';
    final awayFormation = jogo['match_awayteam_system'] ?? '4-4-2';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Campo de futebol com formações
          Container(
            height: 700,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                  Color(0xFF1B5E20),
                ],
              ),
            ),
            child: CustomPaint(
              painter: _FootballFieldPainter(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Time visitante (topo)
                  Text(
                    '${jogo['match_awayteam_name']} - $awayFormation',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: _buildFormationPositions(awayFormation, false),
                    ),
                  ),
                  // Linha do meio
                  Container(
                    height: 2,
                    color: Colors.white.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: _buildFormationPositions(homeFormation, true),
                    ),
                  ),
                  // Time da casa (base)
                  Text(
                    '${jogo['match_hometeam_name']} - $homeFormation',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFormationPositions(String formation, bool isHome) {
    final positions = formation.split('-').map((e) => int.tryParse(e) ?? 1).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: positions.reversed.map((count) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(count, (index) {
            return Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isHome ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        );
      }).toList(),
    );
  }

  Widget _buildH2HTab(Map<String, dynamic> jogo) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'Histórico H2H não disponível',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _FootballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Círculo central
    canvas.drawCircle(center, 50, paint);
    canvas.drawCircle(center, 2, Paint()..color = Colors.white);

    // Áreas
    final areaWidth = size.width * 0.6;
    final areaHeight = size.height * 0.15;

    // Área superior
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, areaHeight / 2),
        width: areaWidth,
        height: areaHeight,
      ),
      paint,
    );

    // Área inferior
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - areaHeight / 2),
        width: areaWidth,
        height: areaHeight,
      ),
      paint,
    );

    // Pequenas áreas
    final smallAreaWidth = size.width * 0.35;
    final smallAreaHeight = size.height * 0.08;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, smallAreaHeight / 2),
        width: smallAreaWidth,
        height: smallAreaHeight,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - smallAreaHeight / 2),
        width: smallAreaWidth,
        height: smallAreaHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedStatBar extends StatefulWidget {
  final double home;
  final double away;
  final double homePercent;
  final String type;

  const _AnimatedStatBar({
    required this.home,
    required this.away,
    required this.homePercent,
    required this.type,
  });

  @override
  State<_AnimatedStatBar> createState() => _AnimatedStatBarState();
}

class _AnimatedStatBarState extends State<_AnimatedStatBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.home.toInt()}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  Text(
                    widget.type,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${widget.away.toInt()}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF34C759),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 10,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Row(
                    children: [
                      Expanded(
                        flex: ((widget.homePercent * _animation.value) * 100).toInt().clamp(1, 100),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: (((1 - widget.homePercent) * _animation.value) * 100).toInt().clamp(1, 100),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF34C759),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _PieChartPainter extends CustomPainter {
  final double homeValue;
  final double awayValue;
  final Color homeColor;
  final Color awayColor;
  final Color backgroundColor;

  _PieChartPainter({
    required this.homeValue,
    required this.awayValue,
    required this.homeColor,
    required this.awayColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final total = homeValue + awayValue;

    if (total == 0) return;

    final homeSweep = (homeValue / total) * 2 * pi;

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

    final centerPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.65, centerPaint);
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) => true;
}