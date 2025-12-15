import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';

class JogosPage extends StatefulWidget {
  const JogosPage({super.key});

  @override
  State<JogosPage> createState() => _JogosPageState();
}

class _JogosPageState extends State<JogosPage> {
  Future<List<dynamic>>? _futureJogos;

  final Map<String, String> _leagueLogos = {
    'Premier League': 'https://upload.wikimedia.org/wikipedia/en/f/f2/Premier_League_Logo.svg',
    'La Liga': 'https://upload.wikimedia.org/wikipedia/commons/1/13/LaLiga_EA_Sports_2023_Vertical_Logo.svg',
    'Serie A': 'https://upload.wikimedia.org/wikipedia/commons/d/d2/Serie_A_logo_2022.svg',
    'Bundesliga': 'https://upload.wikimedia.org/wikipedia/en/d/df/Bundesliga_logo_%282017%29.svg',
    'Ligue 1': 'https://upload.wikimedia.org/wikipedia/commons/5/5e/Ligue1.svg',
    'UEFA Champions League': 'https://upload.wikimedia.org/wikipedia/en/b/bf/UEFA_Champions_League_logo_2.svg',
    'UEFA Europa League': 'https://upload.wikimedia.org/wikipedia/en/6/67/UEFA_Europa_League_logo.svg',
  };

  @override
  void initState() {
    super.initState();
    _loadJogos();
  }

  @override
  void didUpdateWidget(JogosPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadJogos();
  }

  void _loadJogos() {
    final appState = context.read<AppState>();
    setState(() {
      _futureJogos = appState.carregarJogosDoDia(appState.dataSelecionada);
    });
  }

  void _showMatchModal(dynamic jogo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMatchModal(jogo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Hoje',
                  icon: Symbols.today_rounded,
                  isSelected: appState.filtroJogos == 'hoje',
                  onSelected: () => appState.filtrarJogos('hoje'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Ao Vivo',
                  icon: Symbols.circle_rounded,
                  isSelected: appState.filtroJogos == 'direto',
                  onSelected: () => appState.filtrarJogos('direto'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Terminados',
                  icon: Symbols.check_circle_rounded,
                  isSelected: appState.filtroJogos == 'terminados',
                  onSelected: () => appState.filtrarJogos('terminados'),
                ),
              ],
            ),
          ),
        ),
        Container(height: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.1)),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _futureJogos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.error_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text('Erro ao carregar jogos'),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _loadJogos,
                        icon: const Icon(Symbols.refresh_rounded),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Erro ao carregar jogos'));
              }

              final jogos = snapshot.data!;
              final jogosFiltrados = _filtrarJogos(jogos, appState.filtroJogos);

              if (jogosFiltrados.isEmpty) {
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

              return _buildJogosList(jogosFiltrados);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _filtrarJogos(List<dynamic> jogos, String filtro) {
    switch (filtro) {
      case 'direto':
        return jogos.where((j) {
          final status = j['match_status'] ?? '';
          return status.contains("'") || status == 'HT' || status == 'LIVE';
        }).toList();
      case 'terminados':
        return jogos.where((j) {
          final status = j['match_status'] ?? '';
          return status.contains('Finished') || status == 'FT' || status == 'AET';
        }).toList();
      default:
        return jogos;
    }
  }

  Widget _buildJogosList(List<dynamic> jogos) {
    Map<String, List<dynamic>> jogosPorLiga = {};
    List<String> ligasOrdenadas = [];

    for (var jogo in jogos) {
      String ligaNome = jogo['league_name'] ?? 'Outras';
      if (!jogosPorLiga.containsKey(ligaNome)) {
        jogosPorLiga[ligaNome] = [];
        ligasOrdenadas.add(ligaNome);
      }
      jogosPorLiga[ligaNome]!.add(jogo);
    }

    ligasOrdenadas.sort((a, b) {
      final aHasLogo = _leagueLogos.containsKey(a);
      final bHasLogo = _leagueLogos.containsKey(b);
      if (aHasLogo && !bHasLogo) return -1;
      if (!aHasLogo && bHasLogo) return 1;
      return a.compareTo(b);
    });

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: ligasOrdenadas.length,
      itemBuilder: (context, index) {
        final ligaNome = ligasOrdenadas[index];
        final jogosLiga = jogosPorLiga[ligaNome]!;
        final leagueLogo = _leagueLogos[ligaNome];

        return Container(
          color: Theme.of(context).colorScheme.surface,
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (leagueLogo != null) ...[
                      Image.network(
                        leagueLogo,
                        width: 24,
                        height: 24,
                        errorBuilder: (_, __, ___) => Icon(Symbols.emoji_events_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                    ] else ...[
                      Icon(Symbols.emoji_events_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        ligaNome,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: leagueLogo != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '${jogosLiga.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ...jogosLiga.map((jogo) => _buildMatchItem(jogo)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchItem(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

    return InkWell(
      onTap: () => _showMatchModal(jogo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(jogo['match_time'] ?? '--:--', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    if (isLive) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: getStatusColor(status, context),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  formatarStatus(status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: getStatusColor(status, context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.network(
                        jogo['team_home_badge'] ?? '',
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) => Container(width: 32, height: 32),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          jogo['match_hometeam_name'] ?? '',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Image.network(
                        jogo['team_away_badge'] ?? '',
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) => Container(width: 32, height: 32),
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
  }

  Widget _buildMatchModal(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    jogo['league_name'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(status, context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    formatarStatus(status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: getStatusColor(status, context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            jogo['match_hometeam_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            '${jogo['match_hometeam_score'] ?? '0'} : ${jogo['match_awayteam_score'] ?? '0'}',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${jogo['match_date']} • ${jogo['match_time']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            jogo['match_awayteam_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final appState = context.read<AppState>();
                      appState.setJogoDetalhes(jogo['match_id'], '');
                      appState.navegarPara('jogo-detalhes');
                    },
                    icon: const Icon(Symbols.info_rounded),
                    label: const Text('Ver Detalhes Completos'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}