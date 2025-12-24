import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeConfigPage extends StatefulWidget {
  const HomeConfigPage({super.key});

  @override
  State<HomeConfigPage> createState() => _HomeConfigPageState();
}

class _HomeConfigPageState extends State<HomeConfigPage> {
  bool _hasChanges = false;
  bool _isLoading = true;

  late List<Map<String, dynamic>> _originalClubs;

  final List<Map<String, dynamic>> _availableClubs = [
    // Inglaterra - Premier League
    {'name': 'Manchester City', 'league': 'Premier League', 'flag': 'assets/flags/gb.png', 'enabled': true},
    {'name': 'Liverpool', 'league': 'Premier League', 'flag': 'assets/flags/gb.png', 'enabled': true},
    {'name': 'Arsenal', 'league': 'Premier League', 'flag': 'assets/flags/gb.png', 'enabled': true},
    {'name': 'Chelsea', 'league': 'Premier League', 'flag': 'assets/flags/gb.png', 'enabled': true},
    {'name': 'Manchester United', 'league': 'Premier League', 'flag': 'assets/flags/gb.png', 'enabled': true},
    {'name': 'Tottenham', 'league': 'Premier League', 'flag': 'assets/flags/gb.png', 'enabled': true},
    {'name': 'Newcastle', 'league': 'Premier League', 'flag': 'assets/flags/gb.png', 'enabled': false},
    {'name': 'Aston Villa', 'league': 'Premier League', 'flag': 'assets/flags/gb.png', 'enabled': false},
    {'name': 'West Ham', 'league': 'Premier League', 'flag': 'assets/flags/gb.png', 'enabled': false},
    {'name': 'Brighton', 'league': 'Premier League', 'flag': 'assets/flags/gb.png', 'enabled': false},

    // Espanha - La Liga
    {'name': 'Real Madrid', 'league': 'La Liga', 'flag': 'assets/flags/es.png', 'enabled': true},
    {'name': 'Barcelona', 'league': 'La Liga', 'flag': 'assets/flags/es.png', 'enabled': true},
    {'name': 'Atlético Madrid', 'league': 'La Liga', 'flag': 'assets/flags/es.png', 'enabled': true},
    {'name': 'Sevilla', 'league': 'La Liga', 'flag': 'assets/flags/es.png', 'enabled': false},
    {'name': 'Real Sociedad', 'league': 'La Liga', 'flag': 'assets/flags/es.png', 'enabled': false},
    {'name': 'Villarreal', 'league': 'La Liga', 'flag': 'assets/flags/es.png', 'enabled': false},
    {'name': 'Athletic Bilbao', 'league': 'La Liga', 'flag': 'assets/flags/es.png', 'enabled': false},
    {'name': 'Real Betis', 'league': 'La Liga', 'flag': 'assets/flags/es.png', 'enabled': false},
    {'name': 'Valencia', 'league': 'La Liga', 'flag': 'assets/flags/es.png', 'enabled': false},

    // Itália - Serie A
    {'name': 'Inter Milan', 'league': 'Serie A', 'flag': 'assets/flags/it.png', 'enabled': true},
    {'name': 'AC Milan', 'league': 'Serie A', 'flag': 'assets/flags/it.png', 'enabled': true},
    {'name': 'Juventus', 'league': 'Serie A', 'flag': 'assets/flags/it.png', 'enabled': true},
    {'name': 'Napoli', 'league': 'Serie A', 'flag': 'assets/flags/it.png', 'enabled': true},
    {'name': 'AS Roma', 'league': 'Serie A', 'flag': 'assets/flags/it.png', 'enabled': false},
    {'name': 'Lazio', 'league': 'Serie A', 'flag': 'assets/flags/it.png', 'enabled': false},
    {'name': 'Atalanta', 'league': 'Serie A', 'flag': 'assets/flags/it.png', 'enabled': false},
    {'name': 'Fiorentina', 'league': 'Serie A', 'flag': 'assets/flags/it.png', 'enabled': false},
    {'name': 'Torino', 'league': 'Serie A', 'flag': 'assets/flags/it.png', 'enabled': false},

    // Alemanha - Bundesliga
    {'name': 'Bayern Munich', 'league': 'Bundesliga', 'flag': 'assets/flags/de.png', 'enabled': true},
    {'name': 'Borussia Dortmund', 'league': 'Bundesliga', 'flag': 'assets/flags/de.png', 'enabled': true},
    {'name': 'RB Leipzig', 'league': 'Bundesliga', 'flag': 'assets/flags/de.png', 'enabled': false},
    {'name': 'Bayer Leverkusen', 'league': 'Bundesliga', 'flag': 'assets/flags/de.png', 'enabled': false},
    {'name': 'Borussia Monchengladbach', 'league': 'Bundesliga', 'flag': 'assets/flags/de.png', 'enabled': false},
    {'name': 'Eintracht Frankfurt', 'league': 'Bundesliga', 'flag': 'assets/flags/de.png', 'enabled': false},
    {'name': 'VfB Stuttgart', 'league': 'Bundesliga', 'flag': 'assets/flags/de.png', 'enabled': false},

    // França - Ligue 1
    {'name': 'Paris Saint-Germain', 'league': 'Ligue 1', 'flag': 'assets/flags/fr.png', 'enabled': true},
    {'name': 'Marseille', 'league': 'Ligue 1', 'flag': 'assets/flags/fr.png', 'enabled': false},
    {'name': 'Lyon', 'league': 'Ligue 1', 'flag': 'assets/flags/fr.png', 'enabled': false},
    {'name': 'Monaco', 'league': 'Ligue 1', 'flag': 'assets/flags/fr.png', 'enabled': false},
    {'name': 'Lille', 'league': 'Ligue 1', 'flag': 'assets/flags/fr.png', 'enabled': false},
    {'name': 'Nice', 'league': 'Ligue 1', 'flag': 'assets/flags/fr.png', 'enabled': false},

    // Portugal - Primeira Liga
    {'name': 'Benfica', 'league': 'Primeira Liga', 'flag': 'assets/flags/pt.png', 'enabled': true},
    {'name': 'Porto', 'league': 'Primeira Liga', 'flag': 'assets/flags/pt.png', 'enabled': true},
    {'name': 'Sporting CP', 'league': 'Primeira Liga', 'flag': 'assets/flags/pt.png', 'enabled': true},
    {'name': 'Braga', 'league': 'Primeira Liga', 'flag': 'assets/flags/pt.png', 'enabled': false},

    // Holanda - Eredivisie
    {'name': 'Ajax', 'league': 'Eredivisie', 'flag': 'assets/flags/nl.png', 'enabled': false},
    {'name': 'PSV Eindhoven', 'league': 'Eredivisie', 'flag': 'assets/flags/nl.png', 'enabled': false},
    {'name': 'Feyenoord', 'league': 'Eredivisie', 'flag': 'assets/flags/nl.png', 'enabled': false},

    // Brasil - Brasileirão
    {'name': 'Flamengo', 'league': 'Brasileirão', 'flag': 'assets/flags/br.png', 'enabled': false},
    {'name': 'Palmeiras', 'league': 'Brasileirão', 'flag': 'assets/flags/br.png', 'enabled': false},
    {'name': 'Corinthians', 'league': 'Brasileirão', 'flag': 'assets/flags/br.png', 'enabled': false},
    {'name': 'São Paulo', 'league': 'Brasileirão', 'flag': 'assets/flags/br.png', 'enabled': false},
    {'name': 'Santos', 'league': 'Brasileirão', 'flag': 'assets/flags/br.png', 'enabled': false},

    // Argentina - Liga Profesional
    {'name': 'Boca Juniors', 'league': 'Liga Profesional', 'flag': 'assets/flags/ar.png', 'enabled': false},
    {'name': 'River Plate', 'league': 'Liga Profesional', 'flag': 'assets/flags/ar.png', 'enabled': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      final savedClubs = prefs.getString('enabled_clubs');
      if (savedClubs != null) {
        final List<dynamic> clubsList = jsonDecode(savedClubs);
        for (var club in _availableClubs) {
          club['enabled'] = clubsList.contains(club['name']);
        }
      }

      _originalClubs = _availableClubs.map((club) => Map<String, dynamic>.from(club)).toList();
      _isLoading = false;
      _hasChanges = false;
    });
  }

  void _checkForChanges() {
    bool changed = false;
    for (int i = 0; i < _availableClubs.length; i++) {
      if (_availableClubs[i]['enabled'] != _originalClubs[i]['enabled']) {
        changed = true;
        break;
      }
    }
    setState(() {
      _hasChanges = changed;
    });
  }

  Map<String, List<Map<String, dynamic>>> get _clubsByLeague {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var club in _availableClubs) {
      final league = club['league'] as String;
      if (!grouped.containsKey(league)) {
        grouped[league] = [];
      }
      grouped[league]!.add(club);
    }
    return grouped;
  }

  void _openSearch() {
    showSearch(
      context: context,
      delegate: ClubSearchDelegate(_availableClubs, (club, value) {
        setState(() {
          club['enabled'] = value;
          _checkForChanges();
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Clubes Favoritos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.search_rounded),
            onPressed: _openSearch,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _clubsByLeague.keys.length,
        itemBuilder: (context, index) {
          final league = _clubsByLeague.keys.elementAt(index);
          final clubs = _clubsByLeague[league]!;
          return _buildLeagueSection(league, clubs, cs);
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _hasChanges ? _saveSettings : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasChanges ? cs.primary : cs.surfaceContainerHighest,
              foregroundColor: _hasChanges ? Colors.white : cs.onSurfaceVariant.withOpacity(0.5),
              disabledBackgroundColor: cs.surfaceContainerHighest,
              disabledForegroundColor: cs.onSurfaceVariant.withOpacity(0.5),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Salvar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeagueSection(String league, List<Map<String, dynamic>> clubs, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              league,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: clubs.asMap().entries.map((entry) {
                final index = entry.key;
                final club = entry.value;
                final isFirst = index == 0;
                final isLast = index == clubs.length - 1;

                return Container(
                  decoration: BoxDecoration(
                    border: !isLast
                        ? Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.3)))
                        : null,
                    borderRadius: BorderRadius.vertical(
                      top: isFirst ? const Radius.circular(12) : Radius.zero,
                      bottom: isLast ? const Radius.circular(12) : Radius.zero,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          club['enabled'] = !(club['enabled'] as bool);
                          _checkForChanges();
                        });
                      },
                      borderRadius: BorderRadius.vertical(
                        top: isFirst ? const Radius.circular(12) : Radius.zero,
                        bottom: isLast ? const Radius.circular(12) : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                club['flag'] as String,
                                width: 32,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                club['name'] as String,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: club['enabled'] as bool,
                              onChanged: (value) {
                                setState(() {
                                  club['enabled'] = value ?? false;
                                  _checkForChanges();
                                });
                              },
                              shape: const CircleBorder(),
                              activeColor: cs.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final enabledClubs = _availableClubs
        .where((club) => club['enabled'] == true)
        .map((club) => club['name'] as String)
        .toList();
    await prefs.setString('enabled_clubs', jsonEncode(enabledClubs));

    _originalClubs = _availableClubs.map((club) => Map<String, dynamic>.from(club)).toList();

    setState(() {
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Symbols.check_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Configurações salvas',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.pop(context);
    });
  }
}

class ClubSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> clubs;
  final Function(Map<String, dynamic>, bool) onToggle;

  ClubSearchDelegate(this.clubs, this.onToggle);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Symbols.close_rounded),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Symbols.arrow_back_rounded),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final results = clubs.where((club) {
      return club['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
             club['league'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.search_off_rounded, size: 64, color: cs.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Nenhum clube encontrado',
              style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final club = results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onToggle(club, !(club['enabled'] as bool));
                close(context, '');
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        club['flag'] as String,
                        width: 32,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club['name'] as String,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface),
                          ),
                          Text(
                            club['league'] as String,
                            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: club['enabled'] as bool,
                      onChanged: (value) => onToggle(club, value ?? false),
                      shape: const CircleBorder(),
                      activeColor: cs.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}