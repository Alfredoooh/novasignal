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
    {'name': 'Manchester City', 'league': 'Premier League', 'badge': 'assets/badges/manchester_city.png', 'enabled': true},
    {'name': 'Liverpool', 'league': 'Premier League', 'badge': 'assets/badges/liverpool.png', 'enabled': true},
    {'name': 'Arsenal', 'league': 'Premier League', 'badge': 'assets/badges/arsenal.png', 'enabled': true},
    {'name': 'Chelsea', 'league': 'Premier League', 'badge': 'assets/badges/chelsea.png', 'enabled': true},
    {'name': 'Manchester United', 'league': 'Premier League', 'badge': 'assets/badges/manchester_united.png', 'enabled': true},
    {'name': 'Tottenham', 'league': 'Premier League', 'badge': 'assets/badges/tottenham.png', 'enabled': true},
    {'name': 'Newcastle', 'league': 'Premier League', 'badge': 'assets/badges/newcastle.png', 'enabled': false},
    {'name': 'Aston Villa', 'league': 'Premier League', 'badge': 'assets/badges/aston_villa.png', 'enabled': false},
    {'name': 'West Ham', 'league': 'Premier League', 'badge': 'assets/badges/west_ham.png', 'enabled': false},
    {'name': 'Brighton', 'league': 'Premier League', 'badge': 'assets/badges/brighton.png', 'enabled': false},

    // Espanha - La Liga
    {'name': 'Real Madrid', 'league': 'La Liga', 'badge': 'assets/badges/real_madrid.png', 'enabled': true},
    {'name': 'Barcelona', 'league': 'La Liga', 'badge': 'assets/badges/barcelona.png', 'enabled': true},
    {'name': 'Atlético Madrid', 'league': 'La Liga', 'badge': 'assets/badges/atletico_madrid.png', 'enabled': true},
    {'name': 'Sevilla', 'league': 'La Liga', 'badge': 'assets/badges/sevilla.png', 'enabled': false},
    {'name': 'Real Sociedad', 'league': 'La Liga', 'badge': 'assets/badges/real_sociedad.png', 'enabled': false},
    {'name': 'Villarreal', 'league': 'La Liga', 'badge': 'assets/badges/villarreal.png', 'enabled': false},
    {'name': 'Athletic Bilbao', 'league': 'La Liga', 'badge': 'assets/badges/athletic_bilbao.png', 'enabled': false},
    {'name': 'Real Betis', 'league': 'La Liga', 'badge': 'assets/badges/real_betis.png', 'enabled': false},
    {'name': 'Valencia', 'league': 'La Liga', 'badge': 'assets/badges/valencia.png', 'enabled': false},

    // Itália - Serie A
    {'name': 'Inter Milan', 'league': 'Serie A', 'badge': 'assets/badges/inter_milan.png', 'enabled': true},
    {'name': 'AC Milan', 'league': 'Serie A', 'badge': 'assets/badges/ac_milan.png', 'enabled': true},
    {'name': 'Juventus', 'league': 'Serie A', 'badge': 'assets/badges/juventus.png', 'enabled': true},
    {'name': 'Napoli', 'league': 'Serie A', 'badge': 'assets/badges/napoli.png', 'enabled': true},
    {'name': 'AS Roma', 'league': 'Serie A', 'badge': 'assets/badges/as_roma.png', 'enabled': false},
    {'name': 'Lazio', 'league': 'Serie A', 'badge': 'assets/badges/lazio.png', 'enabled': false},
    {'name': 'Atalanta', 'league': 'Serie A', 'badge': 'assets/badges/atalanta.png', 'enabled': false},
    {'name': 'Fiorentina', 'league': 'Serie A', 'badge': 'assets/badges/fiorentina.png', 'enabled': false},
    {'name': 'Torino', 'league': 'Serie A', 'badge': 'assets/badges/torino.png', 'enabled': false},

    // Alemanha - Bundesliga
    {'name': 'Bayern Munich', 'league': 'Bundesliga', 'badge': 'assets/badges/bayern_munich.png', 'enabled': true},
    {'name': 'Borussia Dortmund', 'league': 'Bundesliga', 'badge': 'assets/badges/borussia_dortmund.png', 'enabled': true},
    {'name': 'RB Leipzig', 'league': 'Bundesliga', 'badge': 'assets/badges/rb_leipzig.png', 'enabled': false},
    {'name': 'Bayer Leverkusen', 'league': 'Bundesliga', 'badge': 'assets/badges/bayer_leverkusen.png', 'enabled': false},
    {'name': 'Borussia Monchengladbach', 'league': 'Bundesliga', 'badge': 'assets/badges/borussia_monchengladbach.png', 'enabled': false},
    {'name': 'Eintracht Frankfurt', 'league': 'Bundesliga', 'badge': 'assets/badges/eintracht_frankfurt.png', 'enabled': false},
    {'name': 'VfB Stuttgart', 'league': 'Bundesliga', 'badge': 'assets/badges/vfb_stuttgart.png', 'enabled': false},

    // França - Ligue 1
    {'name': 'Paris Saint-Germain', 'league': 'Ligue 1', 'badge': 'assets/badges/psg.png', 'enabled': true},
    {'name': 'Marseille', 'league': 'Ligue 1', 'badge': 'assets/badges/marseille.png', 'enabled': false},
    {'name': 'Lyon', 'league': 'Ligue 1', 'badge': 'assets/badges/lyon.png', 'enabled': false},
    {'name': 'Monaco', 'league': 'Ligue 1', 'badge': 'assets/badges/monaco.png', 'enabled': false},
    {'name': 'Lille', 'league': 'Ligue 1', 'badge': 'assets/badges/lille.png', 'enabled': false},
    {'name': 'Nice', 'league': 'Ligue 1', 'badge': 'assets/badges/nice.png', 'enabled': false},

    // Portugal - Primeira Liga
    {'name': 'Benfica', 'league': 'Primeira Liga', 'badge': 'assets/badges/benfica.png', 'enabled': true},
    {'name': 'Porto', 'league': 'Primeira Liga', 'badge': 'assets/badges/porto.png', 'enabled': true},
    {'name': 'Sporting CP', 'league': 'Primeira Liga', 'badge': 'assets/badges/sporting_cp.png', 'enabled': true},
    {'name': 'Braga', 'league': 'Primeira Liga', 'badge': 'assets/badges/braga.png', 'enabled': false},

    // Holanda - Eredivisie
    {'name': 'Ajax', 'league': 'Eredivisie', 'badge': 'assets/badges/ajax.png', 'enabled': false},
    {'name': 'PSV Eindhoven', 'league': 'Eredivisie', 'badge': 'assets/badges/psv.png', 'enabled': false},
    {'name': 'Feyenoord', 'league': 'Eredivisie', 'badge': 'assets/badges/feyenoord.png', 'enabled': false},

    // Brasil - Brasileirão
    {'name': 'Flamengo', 'league': 'Brasileirão', 'badge': 'assets/badges/flamengo.png', 'enabled': false},
    {'name': 'Palmeiras', 'league': 'Brasileirão', 'badge': 'assets/badges/palmeiras.png', 'enabled': false},
    {'name': 'Corinthians', 'league': 'Brasileirão', 'badge': 'assets/badges/corinthians.png', 'enabled': false},
    {'name': 'São Paulo', 'league': 'Brasileirão', 'badge': 'assets/badges/sao_paulo.png', 'enabled': false},
    {'name': 'Santos', 'league': 'Brasileirão', 'badge': 'assets/badges/santos.png', 'enabled': false},

    // Argentina - Liga Profesional
    {'name': 'Boca Juniors', 'league': 'Liga Profesional', 'badge': 'assets/badges/boca_juniors.png', 'enabled': false},
    {'name': 'River Plate', 'league': 'Liga Profesional', 'badge': 'assets/badges/river_plate.png', 'enabled': false},
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
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
              color: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark 
                  ? cs.outlineVariant.withOpacity(0.3)
                  : cs.outlineVariant.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                      top: isFirst ? const Radius.circular(16) : Radius.zero,
                      bottom: isLast ? const Radius.circular(16) : Radius.zero,
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
                        top: isFirst ? const Radius.circular(16) : Radius.zero,
                        bottom: isLast ? const Radius.circular(16) : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                club['badge'] as String,
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Symbols.shield_rounded,
                                    size: 20,
                                    color: cs.onSurfaceVariant.withOpacity(0.5),
                                  ),
                                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark 
                ? cs.outlineVariant.withOpacity(0.3)
                : cs.outlineVariant.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onToggle(club, !(club['enabled'] as bool));
                close(context, '');
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        club['badge'] as String,
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Symbols.shield_rounded,
                            size: 20,
                            color: cs.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
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