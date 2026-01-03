import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'dart:async';
import 'qr_result_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with TickerProviderStateMixin {
  late MobileScannerController cameraController;
  bool isScanning = false;
  bool isTorchOn = false;
  Barcode? detectedBarcode;
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  bool _isProcessingImage = false;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();

    // Configuração otimizada para web
    cameraController = MobileScannerController(
      detectionSpeed: kIsWeb ? DetectionSpeed.noDuplicates : DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: [BarcodeFormat.qrCode],
    );

    // Listener para saber quando a câmera está pronta
    cameraController.start().then((_) {
      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    });

    // Animação da linha de scan
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessingImage) return;

    setState(() {
      _isProcessingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          _isProcessingImage = false;
        });
        return;
      }

      // Mostra loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFFC107),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Analisando imagem...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Analisa a imagem
      final BarcodeCapture? barcodes = await cameraController.analyzeImage(image.path);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        _handleBarcode(barcodes.barcodes.first);
      } else {
        if (mounted) {
          _showErrorSnackbar('Nenhum QR code encontrado na imagem');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorSnackbar('Erro ao analisar imagem');
      }
      debugPrint('Erro ao analisar imagem: $e');
    } finally {
      setState(() {
        _isProcessingImage = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Symbols.error_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleBarcode(Barcode barcode) {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      detectedBarcode = barcode;
    });

    final scannedCode = barcode.rawValue ?? 'Código não identificado';

    // Feedback visual e navegação
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRResultPage(codigo: scannedCode),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            isScanning = false;
            detectedBarcode = null;
          });
        }
      });
    });
  }

  Future<void> _toggleTorch() async {
    if (kIsWeb) {
      _showErrorSnackbar('Flash não disponível na versão web');
      return;
    }

    try {
      await cameraController.toggleTorch();
      setState(() {
        isTorchOn = !isTorchOn;
      });
    } catch (e) {
      _showErrorSnackbar('Erro ao alternar lanterna');
      debugPrint('Erro ao alternar lanterna: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Câmera Scanner
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture capture) {
              if (capture.barcodes.isNotEmpty && !isScanning && _isCameraReady) {
                _handleBarcode(capture.barcodes.first);
              }
            },
          ),

          // Loading inicial
          if (!_isCameraReady)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFFFC107),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Preparando câmera...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Overlay com área de scan e linha animada
          if (_isCameraReady)
            AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScannerOverlayPainter(
                    detectedBarcode: detectedBarcode,
                    scanLineAnimation: _scanLineAnimation.value,
                  ),
                  child: Container(),
                );
              },
            ),

          // Botão voltar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _ActionButton(
                icon: Symbols.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Instrução
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.qr_code_scanner_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Posicione o QR code na área',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botões inferiores
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão Lanterna
                  if (!kIsWeb)
                    _ScannerButton(
                      icon: isTorchOn 
                          ? Symbols.flashlight_on_rounded 
                          : Symbols.flashlight_off_rounded,
                      onPressed: _toggleTorch,
                      isActive: isTorchOn,
                      label: 'Flash',
                    ),

                  // Espaçador se na web
                  if (kIsWeb) const SizedBox(width: 64),

                  // Botão Upload
                  _ScannerButton(
                    icon: Symbols.photo_library_rounded,
                    onPressed: _isProcessingImage ? null : _pickImageFromGallery,
                    isActive: false,
                    label: 'Galeria',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _ScannerButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final String label;

  const _ScannerButton({
    required this.icon,
    required this.onPressed,
    required this.isActive,
    required this.label,
  });

  @override
  State<_ScannerButton> createState() => _ScannerButtonState();
}

