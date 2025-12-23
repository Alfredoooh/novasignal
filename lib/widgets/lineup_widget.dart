import 'package:flutter/material.dart';

class LineupTab extends StatelessWidget {
  final List<Map<String, dynamic>> lineupHome;
  final List<Map<String, dynamic>> lineupAway;
  final Map<String, dynamic> jogo;

  const LineupTab({
    super.key,
    required this.lineupHome,
    required this.lineupAway,
    required this.jogo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (lineupHome.isEmpty && lineupAway.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Formações não disponíveis',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if ((jogo['match_hometeam_system'] ?? '').toString().isNotEmpty ||
              (jogo['match_awayteam_system'] ?? '').toString().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Formações Táticas',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if ((jogo['match_hometeam_system'] ?? '').toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            jogo['match_hometeam_name'] ?? '',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            jogo['match_hometeam_system'],
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if ((jogo['match_awayteam_system'] ?? '').toString().isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          jogo['match_awayteam_name'] ?? '',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          jogo['match_awayteam_system'],
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (lineupHome.isNotEmpty) ...[
            _buildTeamLineup(
              context: context,
              players: lineupHome,
              teamBadge: jogo['team_home_badge'],
              teamName: jogo['match_hometeam_name'] ?? 'Casa',
              primaryColor: cs.primary,
              cs: cs,
            ),
            const SizedBox(height: 16),
          ],
          if (lineupAway.isNotEmpty) ...[
            _buildTeamLineup(
              context: context,
              players: lineupAway,
              teamBadge: jogo['team_away_badge'],
              teamName: jogo['match_awayteam_name'] ?? 'Fora',
              primaryColor: Colors.green,
              cs: cs,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamLineup({
    required BuildContext context,
    required List<Map<String, dynamic>> players,
    required String? teamBadge,
    required String teamName,
    required Color primaryColor,
    required ColorScheme cs,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              if (teamBadge != null)
                Image.network(
                  teamBadge,
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 32, color: primaryColor),
                ),
              const SizedBox(width: 12),
              Text(
                teamName,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...players.map((p) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      p['lineup_number']?.toString() ?? '0',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['lineup_player']?.toString() ?? '-',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (p['lineup_position'] != null)
                        Text(
                          p['lineup_position'].toString(),
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}