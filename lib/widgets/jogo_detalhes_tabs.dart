import 'package:flutter/material.dart';
import 'event_card_widget.dart';
import 'statistics_widget.dart';
import 'lineup_widget.dart';
import 'comments_widget.dart';

class JogoDetalhesTabs extends StatelessWidget {
  final TabController tabController;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> statistics;
  final List<Map<String, dynamic>> lineupHome;
  final List<Map<String, dynamic>> lineupAway;
  final List<Map<String, dynamic>> comentarios;
  final Map<String, dynamic> jogo;

  const JogoDetalhesTabs({
    super.key,
    required this.tabController,
    required this.events,
    required this.statistics,
    required this.lineupHome,
    required this.lineupAway,
    required this.comentarios,
    required this.jogo,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        EventosTab(events: events, statistics: statistics),
        LineupTab(
          lineupHome: lineupHome,
          lineupAway: lineupAway,
          jogo: jogo,
        ),
        ComentariosTab(comentarios: comentarios),
      ],
    );
  }
}