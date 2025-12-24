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
    final cs = Theme.of(context).colorScheme;
    final status = jogo['match_status'] ?? '';
    
    Color badgeColor;
    String badgeText = formatarStatus(status);

    if (status.contains('Finished') || status == 'FT' || status == 'AET') {
      badgeColor = cs.tertiary;
    } else if (status.contains("'") || status == 'HT' || status == 'LIVE') {
      badgeColor = cs.error;
    } else {
      badgeColor = cs.secondary;
    }

    // Obter logos das equipes da API
    final homeTeamLogo = jogo['team_home_badge']?.toString() ?? '';
    final awayTeamLogo = jogo['team_away_badge']?.toString() ?? '';
    final homeTeamName = jogo['match_hometeam_name']?.toString() ?? 'Unknown';
    final awayTeamName = jogo['match_awayteam_name']?.toString() ?? 'Unknown';
    final homeScore = jogo['match_hometeam_score']?.toString() ?? '-';
    final awayScore = jogo['match_awayteam_score']?.toString() ?? '-';

    return Column(
      children: [
        InkWell(
          onTap: () {
            appState.setJogoDetalhes(
              jogo['match_id'],
              '$homeTeamName vs $awayTeamName',
            );
            appState.navegarPara('jogo-detalhes');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Cabeçalho: Hora e Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.schedule_rounded,
                          size: 14,
                          color: cs.onSurfaceVariant,
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
                
                // Corpo: Times e Placar
                Row(
                  children: [
                    // Time da Casa
                    Expanded(
                      child: Row(
                        children: [
                          _buildTeamLogo(homeTeamLogo, cs),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              homeTeamName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Placar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$homeScore : $awayScore',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    
                    // Time Visitante
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              awayTeamName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildTeamLogo(awayTeamLogo, cs),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Rodapé: Liga (se showLeague = true)
                if (showLeague) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.emoji_events_rounded,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${jogo['league_name'] ?? ''} • ${jogo['country_name'] ?? ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  Widget _buildTeamLogo(String logoUrl, ColorScheme cs) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: cs.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: logoUrl.isNotEmpty
            ? Image.network(
                logoUrl,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildPlaceholderLogo(cs),
              )
            : _buildPlaceholderLogo(cs),
      ),
    );
  }

  Widget _buildPlaceholderLogo(ColorScheme cs) {
    return Container(
      width: 40,
      height: 40,
      color: cs.surfaceContainerHighest,
      child: Icon(
        Symbols.shield_rounded,
        size: 24,
        color: cs.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }
}