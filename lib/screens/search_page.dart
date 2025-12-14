import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<dynamic>>? _searchResults;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = null;
      });
      return;
    }
    setState(() {
      _searchResults = context.read<AppState>().pesquisarJogos(query.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Pesquisar times ou ligas',
                leading: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Symbols.search_rounded),
                ),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Symbols.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = null;
                        });
                      },
                    ),
                ],
                onChanged: _performSearch,
                elevation: const MaterialStatePropertyAll(1),
                backgroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                side: MaterialStatePropertyAll(
                  BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                padding: const MaterialStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_searchResults == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.search_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Pesquisar Jogos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Digite o nome de um time ou liga',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
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
                Text('Erro ao pesquisar', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text('${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.search_off_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum resultado encontrado',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        final jogos = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: jogos.length,
          itemBuilder: (context, index) {
            return _buildMatchItem(jogos[index]);
          },
        );
      },
    );
  }

  Widget _buildMatchItem(dynamic jogo) {
    final appState = context.read<AppState>();
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

    return InkWell(
      onTap: () {
        appState.setJogoDetalhes(jogo['match_id'], '');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => JogoDetalhesPage(jogoId: jogo['match_id']),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Symbols.emoji_events_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${jogo['league_name'] ?? ''} • ${jogo['match_date'] ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatarStatus(status),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
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
                        errorBuilder: (_, __, ___) => Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                        ),
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
                        errorBuilder: (_, __, ___) => Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
    );
  }
}