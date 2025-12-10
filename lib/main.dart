/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';

void main() {
  runApp(const DocuGenApp());
}

class DocuGenApp extends StatelessWidget {
  const DocuGenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'DocuGen AI',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFF212529),
              brightness: Brightness.dark,
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const DocuGenHomePage(),
          );
        },
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;

void main() {
  runApp(const FootballApp());
}

class FootballApp extends StatelessWidget {
  const FootballApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Live',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF444F),
          primary: const Color(0xFFFF444F),
          surface: Colors.white,
          background: const Color(0xFFF8F9FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String _selectedLeague = '';
  bool _isLoading = false;
  List<dynamic> _matches = [];
  List<dynamic> _standings = [];
  List<dynamic> _leagues = [];

  final String _apiKey = '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d';

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    
    try {
      final dateStr = _selectedDate.toIso8601String().split('T')[0];
      final response = await http.get(Uri.parse(
        'https://apiv3.apifootball.com/?action=get_events&from=$dateStr&to=$dateStr&APIkey=$_apiKey'
      ));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _matches = data is List ? data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStandings(String leagueId) async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(Uri.parse(
        'https://apiv3.apifootball.com/?action=get_standings&league_id=$leagueId&APIkey=$_apiKey'
      ));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _standings = data is List ? data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLeagues() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(Uri.parse(
        'https://apiv3.apifootball.com/?action=get_leagues&APIkey=$_apiKey'
      ));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _leagues = data is List ? data.take(100).toList() : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.8),
              title: Text(
                _selectedIndex == 0 ? 'Jogos' : 
                _selectedIndex == 1 ? 'Classificação' : 
                _selectedIndex == 2 ? 'Ligas' : 'Notícias',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                if (_selectedIndex == 0)
                  ExpressiveIconButton(
                    icon: Icons.tune_rounded,
                    onPressed: () => _showFiltersDialog(),
                  ),
                if (_selectedIndex != 3)
                  ExpressiveIconButton(
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      if (_selectedIndex == 0) _loadMatches();
                      else if (_selectedIndex == 1) _loadStandings('152');
                      else if (_selectedIndex == 2) _loadLeagues();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
                if (index == 1 && _standings.isEmpty) _loadStandings('152');
                if (index == 2 && _leagues.isEmpty) _loadLeagues();
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.sports_soccer_outlined),
                  selectedIcon: Icon(Icons.sports_soccer),
                  label: 'Jogos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.leaderboard_outlined),
                  selectedIcon: Icon(Icons.leaderboard),
                  label: 'Tabela',
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: 'Ligas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.newspaper_outlined),
                  selectedIcon: Icon(Icons.newspaper),
                  label: 'Notícias',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ExpressiveFAB(
        onPressed: () {},
        child: const Icon(Icons.arrow_upward_rounded),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: WormLoadingIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return _buildMatchesView();
      case 1:
        return _buildStandingsView();
      case 2:
        return _buildLeaguesView();
      case 3:
        return _buildNewsView();
      default:
        return const SizedBox();
    }
  }

  Widget _buildMatchesView() {
    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: _matches.isEmpty
              ? const EmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'Sem jogos',
                  message: 'Nenhum jogo encontrado para esta data',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _getLeaguesFromMatches().length,
                  itemBuilder: (context, index) {
                    final league = _getLeaguesFromMatches()[index];
                    final leagueMatches = _matches
                        .where((m) => m['league_id'] == league['id'])
                        .toList();
                    
                    return LeagueCard(
                      leagueName: league['name'],
                      leagueCountry: league['country'],
                      leagueLogo: league['logo'],
                      matches: leagueMatches,
                      onLeagueTap: () => _showLeagueDialog(league),
                      onMatchTap: (match) => _showMatchDetails(match),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          ExpressiveIconButton(
            icon: Icons.chevron_left_rounded,
            onPressed: () => _changeDate(-1),
          ),
          Expanded(
            child: Text(
              _formatDate(_selectedDate),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ExpressiveIconButton(
            icon: Icons.chevron_right_rounded,
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getLeaguesFromMatches() {
    final leagues = <String, Map<String, String>>{};
    for (var match in _matches) {
      final id = match['league_id'] ?? '';
      if (!leagues.containsKey(id)) {
        leagues[id] = {
          'id': id,
          'name': match['league_name'] ?? 'Unknown',
          'country': match['country_name'] ?? '',
          'logo': match['league_logo'] ?? '',
        };
      }
    }
    return leagues.values.toList();
  }

  Widget _buildStandingsView() {
    return Column(
      children: [
        _buildStandingsTabs(),
        Expanded(
          child: _standings.isEmpty
              ? const EmptyState(
                  icon: Icons.leaderboard_rounded,
                  title: 'Sem dados',
                  message: 'Classificação não disponível',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return StandingsCard(standings: _standings);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStandingsTabs() {
    final leagues = [
      {'id': '152', 'name': '🏴󠁧󠁢󠁥󠁮󠁧󠁿 Premier League'},
      {'id': '302', 'name': '🇪🇸 La Liga'},
      {'id': '207', 'name': '🇮🇹 Serie A'},
      {'id': '175', 'name': '🇩🇪 Bundesliga'},
      {'id': '168', 'name': '🇫🇷 Ligue 1'},
    ];

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: leagues.length,
        itemBuilder: (context, index) {
          final league = leagues[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ExpressiveChip(
              label: league['name']!,
              onPressed: () => _loadStandings(league['id']!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaguesView() {
    return _leagues.isEmpty
        ? const EmptyState(
            icon: Icons.emoji_events_rounded,
            title: 'Sem ligas',
            message: 'Nenhuma liga disponível',
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 1,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: _leagues.map((league) {
                    return LeagueListTile(
                      leagueName: league['league_name'] ?? 'Unknown',
                      leagueCountry: league['country_name'] ?? '',
                      leagueLogo: league['league_logo'] ?? '',
                      onTap: () => _showLeagueDialog({
                        'id': league['league_id'],
                        'name': league['league_name'],
                        'country': league['country_name'],
                        'logo': league['league_logo'],
                      }),
                    );
                  }).toList(),
                ),
              );
            },
          );
  }

  Widget _buildNewsView() {
    return const EmptyState(
      icon: Icons.newspaper_rounded,
      title: 'Notícias em breve',
      message: 'Esta funcionalidade estará disponível em breve',
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 
                    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    
    return '\${weekdays[date.weekday % 7]}, \${date.day} \${months[date.month - 1]} \${date.year}';
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => ExpressiveDialog(
        title: 'Filtros',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ExpressiveButton(
              label: 'Aplicar',
              onPressed: () {
                Navigator.pop(context);
                _loadMatches();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLeagueDialog(Map<String, String> league) {
    showDialog(
      context: context,
      builder: (context) => ExpressiveDialog(
        title: league['name'] ?? 'Liga',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExpressiveButton(
              label: 'Ver Classificação',
              onPressed: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 1);
                _loadStandings(league['id'] ?? '152');
              },
            ),
            const SizedBox(height: 8),
            ExpressiveButton(
              label: 'Ver Jogos',
              isOutlined: true,
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0;
                  _selectedLeague = league['id'] ?? '';
                });
                _loadMatches();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMatchDetails(Map<String, dynamic> match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailsScreen(match: match),
      ),
    );
  }
}

// CUSTOM WIDGETS COM ANIMAÇÕES EXPRESSIVE

class ExpressiveIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ExpressiveIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<ExpressiveIconButton> createState() => _ExpressiveIconButtonState();
}

class _ExpressiveIconButtonState extends State<ExpressiveIconButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _radiusAnimation = Tween<double>(begin: 20, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _radiusAnimation,
        builder: (context, child) {
          return Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radiusAnimation.value),
              color: Colors.transparent,
            ),
            child: Icon(widget.icon, size: 24),
          );
        },
      ),
    );
  }
}

class ExpressiveButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;

  const ExpressiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  State<ExpressiveButton> createState() => _ExpressiveButtonState();
}

class _ExpressiveButtonState extends State<ExpressiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _radiusAnimation = Tween<double>(begin: 20, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        Future.delayed(const Duration(milliseconds: 100), widget.onPressed);
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _radiusAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radiusAnimation.value),
              color: widget.isOutlined 
                  ? Colors.transparent 
                  : const Color(0xFFFF444F),
              border: widget.isOutlined
                  ? Border.all(color: const Color(0xFFFF444F))
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.isOutlined 
                    ? const Color(0xFFFF444F) 
                    : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExpressiveChip extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const ExpressiveChip({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<ExpressiveChip> createState() => _ExpressiveChipState();
}

class _ExpressiveChipState extends State<ExpressiveChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _radiusAnimation = Tween<double>(begin: 20, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _radiusAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radiusAnimation.value),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExpressiveFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ExpressiveFAB({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  State<ExpressiveFAB> createState() => _ExpressiveFABState();
}

class _ExpressiveFABState extends State<ExpressiveFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _radiusAnimation = Tween<double>(begin: 16, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _radiusAnimation,
        builder: (context, child) {
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radiusAnimation.value),
              color: const Color(0xFFFF444F),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF444F).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

// WORM LOADING INDICATOR (Material 3 Expressive)
class WormLoadingIndicator extends StatefulWidget {
  const WormLoadingIndicator({super.key});

  @override
  State<WormLoadingIndicator> createState() => _WormLoadingIndicatorState();
}

class _WormLoadingIndicatorState extends State<WormLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: WormLoadingPainter(_controller.value),
          );
        },
      ),
    );
  }
}

class WormLoadingPainter extends CustomPainter {
  final double progress;

  WormLoadingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF444F)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    final startAngle = progress * 2 * math.pi;
    final sweepAngle = math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ExpressiveDialog extends StatelessWidget {
  final String title;
  final Widget child;

  const ExpressiveDialog({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class LeagueCard extends StatelessWidget {
  final String leagueName;
  final String leagueCountry;
  final String leagueLogo;
  final List<dynamic> matches;
  final VoidCallback onLeagueTap;
  final Function(Map<String, dynamic>) onMatchTap;

  const LeagueCard({
    super.key,
    required this.leagueName,
    required this.leagueCountry,
    required this.leagueLogo,
    required this.matches,
    required this.onLeagueTap,
    required this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onLeagueTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Image.network(
                    leagueLogo,
                    width: 32,
                    height: 32,
                    errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leagueName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          leagueCountry,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          ...matches.map((match) => MatchTile(
                match: match,
                onTap: () => onMatchTap(match),
              )),
        ],
      ),
    );
  }
}

class MatchTile extends StatelessWidget {
  final Map<String, dynamic> match;
  final VoidCallback onTap;

  const MatchTile({
    super.key,
    required this.match,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = match['match_status'] ?? '';
    Color badgeColor = Colors.green.shade50;
    Color badgeTextColor = Colors.green.shade700;
    
    if (status.contains('Finished')) {
      badgeColor = Colors.grey.shade100;
      badgeTextColor = Colors.grey.shade700;
    } else if (status.contains("'") || status == 'Half Time') {
      badgeColor = Colors.red.shade50;
      badgeTextColor = Colors.red.shade700;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      match['match_time'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.isEmpty ? 'Agendado' : status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.network(
                        match['team_home_badge'] ?? '',
                        width: 36,
                        height: 36,
                        errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          match['match_hometeam_name'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        match['match_hometeam_score']?.toString() ?? '-',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        match['match_awayteam_score']?.toString() ?? '-',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          match['match_awayteam_name'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Image.network(
                        match['team_away_badge'] ?? '',
                        width: 36,
                        height: 36,
                        errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StandingsCard extends StatelessWidget {
  final List<dynamic> standings;

  const StandingsCard({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 30, child: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                const Expanded(child: Text('Equipa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(width: 40, child: Text('J', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(width: 40, child: Text('V', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(width: 40, child: Text('E', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(width: 40, child: Text('D', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(width: 40, child: Text('PTS', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          ...standings.map((team) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        team['overall_league_position']?.toString() ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF444F),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Image.network(
                            team['team_badge'] ?? '',
                            width: 28,
                            height: 28,
                            errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, size: 28),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              team['team_name'] ?? '',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 40, child: Text(team['overall_league_payed']?.toString() ?? '0', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                    SizedBox(width: 40, child: Text(team['overall_league_W']?.toString() ?? '0', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                    SizedBox(width: 40, child: Text(team['overall_league_D']?.toString() ?? '0', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                    SizedBox(width: 40, child: Text(team['overall_league_L']?.toString() ?? '0', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                    SizedBox(width: 40, child: Text(team['overall_league_PTS']?.toString() ?? '0', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class LeagueListTile extends StatelessWidget {
  final String leagueName;
  final String leagueCountry;
  final String leagueLogo;
  final VoidCallback onTap;

  const LeagueListTile({
    super.key,
    required this.leagueName,
    required this.leagueCountry,
    required this.leagueLogo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Image.network(
              leagueLogo,
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leagueName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    leagueCountry,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MatchDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> match;

  const MatchDetailsScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Jogo'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Image.network(
                              match['team_home_badge'] ?? '',
                              width: 80,
                              height: 80,
                              errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, size: 80),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              match['match_hometeam_name'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                match['match_hometeam_score']?.toString() ?? '-',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF444F),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF444F),
                                  ),
                                ),
                              ),
                              Text(
                                match['match_awayteam_score']?.toString() ?? '-',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF444F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            match['match_status'] ?? 'Agendado',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${match['match_date']} ${match['match_time']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Image.network(
                              match['team_away_badge'] ?? '',
                              width: 80,
                              height: 80,
                              errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, size: 80),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              match['match_awayteam_name'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFFFF444F)),
                          SizedBox(width: 8),
                          Text(
                            'Informações do Jogo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF444F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Liga', match['league_name'] ?? 'N/A'),
                      _buildInfoRow('País', match['country_name'] ?? 'N/A'),
                      _buildInfoRow('Estádio', match['match_stadium'] ?? 'N/A'),
                      _buildInfoRow('Árbitro', match['match_referee'] ?? 'N/A', isLast: true),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}