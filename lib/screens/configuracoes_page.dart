import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  void _mostrarDialogTema(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tema do Aplicativo'),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Sistema'),
                value: ThemeMode.system,
                groupValue: appState.modoTema,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    appState.alterarModoTema(value);
                    Navigator.of(context).pop();
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Claro'),
                value: ThemeMode.light,
                groupValue: appState.modoTema,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    appState.alterarModoTema(value);
                    Navigator.of(context).pop();
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Escuro'),
                value: ThemeMode.dark,
                groupValue: appState.modoTema,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    appState.alterarModoTema(value);
                    Navigator.of(context).pop();
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  String _obterTextoTema(ThemeMode modo) {
    switch (modo) {
      case ThemeMode.system:
        return 'Sistema';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Scaffold(
      backgroundColor: brightness == Brightness.light 
          ? Colors.grey.shade50 
          : Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: brightness == Brightness.light 
            ? Colors.white 
            : Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Seção: APARÊNCIA
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
                child: Text(
                  'APARÊNCIA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: brightness == Brightness.light 
                      ? Colors.white 
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: brightness == Brightness.light
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Cor Dinâmica',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Usar vermelho ao invés de azul',
                        style: TextStyle(
                          color: brightness == Brightness.light 
                              ? Colors.grey.shade600 
                              : Colors.grey.shade400,
                        ),
                      ),
                      secondary: Icon(
                        Symbols.palette_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      value: appState.corDinamica,
                      onChanged: (v) => appState.alternarCorDinamica(v),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    Divider(
                      height: 1,
                      indent: 72,
                      color: brightness == Brightness.light 
                          ? Colors.grey.shade200 
                          : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                    ListTile(
                      leading: Icon(
                        Symbols.contrast_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text(
                        'Tema',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _obterTextoTema(appState.modoTema),
                        style: TextStyle(
                          color: brightness == Brightness.light 
                              ? Colors.grey.shade600 
                              : Colors.grey.shade400,
                        ),
                      ),
                      trailing: Icon(
                        Symbols.arrow_forward_ios_rounded,
                        size: 16,
                        color: brightness == Brightness.light 
                            ? Colors.grey.shade400 
                            : Colors.grey.shade600,
                      ),
                      onTap: () => _mostrarDialogTema(context, appState),
                      shape: RoundedRectangleBorder(
                        borderRadius: appState.temaEscuro 
                            ? BorderRadius.zero 
                            : const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    if (appState.temaEscuro) ...[
                      Divider(
                        height: 1,
                        indent: 72,
                        color: brightness == Brightness.light 
                            ? Colors.grey.shade200 
                            : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                      SwitchListTile(
                        title: const Text(
                          'Escuro Profundo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Usar tema preto puro',
                          style: TextStyle(
                            color: brightness == Brightness.light 
                                ? Colors.grey.shade600 
                                : Colors.grey.shade400,
                          ),
                        ),
                        secondary: Icon(
                          Symbols.brightness_low_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        value: appState.temaEscuroProfundo,
                        onChanged: (v) => appState.alternarTemaEscuroProfundo(v),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Seção: NOTIFICAÇÕES
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'NOTIFICAÇÕES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: brightness == Brightness.light 
                      ? Colors.white 
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: brightness == Brightness.light
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Notificações Push',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Receber alertas de jogos',
                    style: TextStyle(
                      color: brightness == Brightness.light 
                          ? Colors.grey.shade600 
                          : Colors.grey.shade400,
                    ),
                  ),
                  secondary: Icon(
                    Symbols.notifications_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  value: appState.notificacoesAtivas,
                  onChanged: (v) => appState.alternarNotificacoes(v),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
              ),

              const SizedBox(height: 32),

              // Seção: SOBRE
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'SOBRE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: brightness == Brightness.light 
                      ? Colors.white 
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: brightness == Brightness.light
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: ListTile(
                  leading: Icon(
                    Symbols.info_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Versão do App',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(
                      color: brightness == Brightness.light 
                          ? Colors.grey.shade600 
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}