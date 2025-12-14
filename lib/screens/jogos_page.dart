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

  @override
  void initState() {
    super.initState();
    _loadJogos();
  }

  void _loadJogos() {
    final appState = context.read<AppState>();
    _futureJogos = appState.carregarJogosDoDia(appState.dataSelecionada);
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
                  context: context,
                  label: 'Hoje',
                  icon: Symbols.today_rounded,
                  isSelected: appState.filtroJogos == 'hoje',
                  onSelected: () => appState.filtrarJogos('hoje'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: 'Ao Vivo',
                  icon: Symbols.circle_rounded,
                  isSelected: appState.filtroJogos == 'direto',
                  onSelected: () => appState.filtrarJogos('direto'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: 'Terminados',
                  icon: Symbols.check_circle_rounded,
                  isSelected: appState.filtroJogos == 'terminados',
                  onSelected: () => appState.filtrarJogos('terminados'),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 0.5,
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
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
                      Icon(Symbols.error_rounded, size: 64, color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text('Erro ao carregar jogos'),
                    ],
                  ),
                );
              } else if (snapshot.hasData) {
                final jogos = snapshot.data!;
                final jogosFiltrados = _filtrarJogos(jogos, appState.filtroJogos);
                if (jogosFiltrados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Symbols.sports_soccer_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text('Nenhum jogo disponível'),
                      ],
                    ),
                  );
                }
                return _buildJogosList(jogosFiltrados, context, appState);
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
          return status.contains("'") || status == 'HT' || status == 'PEN' || status == 'LIVE';
        }).toList();
      case 'terminados':
        return jogos.where((j) {
          final status = j['match_status'] ?? '';
          return status.contains('Finished') || status == 'FT' || status == 'AET' || status == 'FT_PEN';
        }).toList();
      default:
        return jogos;
    }
  }

  Widget _buildJogosList(List<dynamic> jogosFiltrados, BuildContext context, AppState appState) {
    Map<String, dynamic> jogosPorLiga = {};
    for (var jogo in jogosFiltrados) {
      String ligaId = jogo['league_id'] ?? 'unknown';
      if (!jogosPorLiga.containsKey(ligaId)) {
        jogosPorLiga[ligaId] = {
          'liga': {
            'id': ligaId,
            'name': jogo['league_name'] ?? 'Unknown',
            'logo': jogo['league_logo'],
            'country': jogo['country_name'] ?? 'Unknown',
          },
          'jogos': [],
        };
      }
      jogosPorLiga[ligaId]['jogos'].add(jogo);
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: jogosPorLiga.length,
      itemBuilder: (context, index) {
        var ligaData = jogosPorLiga.values.toList()[index];
        return Container(
          color: Theme.of(context).colorScheme.surface,
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  appState.setLigaDetalhes(ligaData['liga']['id'], ligaData['liga']['name']);
                  appState.navegarPara('liga-detalhes');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          ligaData['liga']['logo'] ?? 'https://via.placeholder.com/32',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            width: 32,
                            height: 32,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Icon(Symbols.emoji_events_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ligaData['liga']['name'],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              ligaData['liga']['country'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(Symbols.chevron_right_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              Container(height: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.3)),
              ...ligaData['jogos'].map((jogo) => _buildMatchWidget(jogo, context, appState)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchWidget(dynamic jogo, BuildContext context, AppState appState) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';
    
    Color badgeColor;
    if (status.contains('Finished') || status == 'FT' || status == 'AET') {
      badgeColor = Theme.of(context).colorScheme.tertiary;
    } else if (isLive) {
      badgeColor = Theme.of(context).colorScheme.error;
    } else {
      badgeColor = Theme.of(context).colorScheme.secondary;
    }

    return InkWell(
      onTap: () {
        appState.setJogoDetalhes(jogo['match_id'], '');
        appState.navegarPara('jogo-detalhes');
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Symbols.schedule_rounded, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(jogo['match_time'] ?? '--:--', style: Theme.of(context).textTheme.bodySmall),
                        if (isLive) ...[
                          const SizedBox(width: 8),
                          _buildLiveIndicator(),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formatarStatus(status),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor),
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
                            jogo['team_home_badge'] ?? 'https://via.placeholder.com/36',
                            width: 36,
                            height: 36,
                            errorBuilder: (_, __, ___) => Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              jogo['match_hometeam_name'] ?? 'Unknown',
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
                          fontSize: 20,
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
                              jogo['match_awayteam_name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.network(
                            jogo['team_away_badge'] ?? 'https://via.placeholder.com/36',
                            width: 36,
                            height: 36,
                            errorBuilder: (_, __, ___) => Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }
}