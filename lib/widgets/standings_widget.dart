import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class StandingsTab extends StatelessWidget {
  final List<Map<String, dynamic>> standings;
  final Map<String, dynamic> jogo;

  const StandingsTab({
    super.key,
    required this.standings,
    required this.jogo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (standings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.leaderboard_rounded,
                size: 64,
                color: cs.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Classificação não disponível',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Symbols.leaderboard_rounded, color: cs.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      jogo['league_name'] ?? 'Classificação',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Header da tabela
              _buildTableHeader(cs),
              const SizedBox(height: 8),
              // Times
              ...standings.asMap().entries.map((entry) {
                final index = entry.key;
                final team = entry.value;
                final isHomeTeam = team['team_name'] == jogo['match_hometeam_name'];
                final isAwayTeam = team['team_name'] == jogo['match_awayteam_name'];
                final isHighlighted = isHomeTeam || isAwayTeam;
                
                return _buildStandingRow(
                  team: team,
                  position: index + 1,
                  isHighlighted: isHighlighted,
                  isHomeTeam: isHomeTeam,
                  cs: cs,
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(cs),
      ],
    );
  }

  Widget _buildTableHeader(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Time',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              'J',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              'V',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              'E',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              'D',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              'Pts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingRow({
    required Map<String, dynamic> team,
    required int position,
    required bool isHighlighted,
    required bool isHomeTeam,
    required ColorScheme cs,
  }) {
    final teamName = team['team_name']?.toString() ?? '';
    final played = team['overall_league_payed']?.toString() ?? '0';
    final wins = team['overall_league_W']?.toString() ?? '0';
    final draws = team['overall_league_D']?.toString() ?? '0';
    final losses = team['overall_league_L']?.toString() ?? '0';
    final points = team['overall_league_PTS']?.toString() ?? '0';
    final goalDiff = team['overall_league_GF']?.toString() ?? '0';
    final goalAgainst = team['overall_league_GA']?.toString() ?? '0';
    
    Color? positionColor;
    if (position <= 4) {
      positionColor = const Color(0xFF00C853); // Champions League
    } else if (position <= 6) {
      positionColor = Colors.blue; // Europa League
    } else if (position >= (standings.length - 2)) {
      positionColor = Colors.red; // Rebaixamento
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? (isHomeTeam ? cs.primary.withOpacity(0.1) : Colors.green.withOpacity(0.1))
            : cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(
                color: isHomeTeam ? cs.primary : Colors.green,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            child: Row(
              children: [
                if (positionColor != null)
                  Container(
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      color: positionColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                const SizedBox(width: 6),
                Text(
                  '$position',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (team['team_badge'] != null && team['team_badge'].toString().isNotEmpty)
                  Image.network(
                    team['team_badge'],
                    width: 20,
                    height: 20,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.shield,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  )
                else
                  Icon(Icons.shield, size: 20, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    teamName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              played,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              wins,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              draws,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              losses,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              points,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legenda',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildLegendItem('Champions League', const Color(0xFF00C853), cs),
          const SizedBox(height: 8),
          _buildLegendItem('Europa League', Colors.blue, cs),
          const SizedBox(height: 8),
          _buildLegendItem('Rebaixamento', Colors.red, cs),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, ColorScheme cs) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}