// ==================== scanner_page.dart ====================
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'qr_result_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool isScanning = false;
  bool isTorchOn = false;
  Barcode? detectedBarcode;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final BarcodeCapture? barcodes = await cameraController.analyzeImage(image.path);
      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        _handleBarcode(barcodes.barcodes.first);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum QR code encontrado na imagem'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleBarcode(Barcode barcode) {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      detectedBarcode = barcode;
    });

    final scannedCode = barcode.rawValue ?? 'Código não identificado';

    // Navega para página de resultado
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRResultPage(codigo: scannedCode),
        ),
      ).then((_) {
        setState(() {
          isScanning = false;
          detectedBarcode = null;
        });
      });
    });
  }

  void _toggleTorch() {
    setState(() {
      isTorchOn = !isTorchOn;
    });
    cameraController.toggleTorch();
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
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                _handleBarcode(barcodes.first);
              }
            },
          ),

          // Overlay com bordas amarelas e destaque do QR
          CustomPaint(
            painter: ScannerOverlayPainter(detectedBarcode: detectedBarcode),
            child: Container(),
          ),

          // Botão de voltar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _AnimatedIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Texto instrução
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Aponte a câmera para o QR code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Botões inferiores
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão Lanterna
                _AnimatedCircleButton(
                  icon: isTorchOn ? Icons.flash_on : Icons.flash_off,
                  onPressed: _toggleTorch,
                  backgroundColor: isTorchOn ? Colors.amber : Colors.white,
                  iconColor: isTorchOn ? Colors.white : Colors.black,
                ),
                // Botão Upload
                _AnimatedCircleButton(
                  icon: Icons.upload_outlined,
                  onPressed: _pickImageFromGallery,
                  backgroundColor: Colors.white,
                  iconColor: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Botão circular animado
class _AnimatedCircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;

  const _AnimatedCircleButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  State<_AnimatedCircleButton> createState() => _AnimatedCircleButtonState();
}

class _AnimatedCircleButtonState extends State<_AnimatedCircleButton>
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
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: 28,
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
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

// Custom Painter para o overlay com bordas amarelas e destaque do QR
class ScannerOverlayPainter extends CustomPainter {
  final Barcode? detectedBarcode;

  ScannerOverlayPainter({this.detectedBarcode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    const scanAreaWidth = 280.0;
    const scanAreaHeight = 360.0;
    final scanLeft = (size.width - scanAreaWidth) / 2;
    final scanTop = (size.height - scanAreaHeight) / 2;

    // Se QR detectado, destacar a área específica
    if (detectedBarcode != null && detectedBarcode!.corners.isNotEmpty) {
      final corners = detectedBarcode!.corners;
      
      // Desenha overlay escuro exceto na área do QR
      final qrPath = Path()
        ..moveTo(corners[0].dx, corners[0].dy);
      
      for (var i = 1; i < corners.length; i++) {
        qrPath.lineTo(corners[i].dx, corners[i].dy);
      }
      qrPath.close();

      final overlayPath = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addPath(qrPath, Offset.zero)
        ..fillType = PathFillType.evenOdd;

      canvas.drawPath(overlayPath, paint);

      // Desenha borda verde ao redor do QR detectado
      final borderPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawPath(qrPath, borderPaint);
    } else {
      // Área de scan padrão
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(scanLeft, scanTop, scanAreaWidth, scanAreaHeight),
          const Radius.circular(16),
        ))
        ..fillType = PathFillType.evenOdd;

      canvas.drawPath(path, paint);

      final borderPaint = Paint()
        ..color = const Color(0xFFFFC107)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      const cornerLength = 40.0;
      const radius = 16.0;

      // Cantos superiores e inferiores
      canvas.drawPath(
        Path()
          ..moveTo(scanLeft, scanTop + cornerLength)
          ..lineTo(scanLeft, scanTop + radius)
          ..arcToPoint(
            Offset(scanLeft + radius, scanTop),
            radius: const Radius.circular(radius),
          )
          ..lineTo(scanLeft + cornerLength, scanTop),
        borderPaint,
      );

      canvas.drawPath(
        Path()
          ..moveTo(scanLeft + scanAreaWidth - cornerLength, scanTop)
          ..lineTo(scanLeft + scanAreaWidth - radius, scanTop)
          ..arcToPoint(
            Offset(scanLeft + scanAreaWidth, scanTop + radius),
            radius: const Radius.circular(radius),
          )
          ..lineTo(scanLeft + scanAreaWidth, scanTop + cornerLength),
        borderPaint,
      );

      canvas.drawPath(
        Path()
          ..moveTo(scanLeft, scanTop + scanAreaHeight - cornerLength)
          ..lineTo(scanLeft, scanTop + scanAreaHeight - radius)
          ..arcToPoint(
            Offset(scanLeft + radius, scanTop + scanAreaHeight),
            radius: const Radius.circular(radius),
          )
          ..lineTo(scanLeft + cornerLength, scanTop + scanAreaHeight),
        borderPaint,
      );

      canvas.drawPath(
        Path()
          ..moveTo(scanLeft + scanAreaWidth - cornerLength, scanTop + scanAreaHeight)
          ..lineTo(scanLeft + scanAreaWidth - radius, scanTop + scanAreaHeight)
          ..arcToPoint(
            Offset(scanLeft + scanAreaWidth, scanTop + scanAreaHeight - radius),
            radius: const Radius.circular(radius),
          )
          ..lineTo(scanLeft + scanAreaWidth, scanTop + scanAreaHeight - cornerLength),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.detectedBarcode != detectedBarcode;
  }
}