import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
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

  @override
  void initState() {
    super.initState();
    
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    // Animação da linha de scan
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
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
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.amber),
                  SizedBox(height: 16),
                  Text(
                    'Analisando imagem...',
                    style: TextStyle(color: Colors.white, fontSize: 14),
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
        Navigator.of(context).pop(); // Remove loading
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
        Navigator.of(context).pop(); // Remove loading se existir
        _showErrorSnackbar('Erro ao analisar imagem: ${e.toString()}');
      }
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
            const Icon(CupertinoIcons.exclamationmark_circle_fill, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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

    // Feedback háptico e visual
    Future.delayed(const Duration(milliseconds: 300), () {
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
    try {
      await cameraController.toggleTorch();
      setState(() {
        isTorchOn = !isTorchOn;
      });
    } catch (e) {
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
              if (capture.barcodes.isNotEmpty && !isScanning) {
                _handleBarcode(capture.barcodes.first);
              }
            },
          ),

          // Overlay com área de scan e linha animada
          CustomPaint(
            painter: ScannerOverlayPainter(
              detectedBarcode: detectedBarcode,
              scanLineAnimation: _scanLineAnimation.value,
            ),
            child: Container(),
          ),

          // Botão voltar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
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
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: const Text(
                  'Posicione o QR code na área',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),

          // Botões inferiores
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão Lanterna
                  _ScannerButton(
                    icon: isTorchOn ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt_slash_fill,
                    onPressed: _toggleTorch,
                    isActive: isTorchOn,
                    label: 'Flash',
                  ),
                  
                  // Botão Upload
                  _ScannerButton(
                    icon: CupertinoIcons.photo_on_rectangle,
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

class _ScannerButtonState extends State<_ScannerButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.isActive 
                    ? const Color(0xFFFFC107)
                    : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.isActive 
                        ? const Color(0xFFFFC107).withOpacity(0.4)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.isActive ? Colors.black : Colors.black87,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
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
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    const scanAreaWidth = 280.0;
    const scanAreaHeight = 280.0;
    final scanLeft = (size.width - scanAreaWidth) / 2;
    final scanTop = (size.height - scanAreaHeight) / 2;

    if (detectedBarcode != null && detectedBarcode!.corners.isNotEmpty) {
      // QR Code detectado - destaca área específica
      final corners = detectedBarcode!.corners;
      
      final qrPath = Path();
      qrPath.moveTo(corners[0].dx, corners[0].dy);
      for (var i = 1; i < corners.length; i++) {
        qrPath.lineTo(corners[i].dx, corners[i].dy);
      }
      qrPath.close();

      // Overlay escuro ao redor
      final overlayPath = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addPath(qrPath, Offset.zero)
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(overlayPath, overlayPaint);

      // Borda verde animada
      final borderPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(qrPath, borderPaint);

      // Efeito de canto verde
      final cornerPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < corners.length; i++) {
        canvas.drawCircle(corners[i], 5, cornerPaint);
      }
    } else {
      // Área de scan padrão
      final scanRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(scanLeft, scanTop, scanAreaWidth, scanAreaHeight),
        const Radius.circular(24),
      );

      final overlayPath = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(scanRect)
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(overlayPath, overlayPaint);

      // Cantos amarelos
      final cornerPaint = Paint()
        ..color = const Color(0xFFFFC107)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      const cornerLength = 35.0;
      const radius = 24.0;

      // Canto superior esquerdo
      final topLeftPath = Path()
        ..moveTo(scanLeft, scanTop + cornerLength)
        ..lineTo(scanLeft, scanTop + radius)
        ..arcToPoint(
          Offset(scanLeft + radius, scanTop),
          radius: const Radius.circular(radius),
        )
        ..lineTo(scanLeft + cornerLength, scanTop);
      canvas.drawPath(topLeftPath, cornerPaint);

      // Canto superior direito
      final topRightPath = Path()
        ..moveTo(scanLeft + scanAreaWidth - cornerLength, scanTop)
        ..lineTo(scanLeft + scanAreaWidth - radius, scanTop)
        ..arcToPoint(
          Offset(scanLeft + scanAreaWidth, scanTop + radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(scanLeft + scanAreaWidth, scanTop + cornerLength);
      canvas.drawPath(topRightPath, cornerPaint);

      // Canto inferior esquerdo
      final bottomLeftPath = Path()
        ..moveTo(scanLeft, scanTop + scanAreaHeight - cornerLength)
        ..lineTo(scanLeft, scanTop + scanAreaHeight - radius)
        ..arcToPoint(
          Offset(scanLeft + radius, scanTop + scanAreaHeight),
          radius: const Radius.circular(radius),
        )
        ..lineTo(scanLeft + cornerLength, scanTop + scanAreaHeight);
      canvas.drawPath(bottomLeftPath, cornerPaint);

      // Canto inferior direito
      final bottomRightPath = Path()
        ..moveTo(scanLeft + scanAreaWidth - cornerLength, scanTop + scanAreaHeight)
        ..lineTo(scanLeft + scanAreaWidth - radius, scanTop + scanAreaHeight)
        ..arcToPoint(
          Offset(scanLeft + scanAreaWidth, scanTop + scanAreaHeight - radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(scanLeft + scanAreaWidth, scanTop + scanAreaHeight - cornerLength);
      canvas.drawPath(bottomRightPath, cornerPaint);

      // Linha de scan animada
      final scanLineY = scanTop + (scanAreaHeight * scanLineAnimation);
      final scanLinePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFC107).withOpacity(0.0),
            const Color(0xFFFFC107).withOpacity(0.8),
            const Color(0xFFFFC107).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(scanLeft, scanLineY - 2, scanAreaWidth, 4))
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(scanLeft + 10, scanLineY - 2, scanAreaWidth - 20, 4),
          const Radius.circular(2),
        ),
        scanLinePaint,
      );

      // Sombra da linha
      final shadowPaint = Paint()
        ..color = const Color(0xFFFFC107).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(scanLeft + 10, scanLineY - 1, scanAreaWidth - 20, 2),
          const Radius.circular(1),
        ),
        shadowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.detectedBarcode != detectedBarcode ||
           oldDelegate.scanLineAnimation != scanLineAnimation;
  }
}