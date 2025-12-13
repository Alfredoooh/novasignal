import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../utils/formatters.dart';

class MatchCard extends StatelessWidget {
  final dynamic jogo;
  final bool showLeague;

  const MatchCard({
    super.key,
    required this.jogo,
    this.showLeague = false,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final status = jogo['match_status'] ?? '';
    Color badgeColor;
    String badgeText = formatarStatus(status);
    
    if (status.contains('Finished') || status == 'FT' || status == 'AET') {
      badgeColor = Theme.of(context).colorScheme.tertiary;
    } else if (status.contains("'") || status == 'HT' || status == 'LIVE') {
      badgeColor = Theme.of(context).colorScheme.error;
    } else {
      badgeColor = Theme.of(context).colorScheme.secondary;
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            appState.setJogoDetalhes(
              jogo['match_id'],
              '${jogo['match_hometeam_name']} vs ${jogo['match_awayteam_name']}',
            );
            appState.navegarPara('jogo-detalhes');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.schedule_rounded,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          jogo['match_time'] ?? '--:--',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              jogo['team_home_badge'] ?? 'https://via.placeholder.com/40x40?text=⚽',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.network('https://via.placeholder.com/40x40?text=⚽', width: 40, height: 40),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              jogo['match_hometeam_name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
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
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              jogo['team_away_badge'] ?? 'https://via.placeholder.com/40x40?text=⚽',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.network('https://via.placeholder.com/40x40?text=⚽', width: 40, height: 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showLeague) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.emoji_events_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${jogo['league_name'] ?? ''} • ${jogo['country_name'] ?? ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}