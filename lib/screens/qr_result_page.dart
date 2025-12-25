// ==================== qr_result_page.dart ====================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'verificacao_webview_page.dart';

class QRResultPage extends StatefulWidget {
  final String codigo;

  const QRResultPage({super.key, required this.codigo});

  @override
  State<QRResultPage> createState() => _QRResultPageState();
}

class _QRResultPageState extends State<QRResultPage> {
  bool copiado = false;

  void _copiarCodigo() {
    Clipboard.setData(ClipboardData(text: widget.codigo));
    setState(() {
      copiado = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Código copiado!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _verificarCodigo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VerificacaoWebViewPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _AnimatedIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'QR Code Detectado',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // QR Code gerado
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: QrImageView(
                data: widget.codigo,
                version: QrVersions.auto,
                size: 240,
                backgroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Código em texto
            SelectableText(
              widget.codigo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const Spacer(),
            
            // Botão Copiar/Verificar
            _AnimatedButton(
              onPressed: copiado ? _verificarCodigo : _copiarCodigo,
              backgroundColor: const Color(0xFFFF444F),
              child: Text(
                copiado ? 'Verificar' : 'Copiar Código',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Botão animado reutilizável
class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget child;

  const _AnimatedButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.child,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.88)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    _controller.reset();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Material(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(27),
        elevation: 0,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(27),
          child: Container(
            width: double.infinity,
            height: 54,
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// Botão de ícone animado
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AnimatedIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(widget.icon),
        onPressed: _handleTap,
      ),
    );
  }
}