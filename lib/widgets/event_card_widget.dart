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

  Widget _buildPlayerAvatar({
    required String? playerImageUrl,
    required String? teamLogo,
    required String player,
    required ColorScheme cs,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        children: [
          // Avatar do jogador
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceContainerHighest,
              border: Border.all(
                color: cs.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: playerImageUrl != null && playerImageUrl.isNotEmpty
                  ? Image.network(
                      playerImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/icons/player_placeholder.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Symbols.person_rounded,
                          size: 18,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/icons/player_placeholder.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Symbols.person_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          // Badge do clube no canto inferior direito
          if (teamLogo != null && teamLogo.isNotEmpty)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    teamLogo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: cs.surfaceContainerHighest,
                      child: Icon(
                        Symbols.shield_rounded,
                        size: 8,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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

    Widget eventIcon = _buildEventIcon(type, cs);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna do time da casa
          Expanded(
            child: isHome 
              ? _buildEventDetails(isHome: true, cs: cs, type: type, icon: eventIcon)
              : const SizedBox(),
          ),
          
          // Coluna central com minutos
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
          
          // Coluna do time visitante
          Expanded(
            child: !isHome 
              ? _buildEventDetails(isHome: false, cs: cs, type: type, icon: eventIcon)
              : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventIcon(String type, ColorScheme cs) {
    if (type == 'goal') {
      return Image.asset(
        'assets/icons/soccer_ball.png',
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) => Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Symbols.sports_soccer_rounded, color: Colors.green, size: 14),
        ),
      );
    } else if (type == 'yellow') {
      return Container(
        width: 12,
        height: 18,
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
      return Container(
        width: 12,
        height: 18,
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
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(Symbols.sync_alt_rounded, color: cs.primary, size: 16),
      );
    }
  }

  Widget _buildEventDetails({
    required bool isHome,
    required ColorScheme cs,
    required String type,
    required Widget icon,
  }) {
    final player = (event['player'] ?? '').toString();
    final assist = (event['assist'] ?? '').toString();
    final method = (event['method'] ?? '').toString();

    return Row(
      mainAxisAlignment: isHome ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isHome) const SizedBox(width: 4),
        
        if (!isHome) ...[
          Expanded(
            child: _buildPlayerInfo(
              player: player,
              assist: assist,
              method: method,
              isHome: isHome,
              cs: cs,
              type: type,
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: icon,
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: icon,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildPlayerInfo(
              player: player,
              assist: assist,
              method: method,
              isHome: isHome,
              cs: cs,
              type: type,
            ),
          ),
        ],
        
        if (isHome) const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildPlayerInfo({
    required String player,
    required String assist,
    required String method,
    required bool isHome,
    required ColorScheme cs,
    required String type,
  }) {
    // Obter URL da imagem do jogador e do clube da API
    final playerImageUrl = event['player_image']?.toString();
    final teamLogo = isHome ? event['home_team_logo']?.toString() : event['away_team_logo']?.toString();
    
    return Column(
      crossAxisAlignment: isHome ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        // Nome do jogador com foto (somente para gols)
        if (type == 'goal')
          Row(
            mainAxisSize: MainAxisSize.min,
            children: isHome
                ? [
                    _buildPlayerAvatarFromEventosTab(
                      playerImageUrl: playerImageUrl,
                      teamLogo: teamLogo,
                      player: player,
                      cs: cs,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        player,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ]
                : [
                    Flexible(
                      child: Text(
                        player,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildPlayerAvatarFromEventosTab(
                      playerImageUrl: playerImageUrl,
                      teamLogo: teamLogo,
                      player: player,
                      cs: cs,
                    ),
                  ],
          )
        else
          Text(
            player,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              fontSize: 15,
            ),
            textAlign: isHome ? TextAlign.left : TextAlign.right,
          ),
        if (assist.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: isHome
                  ? [
                      Image.asset(
                        'assets/icons/assist.png',
                        width: 13,
                        height: 13,
                        errorBuilder: (_, __, ___) => Icon(Symbols.sports_rounded, size: 13, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(width: 3),
                      Flexible(child: Text(assist, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12))),
                    ]
                  : [
                      Flexible(child: Text(assist, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.right)),
                      const SizedBox(width: 3),
                      Image.asset(
                        'assets/icons/assist.png',
                        width: 13,
                        height: 13,
                        errorBuilder: (_, __, ___) => Icon(Symbols.sports_rounded, size: 13, color: cs.onSurfaceVariant),
                      ),
                    ],
            ),
          ),
        if (method.isNotEmpty && method.toLowerCase().contains('var'))
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: isHome
                  ? [
                      Image.asset(
                        'assets/icons/var.png',
                        width: 15,
                        height: 15,
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: Colors.purple.shade700, borderRadius: BorderRadius.circular(4)),
                          child: const Text('VAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Flexible(child: Text(method, style: TextStyle(color: Colors.purple.shade700, fontSize: 11, fontWeight: FontWeight.w600))),
                    ]
                  : [
                      Flexible(child: Text(method, style: TextStyle(color: Colors.purple.shade700, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                      const SizedBox(width: 3),
                      Image.asset(
                        'assets/icons/var.png',
                        width: 15,
                        height: 15,
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
              textAlign: isHome ? TextAlign.left : TextAlign.right,
            ),
          ),
        if (type == 'substitution' && event['playerIn'] != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: isHome
                ? [
                    const Icon(Symbols.arrow_upward_rounded, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Flexible(child: Text(event['playerIn'], style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w700))),
                  ]
                : [
                    Flexible(child: Text(event['playerIn'], style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                    const SizedBox(width: 4),
                    const Icon(Symbols.arrow_upward_rounded, size: 14, color: Colors.green),
                  ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: isHome
                ? [
                    Icon(Symbols.arrow_downward_rounded, size: 14, color: Colors.red.shade400),
                    const SizedBox(width: 4),
                    Flexible(child: Text(event['playerOut'], style: TextStyle(color: Colors.red.shade400, fontSize: 12))),
                  ]
                : [
                    Flexible(child: Text(event['playerOut'], style: TextStyle(color: Colors.red.shade400, fontSize: 12), textAlign: TextAlign.right)),
                    const SizedBox(width: 4),
                    Icon(Symbols.arrow_downward_rounded, size: 14, color: Colors.red.shade400),
                  ],
          ),
        ],
      ],
    );
  }
}