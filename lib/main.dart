import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setTheme(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: MainShell(onThemeChange: _setTheme, themeMode: _themeMode),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final seed = const Color(0xFF6750A4);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      // "não tão profundo" no dark — surface levemente elevada
      surface: brightness == Brightness.dark
          ? const Color(0xFF1C1B22)
          : null,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSecondaryContainer,
            );
          }
          return TextStyle(fontSize: 12, color: scheme.onSurfaceVariant);
        }),
      ),
    );
  }
}

// ─── Shell ───────────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  final void Function(ThemeMode) onThemeChange;
  final ThemeMode themeMode;

  const MainShell({
    super.key,
    required this.onThemeChange,
    required this.themeMode,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    _HomePage(),
    _EditPage(),
    _AgendaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['Home', 'Editar', 'Agenda'][_index],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        actions: _index == 0
            ? [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (v) {
                    if (v == 'theme') _showThemeModal(context);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'theme',
                      child: ListTile(
                        leading: Icon(Icons.palette_outlined),
                        title: Text('Alterar tema'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: _pages[_index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        animationDuration: const Duration(milliseconds: 400),
        indicatorShape: const StadiumBorder(), // pill nativo
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit_rounded),
            label: 'Editar',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Agenda',
          ),
        ],
      ),
    );
  }

  void _showThemeModal(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: cs.surfaceContainerLow,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Aparência',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              _ThemeOption(
                icon: Icons.light_mode_rounded,
                label: 'Claro',
                selected: widget.themeMode == ThemeMode.light,
                onTap: () {
                  widget.onThemeChange(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _ThemeOption(
                icon: Icons.dark_mode_rounded,
                label: 'Escuro suave',
                selected: widget.themeMode == ThemeMode.dark,
                onTap: () {
                  widget.onThemeChange(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _ThemeOption(
                icon: Icons.brightness_auto_rounded,
                label: 'Sistema',
                selected: widget.themeMode == ThemeMode.system,
                onTap: () {
                  widget.onThemeChange(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.secondaryContainer : cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? cs.onSecondaryContainer : cs.onSurface,
                ),
              ),
              const Spacer(),
              if (selected)
                Icon(Icons.check_rounded, color: cs.onSecondaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pages ───────────────────────────────────────────────────────────────────

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.wb_sunny_rounded, color: cs.onPrimaryContainer, size: 32),
              const SizedBox(height: 12),
              Text(
                'Bom dia!',
                style: tt.headlineSmall?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Aqui está o seu resumo de hoje.',
                style: tt.bodyMedium?.copyWith(color: cs.onPrimaryContainer),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Destaques', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...[
          ('Tarefa pendente', Icons.task_alt_rounded),
          ('Reunião às 15h', Icons.video_call_rounded),
          ('Nota rápida', Icons.sticky_note_2_rounded),
        ].map((e) => _SoftCard(icon: e.$2, label: e.$1)),
      ],
    );
  }
}

class _SoftCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SoftCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.secondaryContainer,
          child: Icon(icon, color: cs.onSecondaryContainer, size: 20),
        ),
        title: Text(label),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _EditPage extends StatelessWidget {
  const _EditPage();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text('Editar', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: cs.surfaceContainerLow,
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Descrição',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: cs.surfaceContainerLow,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save_rounded),
          label: const Text('Guardar'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}

class _AgendaPage extends StatelessWidget {
  const _AgendaPage();

  final _events = const [
    ('09:00', 'Reunião de equipa', Icons.groups_rounded),
    ('11:30', 'Revisão de código', Icons.code_rounded),
    ('14:00', 'Almoço com cliente', Icons.restaurant_rounded),
    ('16:00', 'Planeamento semanal', Icons.bar_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text('Agenda', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Hoje', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 20),
        ..._events.map((e) => _EventTile(time: e.$1, title: e.$2, icon: e.$3)),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  final String time;
  final String title;
  final IconData icon;

  const _EventTile({required this.time, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Container(
            width: 2,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: cs.primary),
                  const SizedBox(width: 10),
                  Text(title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}