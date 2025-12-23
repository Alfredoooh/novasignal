import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'dart:math' show pi;

class PredictionsTab extends StatelessWidget {
  final Map<String, dynamic>? predictions;
  final Map<String, dynamic> jogo;

  const PredictionsTab({
    super.key,
    required this.predictions,
    required this.jogo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (predictions == null || predictions!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.psychology_rounded,
                size: 64,
                color: cs.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Previsões não disponíveis',
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
        // Match Winner Prediction
        _buildMatchWinnerCard(cs),
        const SizedBox(height: 16),
        
        // Score Prediction
        _buildScorePrediction(cs),
        const SizedBox(height: 16),
        
        // Goals Prediction
        _buildGoalsPrediction(cs),
        const SizedBox(height: 16),
        
        // Form & Statistics
        _buildFormStatistics(cs),
        const SizedBox(height: 16),
        
        // H2H Stats
        _buildH2HStats(cs),
        const SizedBox(height: 16),
        
        // Comparison
        _buildComparison(cs),
      ],
    );
  }

  Widget _buildMatchWinnerCard(ColorScheme cs) {
    final homeWin = double.tryParse(predictions!['1X2']?['1']?.toString() ?? '0') ?? 0;
    final draw = double.tryParse(predictions!['1X2']?['X']?.toString() ?? '0') ?? 0;
    final awayWin = double.tryParse(predictions!['1X2']?['2']?.toString() ?? '0') ?? 0;

    String prediction = 'Empate';
    if (homeWin > draw && homeWin > awayWin) {
      prediction = jogo['match_hometeam_name'] ?? 'Casa';
    } else if (awayWin > draw && awayWin > homeWin) {
      prediction = jogo['match_awayteam_name'] ?? 'Fora';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.15),
            cs.secondary.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Symbols.emoji_events_rounded, color: cs.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previsão Vencedor',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prediction,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProbabilityColumn(
                  label: jogo['match_hometeam_name'] ?? 'Casa',
                  percentage: homeWin,
                  color: cs.primary,
                  cs: cs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProbabilityColumn(
                  label: 'Empate',
                  percentage: draw,
                  color: Colors.orange,
                  cs: cs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProbabilityColumn(
                  label: jogo['match_awayteam_name'] ?? 'Fora',
                  percentage: awayWin,
                  color: Colors.green,
                  cs: cs,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityColumn({
    required String label,
    required double percentage,
    required Color color,
    required ColorScheme cs,
  }) {
    return Column(
      children: [
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildScorePrediction(ColorScheme cs) {
    final correctScore = predictions!['correct_score'] ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Symbols.scoreboard_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Placar Mais Provável',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (correctScore.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: correctScore.entries.take(6).map<Widget>((entry) {
                final score = entry.key.toString();
                final prob = double.tryParse(entry.value.toString()) ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        score,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${prob.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Text(
              'Sem previsão de placar',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalsPrediction(ColorScheme cs) {
    final overUnder = predictions!['over_under'] ?? {};
    final btts = predictions!['btts'] ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Symbols.sports_soccer_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Previsões de Gols',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Over/Under
          if (overUnder.isNotEmpty) ...[
            Text(
              'Over/Under',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Over 2.5',
                    value: '${overUnder['over_2_5'] ?? '0'}%',
                    color: Colors.orange,
                    cs: cs,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: 'Under 2.5',
                    value: '${overUnder['under_2_5'] ?? '0'}%',
                    color: Colors.blue,
                    cs: cs,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // BTTS
          if (btts.isNotEmpty) ...[
            Text(
              'Ambos Marcam',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Sim',
                    value: '${btts['yes'] ?? '0'}%',
                    color: Colors.green,
                    cs: cs,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: 'Não',
                    value: '${btts['no'] ?? '0'}%',
                    color: Colors.red,
                    cs: cs,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required ColorScheme cs,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormStatistics(ColorScheme cs) {
    final homeForm = predictions!['home_form']?.toString() ?? '';
    final awayForm = predictions!['away_form']?.toString() ?? '';
    
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Symbols.trending_up_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Forma Recente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormRow(
            team: jogo['match_hometeam_name'] ?? 'Casa',
            form: homeForm,
            cs: cs,
          ),
          const SizedBox(height: 12),
          _buildFormRow(
            team: jogo['match_awayteam_name'] ?? 'Fora',
            form: awayForm,
            cs: cs,
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow({
    required String team,
    required String form,
    required ColorScheme cs,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            team,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Row(
            children: form.split('').map((result) {
              Color color;
              if (result == 'W') {
                color = Colors.green;
              } else if (result == 'D') {
                color = Colors.orange;
              } else {
                color = Colors.red;
              }
              
              return Container(
                margin: const EdgeInsets.only(right: 4),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    result,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildH2HStats(ColorScheme cs) {
    final h2h = predictions!['h2h'] ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Symbols.history_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Confrontos Diretos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildH2HCard(
                  label: 'Vitórias Casa',
                  value: h2h['home_wins']?.toString() ?? '0',
                  color: cs.primary,
                  cs: cs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildH2HCard(
                  label: 'Empates',
                  value: h2h['draws']?.toString() ?? '0',
                  color: Colors.orange,
                  cs: cs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildH2HCard(
                  label: 'Vitórias Fora',
                  value: h2h['away_wins']?.toString() ?? '0',
                  color: Colors.green,
                  cs: cs,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildH2HCard({
    required String label,
    required String value,
    required Color color,
    required ColorScheme cs,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComparison(ColorScheme cs) {
    final comparison = predictions!['comparison'] ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Symbols.compare_arrows_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Comparação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildComparisonBar(
            label: 'Ataque',
            homeValue: double.tryParse(comparison['attack_home']?.toString() ?? '0') ?? 0,
            awayValue: double.tryParse(comparison['attack_away']?.toString() ?? '0') ?? 0,
            cs: cs,
          ),
          const SizedBox(height: 12),
          _buildComparisonBar(
            label: 'Defesa',
            homeValue: double.tryParse(comparison['defense_home']?.toString() ?? '0') ?? 0,
            awayValue: double.tryParse(comparison['defense_away']?.toString() ?? '0') ?? 0,
            cs: cs,
          ),
          const SizedBox(height: 12),
          _buildComparisonBar(
            label: 'Posse de Bola',
            homeValue: double.tryParse(comparison['possession_home']?.toString() ?? '0') ?? 0,
            awayValue: double.tryParse(comparison['possession_away']?.toString() ?? '0') ?? 0,
            cs: cs,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar({
    required String label,
    required double homeValue,
    required double awayValue,
    required ColorScheme cs,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              homeValue.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              awayValue.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(
                flex: homeValue.toInt().clamp(1, 100),
                child: Container(height: 6, color: cs.primary),
              ),
              Expanded(
                flex: awayValue.toInt().clamp(1, 100),
                child: Container(height: 6, color: Colors.green),
              ),
            ],
          ),
        ),
      ],
    );
  }
}