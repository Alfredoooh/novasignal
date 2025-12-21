import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import 'jogo_detalhes_page.dart';

class LigaDetalhesPage extends StatefulWidget {
  final String ligaId;
  final Map<String, dynamic>? ligaData;
  final String? ligaNome;
  final String? ligaLogo;

  const LigaDetalhesPage({
    super.key,
    required this.ligaId,
    this.ligaData,
    this.ligaNome,
    this.ligaLogo,
  });

  @override
  State<LigaDetalhesPage> createState() => _LigaDetalhesPageState();
}

class _LigaDetalhesPageState extends State<LigaDetalhesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<List<dynamic>>? _futureJogos;
  Future<List<dynamic>>? _futureClassificacao;
  List<dynamic>? _cachedJogos;
  List<dynamic>? _cachedClassificacao;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLigaData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLigaData() {
    final appState = context.read<AppState>();
    setState(() {
      _futureJogos = appState.carregarJogosPorLiga(widget.ligaId);
      _futureClassificacao = appState.carregarClassificacao(widget.ligaId);
    });

    _futureJogos?.then((jogos) {
      if (mounted) {
        setState(() {
          _cachedJogos = jogos;
        });
      }
    });

    _futureClassificacao?.then((classificacao) {
      if (mounted) {
        setState(() {
          _cachedClassificacao = classificacao;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ligaData = widget.ligaData ??
        {
          'league_name': widget.ligaNome ?? 'Liga',
          'league_logo': widget.ligaLogo ?? '',
        };

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              stretch: true,
              leading: IconButton(
                icon: const Icon(Symbols.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  ligaData['league_name'] ?? 'Liga',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                  ),
                  child: Center(
                    child: ligaData['league_logo'] != null && ligaData['league_logo'].toString().isNotEmpty
                        ? Image.network(
                            ligaData['league_logo'],
                            width: 80,
                            height: 80,
                            errorBuilder: (_, __, ___) => Icon(
                              Symbols.emoji_events_rounded,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          )
                        : Icon(
                            Symbols.emoji_events_rounded,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Classificação'),
                    Tab(text: 'Jogos'),
                    Tab(text: 'Estatísticas'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildClassificacaoTab(),
            _buildJogosTab(),
            _buildEstatisticasTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildClassificacaoTab() {
    if (_cachedClassificacao != null) {
      return _buildClassificacaoContent(_cachedClassificacao!);
    }

    return FutureBuilder<List<dynamic>>(
      future: _futureClassificacao,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.table_chart_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                const Text('Classificação não disponível'),
              ],
            ),
          );
        }
        return _buildClassificacaoContent(snapshot.data!);
      },
    );
  }

  Widget _buildClassificacaoContent(List<dynamic> classificacao) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classificacao.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'Pos',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Clube',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'J',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'V',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'E',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'D',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(
                  width: 45,
                  child: Text(
                    'Pts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final time = classificacao[index - 1];
        final posicao = int.tryParse(time['overall_league_position']?.toString() ?? 
                        time['league_position']?.toString() ?? 
                        time['position']?.toString() ?? '0') ?? index;
        
        final jogos = int.tryParse(time['overall_league_payed']?.toString() ?? 
                                   time['matches_played']?.toString() ?? '0') ?? 0;
        final vitorias = int.tryParse(time['overall_league_W']?.toString() ?? 
                                      time['wins']?.toString() ?? '0') ?? 0;
        final empates = int.tryParse(time['overall_league_D']?.toString() ?? 
                                     time['draws']?.toString() ?? '0') ?? 0;
        final derrotas = int.tryParse(time['overall_league_L']?.toString() ?? 
                                      time['losses']?.toString() ?? '0') ?? 0;
        final pontos = int.tryParse(time['overall_league_PTS']?.toString() ?? 
                                    time['points']?.toString() ?? '0') ?? 0;
        
        Color? posicaoColor;
        Color? borderColor;

        if (posicao <= 4) {
          posicaoColor = Colors.green.withOpacity(0.15);
          borderColor = Colors.green;
        } else if (posicao <= 6) {
          posicaoColor = Colors.orange.withOpacity(0.15);
          borderColor = Colors.orange;
        } else if (posicao >= classificacao.length - 2) {
          posicaoColor = Colors.red.withOpacity(0.15);
          borderColor = Colors.red;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: posicaoColor ?? Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 0.5,
              ),
              left: borderColor != null
                  ? BorderSide(color: borderColor, width: 4)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '$posicao',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    if ((time['team_badge'] ?? time['logo'] ?? '').toString().isNotEmpty) ...[
                      Image.network(
                        time['team_badge'] ?? time['logo'],
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 28),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        time['team_name']?.toString() ?? time['name']?.toString() ?? 'Unknown',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(
                  '$jogos',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(
                  '$vitorias',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(
                  '$empates',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(
                  '$derrotas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(
                width: 45,
                child: Text(
                  '$pontos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJogosTab() {
    if (_cachedJogos != null) {
      return _buildJogosContent(_cachedJogos!);
    }

    return FutureBuilder<List<dynamic>>(
      future: _futureJogos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.sports_soccer_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                const Text('Nenhum jogo disponível'),
              ],
            ),
          );
        }
        return _buildJogosContent(snapshot.data!);
      },
    );
  }

  Widget _buildJogosContent(List<dynamic> jogos) {
    final jogosSorted = List<dynamic>.from(jogos)
      ..sort((a, b) {
        final dateA = a['match_date'] ?? '';
        final dateB = b['match_date'] ?? '';
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jogosSorted.length,
      itemBuilder: (context, index) {
        final jogo = jogosSorted[index];
        final status = jogo['match_status'] ?? '';
        final isLive = status.contains("'") || status == 'LIVE';
        final isFinished = status.contains('Finished') || status == 'FT';

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => JogoDetalhesPage(jogoId: jogo['match_id']),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLive 
                    ? Colors.red 
                    : Theme.of(context).dividerColor.withOpacity(0.2),
                width: isLive ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${jogo['match_date']} • ${jogo['match_time']}',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLive
                            ? Colors.red
                            : isFinished
                                ? Theme.of(context).colorScheme.surfaceContainerHighest
                                : Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formatarStatus(status),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
                            errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 32),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              jogo['match_hometeam_name'] ?? '',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                              jogo['match_awayteam_name'] ?? '',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.network(
                            jogo['team_away_badge'] ?? '',
                            width: 32,
                            height: 32,
                            errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEstatisticasTab() {
    if (_cachedClassificacao == null) {
      return FutureBuilder<List<dynamic>>(
        future: _futureClassificacao,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Sem dados disponíveis'));
          }
          return _buildEstatisticasContent(snapshot.data!);
        },
      );
    }
    return _buildEstatisticasContent(_cachedClassificacao!);
  }

  Widget _buildEstatisticasContent(List<dynamic> classificacao) {
    if (classificacao.isEmpty) {
      return const Center(child: Text('Sem dados de estatísticas'));
    }

    final top3 = classificacao.take(3).toList();
    final bottom3 = classificacao.skip(classificacao.length - 3).take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 3 Clubes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildPodium(top3),
          const SizedBox(height: 32),
          Text(
            'Zona de Rebaixamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...bottom3.asMap().entries.map((entry) {
            final time = entry.value;
            final pos = classificacao.length - 2 + entry.key;
            return _buildBottomTeamCard(time, pos);
          }),
        ],
      ),
    );
  }

  Widget _buildPodium(List<dynamic> top3) {
    if (top3.length < 3) return const SizedBox();

    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/podium.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // 2º Lugar (Esquerda)
          Positioned(
            left: 20,
            bottom: 80,
            child: _buildPodiumTeam(top3[1], 2, 70),
          ),
          // 1º Lugar (Centro)
          Positioned(
            left: 0,
            right: 0,
            bottom: 120,
            child: _buildPodiumTeam(top3[0], 1, 80),
          ),
          // 3º Lugar (Direita)
          Positioned(
            right: 20,
            bottom: 60,
            child: _buildPodiumTeam(top3[2], 3, 60),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumTeam(Map<String, dynamic> time, int posicao, double size) {
    final pontos = int.tryParse(time['overall_league_PTS']?.toString() ?? 
                                time['points']?.toString() ?? '0') ?? 0;
    
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: posicao == 1 ? Colors.amber : posicao == 2 ? Colors.grey.shade400 : Colors.brown,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: (time['team_badge'] ?? time['logo'] ?? '').toString().isNotEmpty
                ? Image.network(
                    time['team_badge'] ?? time['logo'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.shield, size: size * 0.6),
                  )
                : Icon(Icons.shield, size: size * 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                time['team_name']?.toString() ?? time['name']?.toString() ?? '',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$pontos pts',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTeamCard(Map<String, dynamic> time, int posicao) {
    final pontos = int.tryParse(time['overall_league_PTS']?.toString() ?? 
                                time['points']?.toString() ?? '0') ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Row(
        children: [
          Text(
            '$posicao',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.red),
          ),
          const SizedBox(width: 16),
          if ((time['team_badge'] ?? time['logo'] ?? '').toString().isNotEmpty)
            Image.network(
              time['team_badge'] ?? time['logo'],
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 40),
            )
          else
            const Icon(Icons.shield, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              time['team_name']?.toString() ?? time['name']?.toString() ?? '',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$pontos pts',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}