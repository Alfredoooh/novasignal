import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../utils/formatters.dart';
import '../screens/search_page.dart';

class JogoDetalhesHeader extends StatelessWidget {
  final Map<String, dynamic> jogo;
  final int cartoesAmareloCasa;
  final int cartoesVermelhoCasa;
  final int cartoesAmareloFora;
  final int cartoesVermelhoFora;
  final TabController tabController;
  final bool innerScrolled;

  const JogoDetalhesHeader({
    super.key,
    required this.jogo,
    required this.cartoesAmareloCasa,
    required this.cartoesVermelhoCasa,
    required this.cartoesAmareloFora,
    required this.cartoesVermelhoFora,
    required this.tabController,
    required this.innerScrolled,
  });

  String _getMinutosJogo() {
    final status = jogo['match_status'] ?? '';
    if (status == 'Finished' || status == 'After ET' || status == 'After Pen.') {
      return 'FT';
    } else if (status == 'Half Time') {
      return 'HT';
    } else if (status.contains("'")) {
      return status;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minutosJogo = _getMinutosJogo();

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: cs.surface,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Symbols.search_rounded, color: cs.onSurface),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SearchPage(),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: innerScrolled
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (jogo['team_home_badge'] != null)
                    Image.network(
                      jogo['team_home_badge'],
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 24, color: cs.onSurface),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (jogo['team_away_badge'] != null)
                    Image.network(
                      jogo['team_away_badge'],
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 24, color: cs.onSurface),
                    ),
                ],
              )
            : Text(
                jogo['league_name'] ?? 'Liga',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        centerTitle: false,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                cs.primaryContainer,
                cs.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  '${jogo['match_date'] ?? ''} • ${jogo['match_time'] ?? ''}',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  jogo['league_name'] ?? '',
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final query = jogo['match_hometeam_name'] ?? '';
                              if (query.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(initialQuery: query),
                                  ),
                                );
                              }
                            },
                            child: (jogo['team_home_badge'] ?? '').toString().isNotEmpty
                                ? Image.network(
                                    jogo['team_home_badge'],
                                    width: 60,
                                    height: 60,
                                    errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 60, color: cs.primary),
                                  )
                                : Icon(Icons.shield, size: 60, color: cs.primary),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              jogo['match_hometeam_name'] ?? '',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Text(
                            '${jogo['match_hometeam_score'] ?? '0'} - ${jogo['match_awayteam_score'] ?? '0'}',
                            style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: cs.onSurface, height: 1),
                          ),
                          const SizedBox(height: 10),
                          if (minutosJogo.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: getStatusColor(jogo['match_status'] ?? '', context).withOpacity(0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                minutosJogo,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: getStatusColor(jogo['match_status'] ?? '', context),
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: getStatusColor(jogo['match_status'] ?? '', context).withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              formatarStatus(jogo['match_status'] ?? ''),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: getStatusColor(jogo['match_status'] ?? '', context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final query = jogo['match_awayteam_name'] ?? '';
                              if (query.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(initialQuery: query),
                                  ),
                                );
                              }
                            },
                            child: (jogo['team_away_badge'] ?? '').toString().isNotEmpty
                                ? Image.network(
                                    jogo['team_away_badge'],
                                    width: 60,
                                    height: 60,
                                    errorBuilder: (_, __, ___) => Icon(Icons.shield, size: 60, color: cs.primary),
                                  )
                                : Icon(Icons.shield, size: 60, color: cs.primary),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              jogo['match_awayteam_name'] ?? '',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (cartoesAmareloCasa > 0) ...[
                            Container(
                              width: 14,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade700,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('$cartoesAmareloCasa', style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                          ],
                          if (cartoesVermelhoCasa > 0) ...[
                            Container(
                              width: 14,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('$cartoesVermelhoCasa', style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          if (cartoesAmareloFora > 0) ...[
                            Text('$cartoesAmareloFora', style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            Container(
                              width: 14,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade700,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (cartoesVermelhoFora > 0) ...[
                            Text('$cartoesVermelhoFora', style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            Container(
                              width: 14,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: cs.surface,
          child: TabBar(
            controller: tabController,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Eventos'),
              Tab(text: 'Formações'),
              Tab(text: 'Classificação'),
              Tab(text: 'Previsões'),
              Tab(text: 'Comentários'),
            ],
          ),
        ),
      ),
    );
  }
}