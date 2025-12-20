import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'APARÊNCIA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Cor Dinâmica'),
                      subtitle: const Text('Usar cor azul do Material Design ou vermelho Deriv'),
                      secondary: Icon(
                        Symbols.palette_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      value: appState.corDinamica,
                      onChanged: appState.alternarCorDinamica,
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    SwitchListTile(
                      title: const Text('Tema Escuro'),
                      subtitle: const Text('Ativar modo escuro'),
                      secondary: Icon(
                        Symbols.dark_mode_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      value: appState.temaEscuro,
                      onChanged: (valor) {
                        appState.alternarTema(valor);
                        if (!valor) {
                          appState.alternarTemaAmoled(false);
                          appState.alternarTemaEscuroProfundo(false);
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Opções de tema escuro só aparecem se tema escuro estiver ativo
              if (appState.temaEscuro) ...[
                const SizedBox(height: 8),
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Tema Escuro Profundo'),
                        subtitle: const Text('Tons mais escuros e contraste elevado'),
                        secondary: Icon(
                          Symbols.contrast_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        value: appState.temaEscuroProfundo,
                        onChanged: (valor) {
                          appState.alternarTemaEscuroProfundo(valor);
                          if (valor) {
                            appState.alternarTemaAmoled(false);
                          }
                        },
                      ),
                      Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      SwitchListTile(
                        title: const Text('Tema AMOLED'),
                        subtitle: const Text('Preto puro para telas OLED'),
                        secondary: Icon(
                          Symbols.brightness_1_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        value: appState.temaAmoled,
                        onChanged: (valor) {
                          appState.alternarTemaAmoled(valor);
                          if (valor) {
                            appState.alternarTemaEscuroProfundo(false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'NOTIFICAÇÕES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: SwitchListTile(
                  title: const Text('Notificações Push'),
                  subtitle: const Text('Receber alertas de jogos'),
                  secondary: Icon(
                    Symbols.notifications_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  value: appState.notificacoesAtivas,
                  onChanged: appState.alternarNotificacoes,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'SOBRE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surface,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}