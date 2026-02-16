import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF18191A),
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chamadas',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3A3B3C),
          surface: Color(0xFF242526),
          background: Color(0xFF18191A),
          onPrimary: Colors.white,
          onSurface: Color(0xFFE4E6EB),
          onBackground: Color(0xFFE4E6EB),
        ),
        scaffoldBackgroundColor: const Color(0xFF18191A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF242526),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFFE4E6EB),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF242526),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamadas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3A3B3C),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF4E4F50),
                  borderRadius: BorderRadius.circular(24),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: const Color(0xFFE4E6EB),
                unselectedLabelColor: const Color(0xFFB0B3B8),
                labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Recentes'),
                  Tab(text: 'Contactos'),
                  Tab(text: 'Grupos'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RecentCallsTab(),
          ContactsTab(),
          GroupsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00A884),
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }
}

class RecentCallsTab extends StatelessWidget {
  const RecentCallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final calls = [
      {'name': 'João Silva', 'time': 'Hoje, 14:32', 'type': 'incoming', 'answered': true},
      {'name': 'Maria Costa', 'time': 'Hoje, 12:15', 'type': 'outgoing', 'answered': true},
      {'name': 'Pedro Santos', 'time': 'Ontem, 22:48', 'type': 'incoming', 'answered': false},
      {'name': 'Ana Ferreira', 'time': 'Ontem, 18:20', 'type': 'outgoing', 'answered': true},
      {'name': 'Carlos Oliveira', 'time': '15 Fev, 16:55', 'type': 'incoming', 'answered': true},
      {'name': 'Sofia Rodrigues', 'time': '14 Fev, 21:10', 'type': 'outgoing', 'answered': false},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        final isIncoming = call['type'] == 'incoming';
        final answered = call['answered'] as bool;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF3A3B3C),
              child: Text(
                call['name'].toString()[0],
                style: const TextStyle(color: Color(0xFFE4E6EB), fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              call['name'].toString(),
              style: const TextStyle(color: Color(0xFFE4E6EB), fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Icon(
                  isIncoming ? Icons.call_received : Icons.call_made,
                  size: 16,
                  color: answered ? const Color(0xFF00A884) : const Color(0xFFFA383E),
                ),
                const SizedBox(width: 6),
                Text(
                  call['time'].toString(),
                  style: const TextStyle(color: Color(0xFFB0B3B8), fontSize: 14),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Color(0xFF00A884)),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: Color(0xFF00A884)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ContactsTab extends StatelessWidget {
  const ContactsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      'Ana Ferreira',
      'Carlos Oliveira',
      'João Silva',
      'Maria Costa',
      'Pedro Santos',
      'Sofia Rodrigues',
      'Tiago Almeida',
      'Beatriz Lima',
      'Ricardo Sousa',
      'Catarina Dias',
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF3A3B3C),
              child: Text(
                contact[0],
                style: const TextStyle(color: Color(0xFFE4E6EB), fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              contact,
              style: const TextStyle(color: Color(0xFFE4E6EB), fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Disponível',
              style: TextStyle(color: Color(0xFFB0B3B8), fontSize: 14),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Color(0xFF00A884)),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: Color(0xFF00A884)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = [
      {'name': 'Família', 'members': '8 membros'},
      {'name': 'Trabalho', 'members': '12 membros'},
      {'name': 'Amigos', 'members': '15 membros'},
      {'name': 'Futebol', 'members': '22 membros'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF3A3B3C),
              child: const Icon(Icons.group, color: Color(0xFFE4E6EB)),
            ),
            title: Text(
              group['name'].toString(),
              style: const TextStyle(color: Color(0xFFE4E6EB), fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              group['members'].toString(),
              style: const TextStyle(color: Color(0xFFB0B3B8), fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.videocam, color: Color(0xFF00A884)),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}