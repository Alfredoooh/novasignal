import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';

class PesquisarPage extends StatefulWidget {
  const PesquisarPage({super.key});

  @override
  State<PesquisarPage> createState() => _PesquisarPageState();
}

class _PesquisarPageState extends State<PesquisarPage> {
  final TextEditingController _controller = TextEditingController();
  Future<List<dynamic>>? _futureResultados;
  String _currentTerm = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Symbols.search_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Symbols.close_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                _controller.clear();
                                setState(() {
                                  _futureResultados = null;
                                  _isSearching = false;
                                });
                              },
                            )
                          : null,
                      hintText: 'Pesquisar clubes...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isSearching = value.isNotEmpty;
                      });
                      if (value.trim().length < 2) {
                        setState(() {
                          _futureResultados = null;
                        });
                        return;
                      }
                      _currentTerm = value.trim();
                      _futureResultados = context.read<AppState>().executarPesquisaClube(_currentTerm);
                      setState(() {});
                    },
                  ),
                ),
              ),
              if (_isSearching) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    _controller.clear();
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _futureResultados = null;
                      _isSearching = false;
                    });
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ],
          ),
        ),
        Container(height: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.3)),
        Expanded(
          child: _futureResultados == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Symbols.search_rounded,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Pesquisar Clubes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Digite o nome do clube para ver seus jogos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : FutureBuilder<List<dynamic>>(
                  future: _futureResultados,
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
                            const Text('Erro ao pesquisar'),
                          ],
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Symbols.search_off_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text('Nenhum resultado para "$_currentTerm"'),
                          ],
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final resultados = snapshot.data!;
                      
                      // Separar em próximos e anteriores
                      final agora = DateTime.now();
                      final proximos = resultados.where((jogo) {
                        try {
                          final dataJogo = DateTime.parse(jogo['match_date']);
                          return dataJogo.isAfter(agora) || dataJogo.isAtSameMomentAs(agora);
                        } catch (_) {
                          return false;
                        }
                      }).toList();
                      
                      final anteriores = resultados.where((jogo) {
                        try {
                          final dataJogo = DateTime.parse(jogo['match_date']);
                          return dataJogo.isBefore(agora);
                        } catch (_) {
                          return true;
                        }
                      }).toList()..sort((a, b) => (b['match_date'] ?? '').compareTo(a['match_date'] ?? ''));

                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (proximos.isNotEmpty) ...[
                            _buildSectionHeader('Próximos Jogos', proximos.length),
                            Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: Column(
                                children: proximos.map((jogo) => _buildMatchItem(jogo)).toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (anteriores.isNotEmpty) ...[
                            _buildSectionHeader('Jogos Anteriores', anteriores.length),
                            Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: Column(
                                children: anteriores.map((jogo) => _buildMatchItem(jogo)).toList(),
                              ),
                            ),
                          ],
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.background,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchItem(dynamic jogo) {
    final appState = context.read<AppState>();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Symbols.emoji_events_rounded, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${jogo['league_name'] ?? ''} • ${jogo['match_date'] ?? ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
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
                            jogo['team_home_badge'] ?? 'https://via.placeholder.com/32',
                            width: 32,
                            height: 32,
                            errorBuilder: (_, __, ___) => Container(
                              width: 32,
                              height: 32,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                              jogo['match_awayteam_name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.network(
                            jogo['team_away_badge'] ?? 'https://via.placeholder.com/32',
                            width: 32,
                            height: 32,
                            errorBuilder: (_, __, ___) => Container(
                              width: 32,
                              height: 32,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
}
