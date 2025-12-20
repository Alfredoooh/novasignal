import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'dart:math' show cos, sin, pi;

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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: const Color(0xFF000000),
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Detalhes', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: AnimatedBuilder(
              animation: _loadingController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ExpressiveProgressPainter(
                    progress: _loadingController.value,
                    color: const Color(0xFFFF6B35),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    if (_jogo == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: const Color(0xFF000000),
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Detalhes', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.error_rounded,
                size: 64,
                color: Colors.red.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text('Erro ao carregar detalhes', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return _buildDetalhes(_jogo!);
  }

  Widget _buildDetalhes(Map<String, dynamic> jogo) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: CustomScrollView(
        slivers: [
          // App Bar com Header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF1C1C1E),
            leading: IconButton(
              icon: const Icon(Symbols.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Symbols.share_rounded, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Symbols.star_outline_rounded, color: Colors.white),
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
                      const Color(0xFF1C1C1E),
                      const Color(0xFF000000).withOpacity(0.8),
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
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
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
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.shield,
                                    size: 64,
                                    color: Color(0xFFFF6B35),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  jogo['match_hometeam_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isLive 
                                        ? const Color(0xFFFF3B30).withOpacity(0.2)
                                        : const Color(0xFF2C2C2E),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isLive) ...[
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF3B30),
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
                                          color: isLive 
                                              ? const Color(0xFFFF3B30)
                                              : const Color(0xFF8E8E93),
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
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.shield,
                                    size: 64,
                                    color: Color(0xFFFF6B35),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  jogo['match_awayteam_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tabs de navegação
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              child: Container(
                color: const Color(0xFF000000),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      color: const Color(0xFF2C2C2E),
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
              color: const Color(0xFF000000),
              child: _buildTabContent(jogo),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          border: Border(top: BorderSide(color: Color(0xFF2C2C2E), width: 1)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Começar Aposta',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String value, String label) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF8E8E93),
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
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1459865264687-595d652de67e?w=800'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Symbols.play_arrow_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            const Text(
              'Live Stream',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(Map<String, dynamic> jogo) {
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
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
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
      eventIcon = const Icon(Symbols.sports_soccer_rounded, size: 20, color: Colors.white);
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
          color: const Color(0xFFFF3B30),
          borderRadius: BorderRadius.circular(3),
        ),
      );
      eventColor = const Color(0xFFFF3B30);
    } else {
      eventIcon = const Icon(Symbols.swap_horiz_rounded, size: 20, color: Color(0xFF007AFF));
      eventColor = const Color(0xFF007AFF);
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
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(child: icon),
        ),
        const SizedBox(height: 4),
        Text(
          '$time\'',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8E8E93),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: isHome ? TextAlign.right : TextAlign.left,
          ),
          if (event['assist'].toString().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Assistência: ${event['assist']}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8E8E93),
              ),
              textAlign: isHome ? TextAlign.right : TextAlign.left,
            ),
          ],
          const SizedBox(height: 2),
          Text(
            event['score'],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF34C759),
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
                const Icon(Symbols.arrow_upward_rounded, size: 16, color: Color(0xFF34C759)),
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
                const Icon(Symbols.arrow_downward_rounded, size: 16, color: Color(0xFFFF3B30)),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  event['playerOut'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFFF3B30),
                  ),
                  textAlign: isHome ? TextAlign.right : TextAlign.left,
                ),
              ),
              if (isHome) ...[
                const SizedBox(width: 4),
                const Icon(Symbols.arrow_downward_rounded, size: 16, color: Color(0xFFFF3B30)),
              ],
            ],
          ),
        ],
      );
    } else {
      return Text(
        event['player'],
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: isHome ? TextAlign.right : TextAlign.left,
      );
    }
  }

  Widget _buildInfoCard(Map<String, dynamic> jogo) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF8E8E93)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
    if (jogo['statistics'] == null || (jogo['statistics'] as List).isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Estatísticas não disponíveis',
            style: TextStyle(color: Color(0xFF8E8E93)),
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
              color: const Color(0xFF1C1C1E),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: _PieChartPainter(
                homeValue: home,
                awayValue: away,
                homeColor: const Color(0xFF007AFF),
                awayColor: const Color(0xFF34C759),
                backgroundColor: const Color(0xFF1C1C1E),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${home.toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF007AFF),
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
                color: isHome ? const Color(0xFF007AFF) : const Color(0xFFFF3B30),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'Histórico H2H não disponível',
          style: TextStyle(color: Color(0xFF8E8E93)),
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
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;