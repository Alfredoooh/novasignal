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

class _JogoDetalhesPageState extends State<JogoDetalhesPage> {
  Future<dynamic>? _futureJogo;

  @override
  void initState() {
    super.initState();
    _futureJogo = context.read<AppState>().carregarJogoDetalhes(widget.jogoId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureJogo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Erro ao carregar detalhes'));
        }

        final jogo = snapshot.data!;
        return _buildDetalhes(jogo);
      },
    );
  }

  Widget _buildDetalhes(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    final isLive = status.contains("'") || status == 'HT' || status == 'LIVE';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                jogo['league_name'] ?? '',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          jogo['team_home_badge'] ?? '',
                          width: 60,
                          height: 60,
                          errorBuilder: (_, __, ___) => Container(width: 60, height: 60),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jogo['match_hometeam_name'] ?? '',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${jogo['match_hometeam_score'] ?? '0'} : ${jogo['match_awayteam_score'] ?? '0'}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLive 
                              ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                              : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            if (isLive) ...[
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.error,
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
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          jogo['team_away_badge'] ?? '',
                          width: 60,
                          height: 60,
                          errorBuilder: (_, __, ___) => Container(width: 60, height: 60),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jogo['match_awayteam_name'] ?? '',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (jogo['goalscorer'] != null && jogo['goalscorer'].isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Gols', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: jogo['goalscorer'].map<Widget>((gol) {
                final scorer = gol['home_scorer'] ?? gol['away_scorer'] ?? 'N/A';
                final time = gol['time'] ?? '';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Symbols.sports_soccer_rounded, size: 20, color: Theme.of(context).colorScheme.tertiary),
                      const SizedBox(width: 12),
                      Expanded(child: Text(scorer, style: const TextStyle(fontSize: 14))),
                      Text('$time\'', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        if (jogo['cards'] != null && jogo['cards'].isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Cartões', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: jogo['cards'].map<Widget>((card) {
                final isYellow = card['card'] == 'yellow card';
                final player = card['home_fault'] ?? card['away_fault'] ?? 'N/A';
                final time = card['time'] ?? '';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isYellow ? const Color(0xFFFFD700) : const Color(0xFFDC143C),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(player, style: const TextStyle(fontSize: 14))),
                      Text('$time\'', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        if (jogo['statistics'] != null && jogo['statistics'].isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Estatísticas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: jogo['statistics'].map<Widget>((stat) {
                final home = double.tryParse(stat['home'] ?? '0') ?? 0;
                final away = double.tryParse(stat['away'] ?? '0') ?? 0;
                final total = home + away > 0 ? home + away : 1;
                final homePercent = home / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${home.toInt()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                          Text(stat['type'] ?? '', style: const TextStyle(fontSize: 12)),
                          Text('${away.toInt()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: (homePercent * 100).toInt(),
                              child: Container(height: 6, color: Theme.of(context).colorScheme.primary),
                            ),
                            Expanded(
                              flex: ((1 - homePercent) * 100).toInt(),
                              child: Container(height: 6, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}