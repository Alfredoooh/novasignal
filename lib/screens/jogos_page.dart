import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/match_card.dart';

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
    _loadJogos();

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
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _futureJogos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('A carregar jogos...'),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.error_rounded,
                        size: 100,
                        color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text('Erro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text('Não foi possível carregar os jogos. Tente novamente.'),
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
                        Icon(
                          Symbols.filter_alt_rounded,
                          size: 100,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text('Nenhum jogo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('Não há jogos para o filtro selecionado'),
                      ],
                    ),
                  );
                }
                return _buildJogosList(jogosFiltrados, context, appState);
              } else {
                return const Center(child: Text('Sem jogos'));
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
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
            'flag': jogo['country_logo'],
          },
          'jogos': [],
        };
      }
      jogosPorLiga[ligaId]['jogos'].add(jogo);
    }

    return ListView.builder(
      itemCount: jogosPorLiga.length,
      itemBuilder: (context, index) {
        var ligaData = jogosPorLiga.values.toList()[index];
        return Card(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  appState.setLigaDetalhes(ligaData['liga']['id'], ligaData['liga']['name']);
                  appState.navegarPara('liga-detalhes');
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          ligaData['liga']['logo'] ?? 'https://via.placeholder.com/40x40?text=🏆',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.network('https://via.placeholder.com/40x40?text=🏆', width: 40, height: 40),
                        ),
                      ),
                      if (ligaData['liga']['flag'] != null) const SizedBox(width: 12),
                      if (ligaData['liga']['flag'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            ligaData['liga']['flag'],
                            width: 24,
                            height: 18,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const SizedBox(),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ligaData['liga']['name'],
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              ligaData['liga']['country'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Symbols.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              ...ligaData['jogos'].map((jogo) => MatchCard(jogo: jogo)).toList(),
            ],
          ),
        );
      },
    );
  }
}