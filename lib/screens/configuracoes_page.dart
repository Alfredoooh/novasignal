import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  void _mostrarDialogoIndisponivel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opção indisponível'),
        content: const Text('Esta opção ainda não está disponível.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFF5F5F5)
          : Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Seção: APARÊNCIA
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'APARÊNCIA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: SwitchListTile(
                        title: const Text('Cor Dinâmica'),
                        subtitle: const Text('Usar cor azul do Material Design ou vermelho Deriv'),
                        secondary: Icon(
                          Symbols.palette_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        value: false,
                        onChanged: (valor) => _mostrarDialogoIndisponivel(context),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 72,
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                    Opacity(
                      opacity: 0.5,
                      child: SwitchListTile(
                        title: const Text('Tema Escuro'),
                        subtitle: const Text('Ativar modo escuro'),
                        secondary: Icon(
                          Symbols.dark_mode_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        value: false,
                        onChanged: (valor) => _mostrarDialogoIndisponivel(context),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Seção: NOTIFICAÇÕES
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'NOTIFICAÇÕES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  title: const Text('Notificações Push'),
                  subtitle: const Text('Receber alertas de jogos'),
                  secondary: Icon(
                    Symbols.notifications_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  value: appState.notificacoesAtivas,
                  onChanged: appState.alternarNotificacoes,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Seção: SOBRE
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'SOBRE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(
                    Symbols.info_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('Versão do App'),
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}