import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';

class LigasPage extends StatefulWidget {
  const LigasPage({super.key});

  @override
  State<LigasPage> createState() => _LigasPageState();
}

class _LigasPageState extends State<LigasPage> {
  Future<List<dynamic>>? _futureLigas;

  @override
  void initState() {
    super.initState();
    _futureLigas = context.read<AppState>().carregarLigas();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureLigas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('A carregar ligas...'),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.error_rounded, size: 100, color: Colors.grey),
                Text('Erro'),
                Text('Não foi possível carregar as ligas.'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final ligas = snapshot.data!;
          Map<String, List<dynamic>> ligasPorPais = {};
          for (var liga in ligas) {
            String pais = liga['country_name'] ?? 'Outros';
            ligasPorPais.putIfAbsent(pais, () => []);
            ligasPorPais[pais]!.add(liga);
          }
          final sortedPaises = ligasPorPais.keys.toList()..sort();
          return ListView.builder(
            itemCount: sortedPaises.length,
            itemBuilder: (context, index) {
              final pais = sortedPaises[index];
              final ligasDoPais = ligasPorPais[pais]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(Symbols.location_on_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(pais, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: ligasDoPais.map((liga) => _buildLeagueItem(liga, context)).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          return const Center(child: Text('Sem ligas'));
        }
      },
    );
  }

  Widget _buildLeagueItem(dynamic liga, BuildContext context) {
    final appState = context.read<AppState>();
    return Column(
      children: [
        InkWell(
          onTap: () {
            appState.setLigaDetalhes(liga['league_id'], liga['league_name']);
            appState.navegarPara('liga-detalhes');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    liga['league_logo'] ?? 'https://via.placeholder.com/40x40?text=🏆',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => 
                        Image.network('https://via.placeholder.com/40x40?text=🏆', width: 40, height: 40),
                  ),
                ),
                if (liga['country_logo'] != null) const SizedBox(width: 12),
                if (liga['country_logo'] != null)
                  Image.network(
                    liga['country_logo'],
                    width: 24,
                    height: 18,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liga['league_name'] ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(liga['country_name'] ?? 'Unknown', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Symbols.chevron_right_rounded),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }