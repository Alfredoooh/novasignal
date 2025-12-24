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

  String _getFormationImage(String? formation) {
    if (formation == null || formation.isEmpty) return '';
    
    // Mapeia formações para seus respectivos PNGs
    final formationMap = {
      '4-4-2': 'assets/formations/442.png',
      '4-3-3': 'assets/formations/433.png',
      '3-5-2': 'assets/formations/352.png',
      '4-2-3-1': 'assets/formations/4231.png',
      '4-1-4-1': 'assets/formations/4141.png',
      '3-4-3': 'assets/formations/343.png',
      '5-3-2': 'assets/formations/532.png',
      '4-5-1': 'assets/formations/451.png',
    };
    
    return formationMap[formation] ?? '';
  }

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
          if (lineupHome.isNotEmpty) ...[
            _buildTeamLineup(
              context: context,
              players: lineupHome,
              teamBadge: jogo['team_home_badge'],
              teamName: jogo['match_hometeam_name'] ?? 'Casa',
              formation: jogo['match_hometeam_system'],
              primaryColor: cs.primary,
              cs: cs,
            ),
          ],
          if (lineupHome.isNotEmpty && lineupAway.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: cs.outlineVariant, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: cs.outlineVariant, thickness: 1),
                  ),
                ],
              ),
            ),
          ],
          if (lineupAway.isNotEmpty) ...[
            _buildTeamLineup(
              context: context,
              players: lineupAway,
              teamBadge: jogo['team_away_badge'],
              teamName: jogo['match_awayteam_name'] ?? 'Fora',
              formation: jogo['match_awayteam_system'],
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
    required String? formation,
    required Color primaryColor,
    required ColorScheme cs,
  }) {
    final formationImage = _getFormationImage(formation);

    return Column(
      children: [
        // Cabeçalho da equipa
        Row(
          children: [
            if (teamBadge != null)
              Image.network(
                teamBadge,
                width: 36,
                height: 36,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shield,
                  size: 36,
                  color: primaryColor,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                teamName,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            if (formation != null && formation.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formation,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Campo visual com formação
        if (formationImage.isNotEmpty)
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(formationImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Lista de jogadores em um único card
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jogadores Titulares',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              ...players.asMap().entries.map((entry) {
                final p = entry.value;
                final isLast = entry.key == players.length - 1;
                
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Número do jogador
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${p['lineup_number']?.toString() ?? '0'}.',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Nome e posição
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['lineup_player']?.toString() ?? '-',
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (p['lineup_position'] != null)
                                  Text(
                                    p['lineup_position'].toString(),
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        color: cs.outlineVariant.withOpacity(0.3),
                        height: 1,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}