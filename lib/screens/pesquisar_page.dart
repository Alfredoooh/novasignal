import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/match_card.dart';

class PesquisarPage extends StatefulWidget {
  const PesquisarPage({super.key});

  @override
  State<PesquisarPage> createState() => _PesquisarPageState();
}

class _PesquisarPageState extends State<PesquisarPage> {
  final TextEditingController _controller = TextEditingController();
  Future<List<dynamic>>? _futureResultados;
  String _currentTerm = '';

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Symbols.search_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Symbols.close_rounded, size: 20),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _futureResultados = null;
                        });
                      },
                    )
                  : null,
              hintText: 'Pesquisar jogos, clubes ou ligas...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            onChanged: (value) {
              if (value.trim().length < 2) {
                setState(() {
                  _futureResultados = null;
                });
                return;
              }
              _currentTerm = value.trim();
              _futureResultados = context.read<AppState>().executarPesquisa(_currentTerm);
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: _futureResultados == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Symbols.search_rounded,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Pesquisar',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Digite para pesquisar jogos ou clubes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
                            Icon(
                              Symbols.error_rounded,
                              size: 100,
                              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text('Erro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            const Text('Erro ao realizar pesquisa. Tente novamente.'),
                          ],
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Symbols.search_off_rounded,
                              size: 100,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text('Nenhum resultado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text('Nenhum resultado encontrado para "$_currentTerm"'),
                          ],
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final resultados = snapshot.data!;
                      Map<String, List<dynamic>> jogosPorData = {};
                      for (var jogo in resultados) {
                        String data = jogo['match_date'] ?? 'Data desconhecida';
                        jogosPorData.putIfAbsent(data, () => []);
                        jogosPorData[data]!.add(jogo);
                      }
                      final sortedDates = jogosPorData.keys.toList()..sort((a, b) => b.compareTo(a));
                      return ListView.builder(
                        itemCount: sortedDates.length,
                        itemBuilder: (context, index) {
                          final data = sortedDates[index];
                          final jogosDaData = jogosPorData[data]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  data,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Card(
                                child: Column(
                                  children: jogosDaData
                                      .map((jogo) => MatchCard(jogo: jogo, showLeague: true))
                                      .toList(),
                                ),
                              ),
                            ],
                          );
                        },
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
}