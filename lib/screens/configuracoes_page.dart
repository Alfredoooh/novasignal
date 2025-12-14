import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Preferências',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Tema Escuro', style: TextStyle(fontSize: 15)),
                value: appState.temaEscuro,
                onChanged: appState.alternarTema,
                secondary: Icon(Symbols.dark_mode_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Divider(height: 1, indent: 72, color: Theme.of(context).dividerColor.withOpacity(0.3)),
              SwitchListTile(
                title: const Text('Notificações', style: TextStyle(fontSize: 15)),
                subtitle: const Text('Receber alertas de jogos', style: TextStyle(fontSize: 13)),
                value: appState.notificacoesAtivas,
                onChanged: appState.alternarNotificacoes,
                secondary: Icon(Symbols.notifications_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Sobre',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Symbols.info_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                title: const Text('Versão', style: TextStyle(fontSize: 15)),
                trailing: const Text('1.0.0', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}