class _ScannerButtonState extends State<_ScannerButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onPressed == null) return;

    await _controller.forward();
    await _controller.reverse();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: widget.isActive 
                    ? const Color(0xFFFFC107)
                    : Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.isActive 
                        ? const Color(0xFFFFC107).withOpacity(0.5)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: widget.isActive
                      ? Colors.white.withOpacity(0.3)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(
                widget.icon,
                color: widget.isActive ? Colors.black : Colors.black87,
                size: 30,
                fill: 1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Barcode? detectedBarcode;
  final double scanLineAnimation;

  ScannerOverlayPainter({
    this.detectedBarcode,
    required this.scanLineAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    const scanAreaWidth = 280.0;
    const scanAreaHeight = 280.0;
    final scanLeft = (size.width - scanAreaWidth) / 2;
    final scanTop = (size.height - scanAreaHeight) / 2;

    if (detectedBarcode != null && detectedBarcode!.corners.isNotEmpty) {
      // QR Code detectado
      final corners = detectedBarcode!.corners;

      final qrPath = Path();
      qrPath.moveTo(corners[0].dx, corners[0].dy);
      for (var i = 1; i < corners.length; i++) {
        qrPath.lineTo(corners[i].dx, corners[i].dy);
      }
      qrPath.close();

      final overlayPath = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addPath(qrPath, Offset.zero)
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(overlayPath, overlayPaint);

      // Borda verde
      final borderPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(qrPath, borderPaint);

      // Cantos verdes
      final cornerPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.fill;

      for (var corner in corners) {
        canvas.drawCircle(corner, 6, cornerPaint);
      }
    } else {
      // Área de scan padrão com CANTOS CURVOS
      const radius = 28.0;
      final scanRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(scanLeft, scanTop, scanAreaWidth, scanAreaHeight),
        const Radius.circular(radius),
      );

      final overlayPath = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(scanRect)
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(overlayPath, overlayPaint);

      // Borda sutil
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(scanRect, borderPaint);

      // Cantos amarelos CURVOS
      final cornerPaint = Paint()
        ..color = const Color(0xFFFFC107)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      const cornerLength = 40.0;

      // Canto SUPERIOR ESQUERDO (curvo)
      final topLeftPath = Path()
        ..moveTo(scanLeft, scanTop + cornerLength)
        ..lineTo(scanLeft, scanTop + radius)
        ..arcToPoint(
          Offset(scanLeft + radius, scanTop),
          radius: const Radius.circular(radius),
          clockwise: false,
        )
        ..lineTo(scanLeft + cornerLength, scanTop);
      canvas.drawPath(topLeftPath, cornerPaint);

      // Canto SUPERIOR DIREITO (curvo)
      final topRightPath = Path()
        ..moveTo(scanLeft + scanAreaWidth - cornerLength, scanTop)
        ..lineTo(scanLeft + scanAreaWidth - radius, scanTop)
        ..arcToPoint(
          Offset(scanLeft + scanAreaWidth, scanTop + radius),
          radius: const Radius.circular(radius),
          clockwise: false,
        )
        ..lineTo(scanLeft + scanAreaWidth, scanTop + cornerLength);
      canvas.drawPath(topRightPath, cornerPaint);

      // Canto INFERIOR ESQUERDO (curvo)
      final bottomLeftPath = Path()
        ..moveTo(scanLeft, scanTop + scanAreaHeight - cornerLength)
        ..lineTo(scanLeft, scanTop + scanAreaHeight - radius)
        ..arcToPoint(
          Offset(scanLeft + radius, scanTop + scanAreaHeight),
          radius: const Radius.circular(radius),
          clockwise: false,
        )
        ..lineTo(scanLeft + cornerLength, scanTop + scanAreaHeight);
      canvas.drawPath(bottomLeftPath, cornerPaint);

      // Canto INFERIOR DIREITO (curvo)
      final bottomRightPath = Path()
        ..moveTo(scanLeft + scanAreaWidth - cornerLength, scanTop + scanAreaHeight)
        ..lineTo(scanLeft + scanAreaWidth - radius, scanTop + scanAreaHeight)
        ..arcToPoint(
          Offset(scanLeft + scanAreaWidth, scanTop + scanAreaHeight - radius),
          radius: const Radius.circular(radius),
          clockwise: false,
        )
        ..lineTo(scanLeft + scanAreaWidth, scanTop + scanAreaHeight - cornerLength);
      canvas.drawPath(bottomRightPath, cornerPaint);

      // Linha de scan ANIMADA
      final scanLineY = scanTop + (scanAreaHeight * scanLineAnimation);
      final scanLinePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFC107).withOpacity(0.0),
            const Color(0xFFFFC107).withOpacity(0.9),
            const Color(0xFFFFC107).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(scanLeft, scanLineY - 3, scanAreaWidth, 6))
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(scanLeft + 15, scanLineY - 2, scanAreaWidth - 30, 4),
          const Radius.circular(2),
        ),
        scanLinePaint,
      );

      // Brilho da linha
      final glowPaint = Paint()
        ..color = const Color(0xFFFFC107).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(scanLeft + 15, scanLineY - 2, scanAreaWidth - 30, 4),
          const Radius.circular(2),
        ),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.detectedBarcode != detectedBarcode ||
           oldDelegate.scanLineAnimation != scanLineAnimation;
  }
}