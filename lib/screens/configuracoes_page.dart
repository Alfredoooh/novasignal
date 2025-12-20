import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'dart:math' show cos, sin;
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
                      subtitle: const Text('Usar cor azul adaptativa ou vermelho Deriv'),
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
                      ListTile(
                        leading: Icon(
                          Symbols.contrast_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        title: const Text('Tema Escuro Profundo'),
                        subtitle: const Text('Tons mais escuros e contraste elevado'),
                        trailing: AnimatedCheckbox(
                          value: appState.temaEscuroProfundo,
                          onChanged: (valor) {
                            appState.alternarTemaEscuroProfundo(valor);
                            if (valor) {
                              appState.alternarTemaAmoled(false);
                            }
                          },
                        ),
                      ),
                      Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ListTile(
                        leading: Icon(
                          Symbols.brightness_1_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        title: const Text('Tema AMOLED'),
                        subtitle: const Text('Preto puro para telas OLED'),
                        trailing: AnimatedCheckbox(
                          value: appState.temaAmoled,
                          onChanged: (valor) {
                            appState.alternarTemaAmoled(valor);
                            if (valor) {
                              appState.alternarTemaEscuroProfundo(false);
                            }
                          },
                        ),
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

// Checkbox Animado Customizado com efeito splash verde
class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox> with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _splashController;
  late Animation<double> _checkAnimation;
  late Animation<double> _splashAnimation;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _splashController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _splashAnimation = CurvedAnimation(
      parent: _splashController,
      curve: Curves.easeOut,
    );

    if (widget.value) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _splashController.forward(from: 0.0);
        _checkController.forward();
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Splash effect
            AnimatedBuilder(
              animation: _splashAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SplashPainter(
                    progress: _splashAnimation.value,
                    color: const Color(0xFF4CAF50),
                  ),
                );
              },
            ),
            // Checkbox circle
            AnimatedBuilder(
              animation: _checkController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CheckboxPainter(
                    checked: widget.value,
                    checkProgress: _checkAnimation.value,
                    color: const Color(0xFF4CAF50),
                    borderColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  size: const Size(28, 28),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxPainter extends CustomPainter {
  final bool checked;
  final double checkProgress;
  final Color color;
  final Color borderColor;

  _CheckboxPainter({
    required this.checked,
    required this.checkProgress,
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Border
    final borderPaint = Paint()
      ..color = checked ? color : borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius - 1, borderPaint);

    // Fill quando checked
    if (checked) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius - 1, fillPaint);
    }

    // Check mark
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();

      // Desenhar check mark
      final startX = size.width * 0.25;
      final startY = size.height * 0.5;
      final midX = size.width * 0.42;
      final midY = size.height * 0.68;
      final endX = size.width * 0.75;
      final endY = size.height * 0.32;

      path.moveTo(startX, startY);

      if (checkProgress < 0.5) {
        final progress = checkProgress * 2;
        path.lineTo(
          startX + (midX - startX) * progress,
          startY + (midY - startY) * progress,
        );
      } else {
        path.lineTo(midX, midY);
        final progress = (checkProgress - 0.5) * 2;
        path.lineTo(
          midX + (endX - midX) * progress,
          midY + (endY - midY) * progress,
        );
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_CheckboxPainter oldDelegate) {
    return oldDelegate.checked != checked ||
        oldDelegate.checkProgress != checkProgress;
  }
}

class _SplashPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SplashPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Calcular opacidade baseada no progresso
    double opacity;
    if (progress < 0.4) {
      opacity = progress / 0.4;
    } else {
      opacity = 1 - ((progress - 0.4) / 0.6);
    }

    final paint = Paint()
      ..color = color.withOpacity(opacity * 0.4)
      ..style = PaintingStyle.fill;

    // Desenhar 6 círculos ao redor (efeito splash)
    final angle = 60.0;
    final maxDistance = 18.0 * progress;

    for (int i = 0; i < 6; i++) {
      final rad = (angle * i) * (3.14159 / 180);
      final x = center.dx + maxDistance * cos(rad);
      final y = center.dy + maxDistance * sin(rad);

      double circleSize;
      if (progress < 0.4) {
        circleSize = 4 * (progress / 0.4);
      } else {
        circleSize = 4 * (1 - ((progress - 0.4) / 0.6));
      }

      canvas.drawCircle(Offset(x, y), circleSize, paint);
    }
  }

  @override
  bool shouldRepaint(_SplashPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}