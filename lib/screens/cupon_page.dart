import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CuponPage extends StatelessWidget {
  const CuponPage({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Scaffold(
      backgroundColor: brightness == Brightness.light 
          ? Colors.grey.shade50 
          : Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Cupons Ativos'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: brightness == Brightness.light 
            ? Colors.white 
            : Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cupom 1
          _buildCuponCard(
            context,
            mise: '150 000 F',
            gains: '334 170 F',
            status: 'Payé',
            statusColor: Colors.green,
            matches: [
              _MatchInfo(
                league: 'Championnat de Chypre, Première division',
                date: '08.04.2024 (17:00)',
                team1: 'AEZ Zakakiou',
                team2: 'AEL Limassol',
                score: '1 : 5',
                halfScore: '1:5 (0:3, 1:2)',
                bet: '1X2',
                choice: 'V2',
                odds: 1.58,
                result: 'Gagné',
                resultColor: Colors.green,
              ),
              _MatchInfo(
                league: 'Championnat de Hongrie, NB II',
                date: '08.04.2024 (19:00)',
                team1: 'Nyíregyháza',
                team2: 'PecsiMFC',
                score: '2 : 1',
                halfScore: '2:1 (2:0, 0:1)',
                bet: '1X2',
                choice: 'V1',
                odds: 1.41,
                result: 'Gagné',
                resultColor: Colors.green,
              ),
            ],
            ticketId: '#84930294',
            placedDate: '08.04.2024',
          ),
          const SizedBox(height: 16),
          // Cupom 2 (exemplo adicional)
          _buildCuponCard(
            context,
            mise: '50 000 F',
            gains: '125 500 F',
            status: 'En cours',
            statusColor: Colors.orange,
            matches: [
              _MatchInfo(
                league: 'Premier League',
                date: '07.01.2026 (20:00)',
                team1: 'Manchester United',
                team2: 'Liverpool',
                score: '- : -',
                halfScore: '',
                bet: '1X2',
                choice: 'V2',
                odds: 2.15,
                result: 'En attente',
                resultColor: Colors.orange,
              ),
            ],
            ticketId: '#84930295',
            placedDate: '07.01.2026',
          ),
        ],
      ),
    );
  }

  Widget _buildCuponCard(
    BuildContext context, {
    required String mise,
    required String gains,
    required String status,
    required Color statusColor,
    required List<_MatchInfo> matches,
    required String ticketId,
    required String placedDate,
  }) {
    final brightness = Theme.of(context).brightness;
    
    return Container(
      decoration: BoxDecoration(
        color: brightness == Brightness.light 
            ? Colors.white 
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com valores
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mise :',
                      style: TextStyle(
                        fontSize: 16,
                        color: brightness == Brightness.light 
                            ? Colors.grey.shade600 
                            : Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      mise,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gains :',
                      style: TextStyle(
                        fontSize: 16,
                        color: brightness == Brightness.light 
                            ? Colors.grey.shade600 
                            : Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      gains,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Statut :',
                      style: TextStyle(
                        fontSize: 16,
                        color: brightness == Brightness.light 
                            ? Colors.grey.shade600 
                            : Colors.grey.shade400,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Symbols.check_circle_rounded,
                          size: 18,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Divider(
            height: 1,
            color: brightness == Brightness.light 
                ? Colors.grey.shade200 
                : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          ),
          
          // Matches
          ...matches.asMap().entries.map((entry) {
            final index = entry.key;
            final match = entry.value;
            final isLast = index == matches.length - 1;
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // League e data
                      Row(
                        children: [
                          Icon(
                            Symbols.sports_soccer_rounded,
                            size: 16,
                            color: brightness == Brightness.light 
                                ? Colors.grey.shade600 
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              match.league,
                              style: TextStyle(
                                fontSize: 13,
                                color: brightness == Brightness.light 
                                    ? Colors.grey.shade600 
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: brightness == Brightness.light 
                              ? Colors.grey.shade500 
                              : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Placar
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              match.team1,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            match.score,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              match.team2,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (match.halfScore.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            match.halfScore,
                            style: TextStyle(
                              fontSize: 12,
                              color: brightness == Brightness.light 
                                  ? Colors.grey.shade500 
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Aposta
                      Row(
                        children: [
                          Text(
                            'Mise : ${match.bet}',
                            style: TextStyle(
                              fontSize: 14,
                              color: brightness == Brightness.light 
                                  ? Colors.grey.shade600 
                                  : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              match.choice,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            match.odds.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Status
                      Row(
                        children: [
                          Text(
                            'Statut :',
                            style: TextStyle(
                              fontSize: 14,
                              color: brightness == Brightness.light 
                                  ? Colors.grey.shade600 
                                  : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Symbols.check_circle_rounded,
                            size: 16,
                            color: match.resultColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            match.result,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: match.resultColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: brightness == Brightness.light 
                        ? Colors.grey.shade200 
                        : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                  ),
              ],
            );
          }).toList(),
          
          Divider(
            height: 1,
            color: brightness == Brightness.light 
                ? Colors.grey.shade200 
                : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          ),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'ID Ticket: $ticketId • Placé le $placedDate',
              style: TextStyle(
                fontSize: 12,
                color: brightness == Brightness.light 
                    ? Colors.grey.shade500 
                    : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchInfo {
  final String league;
  final String date;
  final String team1;
  final String team2;
  final String score;
  final String halfScore;
  final String bet;
  final String choice;
  final double odds;
  final String result;
  final Color resultColor;

  _MatchInfo({
    required this.league,
    required this.date,
    required this.team1,
    required this.team2,
    required this.score,
    required this.halfScore,
    required this.bet,
    required this.choice,
    required this.odds,
    required this.result,
    required this.resultColor,
  });
}