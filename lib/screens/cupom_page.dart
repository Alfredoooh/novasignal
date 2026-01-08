import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CupomPage extends StatelessWidget {
  const CupomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Cupons Ativos'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cupom zerado de exemplo
          _buildCuponCard(
            context,
            mise: '0 F',
            gains: '0 F',
            status: 'Aucune mise',
            statusColor: Colors.grey,
            matches: [
              _MatchInfo(
                league: 'Aucun match sélectionné',
                date: '--.--.---- (--:--)',
                team1: '---',
                team2: '---',
                score: '- : -',
                halfScore: '',
                bet: '---',
                choice: '---',
                odds: 0.00,
                result: 'En attente',
                resultColor: Colors.grey,
              ),
            ],
            ticketId: '#00000000',
            placedDate: '--.--.----',
          ),
          const SizedBox(height: 16),
          // Mensagem informativa
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Symbols.info_rounded,
                  size: 48,
                  color: const Color(0xFF007AFF),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum cupom ativo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça suas apostas para ver\nseus cupons aqui',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                        color: Colors.grey.shade600,
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
                        color: Colors.grey.shade600,
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
                        color: Colors.grey.shade600,
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
            color: Colors.grey.shade200,
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
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              match.league,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
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
                          color: Colors.grey.shade500,
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
                              color: Colors.grey.shade500,
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
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              match.choice,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF007AFF),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            match.odds.toStringAsFixed(2),
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
                              color: Colors.grey.shade600,
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
                    color: Colors.grey.shade200,
                  ),
              ],
            );
          }),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'ID Ticket: $ticketId • Placé le $placedDate',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
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
