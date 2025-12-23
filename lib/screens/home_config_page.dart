import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/app_state.dart';

class HomeConfigPage extends StatefulWidget {
  const HomeConfigPage({super.key});

  @override
  State<HomeConfigPage> createState() => _HomeConfigPageState();
}

class _HomeConfigPageState extends State<HomeConfigPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  String _searchQuery = '';
  bool _showNews = true;
  bool _showLiveMatches = true;
  bool _autoRefresh = true;
  int _refreshInterval = 30;
  
  // Estados originais para detectar mudanças
  late bool _originalShowNews;
  late bool _originalShowLiveMatches;
  late bool _originalAutoRefresh;
  late int _originalRefreshInterval;
  late List<Map<String, dynamic>> _originalClubs;
  
  bool _hasChanges = false;
  bool _isLoading = true;
  
  // Lista expandida de clubes famosos
  final List<Map<String, dynamic>> _availableClubs = [
    // Inglaterra - Premier League
    {'name': 'Manchester City', 'league': 'Premier League', 'country': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'enabled': true},
    {'name': 'Liverpool', 'league': 'Premier League', 'country': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'enabled': true},
    {'name': 'Arsenal', 'league': 'Premier League', 'country': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'enabled': true},
    {'name': 'Chelsea', 'league': 'Premier League', 'country': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'enabled': true},
    {'name': 'Manchester United', 'league': 'Premier League', 'country': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'enabled': true},
    {'name': 'Tottenham', 'league': 'Premier League', 'country': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'enabled': true},
    {'name': 'Newcastle', 'league': 'Premier League', 'country': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'enabled': false},
    {'name': 'Aston Villa', 'league': 'Premier League', 'country': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'enabled': false},
    {'name': 'West Ham', 'league': 'Premier League', 'country': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'enabled': false},
    {'name': 'Brighton', 'league': 'Premier League', 'country': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'enabled': false},
    
    // Espanha - La Liga
    {'name': 'Real Madrid', 'league': 'La Liga', 'country': '🇪🇸', 'enabled': true},
    {'name': 'Barcelona', 'league': 'La Liga', 'country': '🇪🇸', 'enabled': true},
    {'name': 'Atlético Madrid', 'league': 'La Liga', 'country': '🇪🇸', 'enabled': true},
    {'name': 'Sevilla', 'league': 'La Liga', 'country': '🇪🇸', 'enabled': false},
    {'name': 'Real Sociedad', 'league': 'La Liga', 'country': '🇪🇸', 'enabled': false},
    {'name': 'Villarreal', 'league': 'La Liga', 'country': '🇪🇸', 'enabled': false},
    {'name': 'Athletic Bilbao', 'league': 'La Liga', 'country': '🇪🇸', 'enabled': false},
    {'name': 'Real Betis', 'league': 'La Liga', 'country': '🇪🇸', 'enabled': false},
    {'name': 'Valencia', 'league': 'La Liga', 'country': '🇪🇸', 'enabled': false},
    
    // Itália - Serie A
    {'name': 'Inter Milan', 'league': 'Serie A', 'country': '🇮🇹', 'enabled': true},
    {'name': 'AC Milan', 'league': 'Serie A', 'country': '🇮🇹', 'enabled': true},
    {'name': 'Juventus', 'league': 'Serie A', 'country': '🇮🇹', 'enabled': true},
    {'name': 'Napoli', 'league': 'Serie A', 'country': '🇮🇹', 'enabled': true},
    {'name': 'AS Roma', 'league': 'Serie A', 'country': '🇮🇹', 'enabled': false},
    {'name': 'Lazio', 'league': 'Serie A', 'country': '🇮🇹', 'enabled': false},
    {'name': 'Atalanta', 'league': 'Serie A', 'country': '🇮🇹', 'enabled': false},
    {'name': 'Fiorentina', 'league': 'Serie A', 'country': '🇮🇹', 'enabled': false},
    {'name': 'Torino', 'league': 'Serie A', 'country': '🇮🇹', 'enabled': false},
    
    // Alemanha - Bundesliga
    {'name': 'Bayern Munich', 'league': 'Bundesliga', 'country': '🇩🇪', 'enabled': true},
    {'name': 'Borussia Dortmund', 'league': 'Bundesliga', 'country': '🇩🇪', 'enabled': true},
    {'name': 'RB Leipzig', 'league': 'Bundesliga', 'country': '🇩🇪', 'enabled': false},
    {'name': 'Bayer Leverkusen', 'league': 'Bundesliga', 'country': '🇩🇪', 'enabled': false},
    {'name': 'Borussia Monchengladbach', 'league': 'Bundesliga', 'country': '🇩🇪', 'enabled': false},
    {'name': 'Eintracht Frankfurt', 'league': 'Bundesliga', 'country': '🇩🇪', 'enabled': false},
    {'name': 'VfB Stuttgart', 'league': 'Bundesliga', 'country': '🇩🇪', 'enabled': false},
    
    // França - Ligue 1
    {'name': 'Paris Saint-Germain', 'league': 'Ligue 1', 'country': '🇫🇷', 'enabled': true},
    {'name': 'Marseille', 'league': 'Ligue 1', 'country': '🇫🇷', 'enabled': false},
    {'name': 'Lyon', 'league': 'Ligue 1', 'country': '🇫🇷', 'enabled': false},
    {'name': 'Monaco', 'league': 'Ligue 1', 'country': '🇫🇷', 'enabled': false},
    {'name': 'Lille', 'league': 'Ligue 1', 'country': '🇫🇷', 'enabled': false},
    {'name': 'Nice', 'league': 'Ligue 1', 'country': '🇫🇷', 'enabled': false},
    
    // Portugal - Primeira Liga
    {'name': 'Benfica', 'league': 'Primeira Liga', 'country': '🇵🇹', 'enabled': true},
    {'name': 'Porto', 'league': 'Primeira Liga', 'country': '🇵🇹', 'enabled': true},
    {'name': 'Sporting CP', 'league': 'Primeira Liga', 'country': '🇵🇹', 'enabled': true},
    {'name': 'Braga', 'league': 'Primeira Liga', 'country': '🇵🇹', 'enabled': false},
    
    // Holanda - Eredivisie
    {'name': 'Ajax', 'league': 'Eredivisie', 'country': '🇳🇱', 'enabled': false},
    {'name': 'PSV Eindhoven', 'league': 'Eredivisie', 'country': '🇳🇱', 'enabled': false},
    {'name': 'Feyenoord', 'league': 'Eredivisie', 'country': '🇳🇱', 'enabled': false},
    
    // Brasil - Brasileirão
    {'name': 'Flamengo', 'league': 'Brasileirão', 'country': '🇧🇷', 'enabled': false},
    {'name': 'Palmeiras', 'league': 'Brasileirão', 'country': '🇧🇷', 'enabled': false},
    {'name': 'Corinthians', 'league': 'Brasileirão', 'country': '🇧🇷', 'enabled': false},
    {'name': 'São Paulo', 'league': 'Brasileirão', 'country': '🇧🇷', 'enabled': false},
    {'name': 'Santos', 'league': 'Brasileirão', 'country': '🇧🇷', 'enabled': false},
    
    // Argentina - Liga Profesional
    {'name': 'Boca Juniors', 'league': 'Liga Profesional', 'country': '🇦🇷', 'enabled': false},
    {'name': 'River Plate', 'league': 'Liga Profesional', 'country': '🇦🇷', 'enabled': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _showNews = prefs.getBool('show_news') ?? true;
      _showLiveMatches = prefs.getBool('show_live_matches') ?? true;
      _autoRefresh = prefs.getBool('auto_refresh') ?? true;
      _refreshInterval = prefs.getInt('refresh_interval') ?? 30;
      
      // Carregar clubes salvos
      final savedClubs = prefs.getString('enabled_clubs');
      if (savedClubs != null) {
        final List<dynamic> clubsList = jsonDecode(savedClubs);
        for (var club in _availableClubs) {
          club['enabled'] = clubsList.contains(club['name']);
        }
      }
      
      // Salvar estados originais
      _originalShowNews = _showNews;
      _originalShowLiveMatches = _showLiveMatches;
      _originalAutoRefresh = _autoRefresh;
      _originalRefreshInterval = _refreshInterval;
      _originalClubs = _availableClubs.map((club) => Map<String, dynamic>.from(club)).toList();
      
      _isLoading = false;
      _hasChanges = false;
    });
  }

  void _checkForChanges() {
    bool changed = false;
    
    if (_showNews != _originalShowNews ||
        _showLiveMatches != _originalShowLiveMatches ||
        _autoRefresh != _originalAutoRefresh ||
        _refreshInterval != _originalRefreshInterval) {
      changed = true;
    }
    
    // Verificar mudanças nos clubes
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

  List<Map<String, dynamic>> get _filteredClubs {
    if (_searchQuery.isEmpty) {
      return _availableClubs;
    }
    return _availableClubs.where((club) {
      return club['name'].toString().toLowerCase().contains(_searchQuery) ||
             club['league'].toString().toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _clubsByLeague {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var club in _filteredClubs) {
      final league = club['league'] as String;
      if (!grouped.containsKey(league)) {
        grouped[league] = [];
      }
      grouped[league]!.add(club);
    }
    return grouped;
  }

  int get _enabledClubsCount {
    return _availableClubs.where((club) => club['enabled'] == true).length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configurar Tela Inicial',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Clubes', icon: Icon(Symbols.shield_rounded, size: 20)),
            Tab(text: 'Exibição', icon: Icon(Symbols.visibility_rounded, size: 20)),
            Tab(text: 'Avançado', icon: Icon(Symbols.settings_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClubsTab(),
          _buildDisplayTab(),
          _buildAdvancedTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: _hasChanges ? _saveSettings : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChanges 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: _hasChanges 
                    ? Colors.white 
                    : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: _hasChanges ? 2 : 0,
              ),
              child: Text(
                'Salvar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClubsTab() {
    return Column(
      children: [
        // Barra de Pesquisa e Estatísticas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Campo de Pesquisa
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar clubes ou ligas...',
                  prefixIcon: const Icon(Symbols.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Symbols.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              // Estatísticas
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Ativos',
                      _enabledClubsCount.toString(),
                      Symbols.check_circle_rounded,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      _availableClubs.length.toString(),
                      Symbols.shield_rounded,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Ações Rápidas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _enableAllClubs,
                  icon: const Icon(Symbols.done_all_rounded, size: 18),
                  label: const Text('Ativar Todos'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _disableAllClubs,
                  icon: const Icon(Symbols.remove_done_rounded, size: 18),
                  label: const Text('Desativar Todos'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lista de Clubes por Liga
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: _clubsByLeague.keys.length,
            itemBuilder: (context, index) {
              final league = _clubsByLeague.keys.elementAt(index);
              final clubs = _clubsByLeague[league]!;
              return _buildLeagueSection(league, clubs);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueSection(String league, List<Map<String, dynamic>> clubs) {
    final enabledCount = clubs.where((c) => c['enabled'] == true).length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Text(
                league,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$enabledCount/${clubs.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...clubs.map((club) => _buildClubTile(club)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildClubTile(Map<String, dynamic> club) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: club['enabled']
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: club['enabled']
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1.5,
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
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: club['enabled']
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      club['country'] as String,
                      style: const TextStyle(fontSize: 24),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: club['enabled']
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        club['league'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: club['enabled'] as bool,
                  onChanged: (value) {
                    setState(() {
                      club['enabled'] = value;
                      _checkForChanges();
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Conteúdo da Tela Inicial'),
        const SizedBox(height: 12),
        _buildSwitchTile(
          'Exibir Notícias',
          'Mostrar seção de atualidades na parte inferior',
          Symbols.article_rounded,
          _showNews,
          (value) {
            setState(() {
              _showNews = value;
              _checkForChanges();
            });
          },
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          'Jogos ao Vivo',
          'Mostrar seção de jogos em tempo real',
          Symbols.sensors_rounded,
          _showLiveMatches,
          (value) {
            setState(() {
              _showLiveMatches = value;
              _checkForChanges();
            });
          },
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Informações Adicionais'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.info_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sobre a Exibição',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'As configurações de exibição controlam quais seções aparecem na sua tela inicial. Você pode personalizar a experiência conforme suas preferências.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Atualizações Automáticas'),
        const SizedBox(height: 12),
        _buildSwitchTile(
          'Atualização Automática',
          'Atualizar jogos automaticamente em segundo plano',
          Symbols.autorenew_rounded,
          _autoRefresh,
          (value) {
            setState(() {
              _autoRefresh = value;
              _checkForChanges();
            });
          },
        ),
        if (_autoRefresh) ...[
          const SizedBox(height: 20),
          Text(
            'Intervalo de Atualização',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'A cada $_refreshInterval segundos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _refreshInterval.toDouble(),
                  min: 15,
                  max: 120,
                  divisions: 7,
                  label: '$_refreshInterval s',
                  onChanged: (value) {
                    setState(() {
                      _refreshInterval = value.round();
                      _checkForChanges();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '15s',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '2min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
        _buildSectionHeader('Cache e Dados'),
        const SizedBox(height: 12),
        _buildActionTile(
          'Limpar Cache',
          'Remover dados temporários armazenados',
          Symbols.delete_sweep_rounded,
          Colors.orange,
          _clearCache,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Limpar Histórico',
          'Remover histórico de jogos visualizados',
          Symbols.history_rounded,
          Colors.red,
          _clearHistory,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Restaurar Padrão',
          'Resetar todas as configurações',
          Symbols.restart_alt_rounded,
          Colors.blue,
          _resetToDefaults,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Symbols.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enableAllClubs() {
    setState(() {
      for (var club in _availableClubs) {
        club['enabled'] = true;
      }
      _checkForChanges();
    });
    _showSnackBar('Todos os clubes ativados', Symbols.done_all_rounded, Colors.green);
  }

  void _disableAllClubs() {
    setState(() {
      for (var club in _availableClubs) {
        club['enabled'] = false;
      }
      _checkForChanges();
    });
    _showSnackBar('Todos os clubes desativados', Symbols.remove_done_rounded, Colors.orange);
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Symbols.restart_alt_rounded),
        title: const Text('Restaurar Configurações'),
        content: const Text(
          'Deseja restaurar todas as configurações para os valores padrão? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              setState(() {
                // Resetar clubes para configuração padrão
                for (var club in _availableClubs) {
                  final defaultEnabled = [
                    'Manchester City', 'Liverpool', 'Arsenal', 'Chelsea', 
                    'Manchester United', 'Tottenham', 'Real Madrid', 'Barcelona',
                    'Atlético Madrid', 'Inter Milan', 'AC Milan', 'Juventus',
                    'Napoli', 'Bayern Munich', 'Borussia Dortmund', 
                    'Paris Saint-Germain', 'Benfica', 'Porto', 'Sporting CP'
                  ];
                  club['enabled'] = defaultEnabled.contains(club['name']);
                }
                _showNews = true;
                _showLiveMatches = true;
                _autoRefresh = true;
                _refreshInterval = 30;
              });
              
              // Limpar SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              Navigator.pop(context);
              _showSnackBar('Configurações restauradas', Symbols.check_rounded, Colors.green);
              
              // Recarregar estados originais
              await _loadSettings();
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Salvar configurações
    await prefs.setBool('show_news', _showNews);
    await prefs.setBool('show_live_matches', _showLiveMatches);
    await prefs.setBool('auto_refresh', _autoRefresh);
    await prefs.setInt('refresh_interval', _refreshInterval);
    
    // Salvar clubes habilitados
    final enabledClubs = _availableClubs
        .where((club) => club['enabled'] == true)
        .map((club) => club['name'] as String)
        .toList();
    await prefs.setString('enabled_clubs', jsonEncode(enabledClubs));
    
    // Atualizar estados originais
    _originalShowNews = _showNews;
    _originalShowLiveMatches = _showLiveMatches;
    _originalAutoRefresh = _autoRefresh;
    _originalRefreshInterval = _refreshInterval;
    _originalClubs = _availableClubs.map((club) => Map<String, dynamic>.from(club)).toList();
    
    setState(() {
      _hasChanges = false;
    });
    
    _showSnackBar('Configurações salvas com sucesso', Symbols.check_rounded, Colors.green);
    
    // Aguardar um pouco e voltar
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Symbols.delete_sweep_rounded, color: Colors.orange),
        title: const Text('Limpar Cache'),
        content: const Text(
          'Deseja limpar o cache? Isso pode melhorar o desempenho do aplicativo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              // Aqui você implementaria a limpeza real do cache
              // Por exemplo: deletar arquivos temporários, etc.
              Navigator.pop(context);
              _showSnackBar('Cache limpo com sucesso', Symbols.check_rounded, Colors.orange);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Symbols.history_rounded, color: Colors.red),
        title: const Text('Limpar Histórico'),
        content: const Text(
          'Deseja limpar o histórico de jogos visualizados? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              // Aqui você implementaria a limpeza real do histórico
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('match_history');
              Navigator.pop(context);
              _showSnackBar('Histórico limpo com sucesso', Symbols.check_rounded, Colors.red);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}