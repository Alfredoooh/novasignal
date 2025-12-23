import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class EventosTab extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> statistics;

  const EventosTab({
    super.key,
    required this.events,
    required this.statistics,
  });

  String _translateStatType(String type) {
    final translations = {
      'Ball Possession': 'Posse de Bola',
      'Shots Total': 'Finalizações',
      'Shots On Goal': 'Finalizações no Gol',
      'Shots Off Goal': 'Finalizações para Fora',
      'Shots Blocked': 'Finalizações Bloqueadas',
      'Corner Kicks': 'Escanteios',
      'Offsides': 'Impedimentos',
      'Fouls': 'Faltas',
      'Yellow Cards': 'Cartões Amarelos',
      'Red Cards': 'Cartões Vermelhos',
      'Goalkeeper Saves': 'Defesas do Goleiro',
      'Total Passes': 'Passes Totais',
      'Passes Accurate': 'Passes Certos',
    };
    return translations[type] ?? type;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (statistics.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
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
                    Icon(Symbols.bar_chart_rounded, color: cs.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Estatísticas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...statistics.take(5).map((s) => _buildStatRow(s, cs)),
              ],
            ),
          ),
        ],
        if (events.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Nenhum evento disponível', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
          )
        else
          ...events.map((e) => EventCard(event: e)),
      ],
    );
  }

  Widget _buildStatRow(Map<String, dynamic> s, ColorScheme cs) {
    final type = _translateStatType(s['type']?.toString() ?? 'Stat');
    final homeStr = s['home']?.toString().replaceAll('%', '') ?? '0';
    final awayStr = s['away']?.toString().replaceAll('%', '') ?? '0';

    final home = double.tryParse(homeStr) ?? 0;
    final away = double.tryParse(awayStr) ?? 0;

    final isPercentage = type.toLowerCase().contains('posse');
    final displayHome = isPercentage ? home : home.toInt();
    final displayAway = isPercentage ? away : away.toInt();
    final suffix = isPercentage ? '%' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$displayHome$suffix', style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
              Text(type, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              Text('$displayAway$suffix', style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  flex: home.toInt().clamp(1, 100),
                  child: Container(height: 6, color: cs.primary),
                ),
                Expanded(
                  flex: away.toInt().clamp(1, 100),
                  child: Container(height: 6, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final type = (event['type'] ?? '').toString();
    final time = event['time']?.toString() ?? '';
    final isHome = event['isHome'] == true;
    final player = (event['player'] ?? '').toString();
    final assist = (event['assist'] ?? '').toString();
    final method = (event['method'] ?? '').toString();

    Widget eventIcon;
    if (type == 'goal') {
      eventIcon = Image.asset(
        'assets/icons/soccer_ball.png',
        width: 24,
        height: 24,
        errorBuilder: (_, __, ___) => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Symbols.sports_soccer_rounded, color: Colors.green, size: 16),
        ),
      );
    } else if (type == 'yellow') {
      eventIcon = Container(
        width: 14,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.yellow.shade700,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.shade900.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    } else if (type == 'red') {
      eventIcon = Container(
        width: 14,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade900.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    } else {
      eventIcon = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(Symbols.sync_alt_rounded, color: cs.primary, size: 18),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isHome) ...[
            _buildPlayerBlock(
              player: player,
              assist: assist,
              method: method,
              leftAligned: true,
              cs: cs,
              event: event,
              type: type,
            ),
            const SizedBox(width: 12),
            eventIcon,
          ] else
            const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$time'",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (!isHome) ...[
            eventIcon,
            const SizedBox(width: 12),
            _buildPlayerBlock(
              player: player,
              assist: assist,
              method: method,
              leftAligned: false,
              cs: cs,
              event: event,
              type: type,
            ),
          ] else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildPlayerBlock({
    required String player,
    required String assist,
    required String method,
    required bool leftAligned,
    required ColorScheme cs,
    required Map<String, dynamic> event,
    required String type,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: leftAligned ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            player,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              fontSize: 15,
            ),
            textAlign: leftAligned ? TextAlign.left : TextAlign.right,
          ),
          if (assist.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: leftAligned
                    ? [
                        Image.asset(
                          'assets/icons/assist.png',
                          width: 14,
                          height: 14,
                          errorBuilder: (_, __, ___) => Icon(Symbols.sports_rounded, size: 14, color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: Text(assist, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12))),
                      ]
                    : [
                        Expanded(child: Text(assist, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.right)),
                        const SizedBox(width: 4),
                        Image.asset(
                          'assets/icons/assist.png',
                          width: 14,
                          height: 14,
                          errorBuilder: (_, __, ___) => Icon(Symbols.sports_rounded, size: 14, color: cs.onSurfaceVariant),
                        ),
                      ],
              ),
            ),
          if (method.isNotEmpty && method.toLowerCase().contains('var'))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: leftAligned
                    ? [
                        Image.asset(
                          'assets/icons/var.png',
                          width: 16,
                          height: 16,
                          errorBuilder: (_, __, ___) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(color: Colors.purple.shade700, borderRadius: BorderRadius.circular(4)),
                            child: const Text('VAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: Text(method, style: TextStyle(color: Colors.purple.shade700, fontSize: 11, fontWeight: FontWeight.w600))),
                      ]
                    : [
                        Expanded(child: Text(method, style: TextStyle(color: Colors.purple.shade700, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                        const SizedBox(width: 4),
                        Image.asset(
                          'assets/icons/var.png',
                          width: 16,
                          height: 16,
                          errorBuilder: (_, __, ___) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(color: Colors.purple.shade700, borderRadius: BorderRadius.circular(4)),
                            child: const Text('VAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
              ),
            )
          else if (method.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                method,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11, fontStyle: FontStyle.italic),
                textAlign: leftAligned ? TextAlign.left : TextAlign.right,
              ),
            ),
          if (type == 'substitution' && event['playerIn'] != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: leftAligned
                  ? [
                      const Icon(Symbols.arrow_upward_rounded, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event['playerIn'], style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w700))),
                    ]
                  : [
                      Expanded(child: Text(event['playerIn'], style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                      const SizedBox(width: 4),
                      const Icon(Symbols.arrow_upward_rounded, size: 14, color: Colors.green),
                    ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: leftAligned
                  ? [
                      Icon(Symbols.arrow_downward_rounded, size: 14, color: Colors.red.shade400),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event['playerOut'], style: TextStyle(color: Colors.red.shade400, fontSize: 12))),
                    ]
                  : [
                      Expanded(child: Text(event['playerOut'], style: TextStyle(color: Colors.red.shade400, fontSize: 12), textAlign: TextAlign.right)),
                      const SizedBox(width: 4),
                      Icon(Symbols.arrow_downward_rounded, size: 14, color: Colors.red.shade400),
                    ],
            ),
          ],
        ],
      ),
    );
  }
}