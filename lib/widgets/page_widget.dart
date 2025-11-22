import 'package:flutter/material.dart';

enum PaperSize {
  a4,
  a5,
  letter,
  legal,
  a3,
  tabloid,
}

class PaperDimensions {
  final double width;
  final double height;
  final int maxChars;
  final int charsPerLine;
  final int linesPerPage;

  const PaperDimensions({
    required this.width,
    required this.height,
    required this.maxChars,
    required this.charsPerLine,
    required this.linesPerPage,
  });

  static const Map<PaperSize, PaperDimensions> dimensions = {
    PaperSize.a4: PaperDimensions(
      width: 595.0,  // 210mm
      height: 842.0, // 297mm
      maxChars: 3026,
      charsPerLine: 75,
      linesPerPage: 40,
    ),
    PaperSize.a5: PaperDimensions(
      width: 420.0,  // 148mm
      height: 595.0, // 210mm
      maxChars: 1800,
      charsPerLine: 50,
      linesPerPage: 36,
    ),
    PaperSize.letter: PaperDimensions(
      width: 612.0,  // 8.5 inches
      height: 792.0, // 11 inches
      maxChars: 2900,
      charsPerLine: 75,
      linesPerPage: 38,
    ),
    PaperSize.legal: PaperDimensions(
      width: 612.0,  // 8.5 inches
      height: 1008.0, // 14 inches
      maxChars: 3800,
      charsPerLine: 75,
      linesPerPage: 50,
    ),
    PaperSize.a3: PaperDimensions(
      width: 842.0,  // 297mm
      height: 1191.0, // 420mm
      maxChars: 6000,
      charsPerLine: 100,
      linesPerPage: 60,
    ),
    PaperSize.tabloid: PaperDimensions(
      width: 792.0,  // 11 inches
      height: 1224.0, // 17 inches
      maxChars: 5800,
      charsPerLine: 95,
      linesPerPage: 60,
    ),
  };
}

class PageWidget extends StatelessWidget {
  final TextEditingController controller;
  final int pageNumber;
  final int totalPages;
  final double fontSize;
  final String fontFamily;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final TextAlign textAlign;
  final VoidCallback? onTextChanged;
  final PaperSize paperSize;

  // Margens padrão em pontos
  static const double marginTop = 72.0;
  static const double marginBottom = 72.0;
  static const double marginLeft = 72.0;
  static const double marginRight = 72.0;

  const PageWidget({
    super.key,
    required this.controller,
    required this.pageNumber,
    required this.totalPages,
    this.fontSize = 12.0,
    this.fontFamily = 'Roboto',
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.textAlign = TextAlign.left,
    this.onTextChanged,
    this.paperSize = PaperSize.a4,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = PaperDimensions.dimensions[paperSize]!;
    
    // Calcula a largura disponível na tela
    final screenWidth = MediaQuery.of(context).size.width - 40;
    
    // Escala a página mantendo a proporção
    final pageWidth = screenWidth.clamp(0.0, dimensions.width);
    final pageHeight = pageWidth * (dimensions.height / dimensions.width);

    return Container(
      width: pageWidth,
      height: pageHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Área de texto
          Padding(
            padding: EdgeInsets.fromLTRB(
              marginLeft * (pageWidth / dimensions.width),
              marginTop * (pageHeight / dimensions.height),
              marginRight * (pageWidth / dimensions.width),
              marginBottom * (pageHeight / dimensions.height) + 35,
            ),
            child: TextField(
              controller: controller,
              maxLength: dimensions.maxChars,
              maxLines: null,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: fontSize * (pageWidth / dimensions.width),
                fontFamily: fontFamily,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
                height: 1.5,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                if (onTextChanged != null) {
                  onTextChanged!();
                }
              },
            ),
          ),
          
          // Número da página
          Positioned(
            bottom: 20 * (pageHeight / dimensions.height),
            right: marginRight * (pageWidth / dimensions.width),
            child: Text(
              'Página $pageNumber de $totalPages',
              style: TextStyle(
                fontSize: 10 * (pageWidth / dimensions.width),
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ),
          
          // Indicador de tamanho do papel
          Positioned(
            bottom: 20 * (pageHeight / dimensions.height),
            left: marginLeft * (pageWidth / dimensions.width),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF375F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${paperSize.name.toUpperCase()} • ${controller.text.length}/${dimensions.maxChars}',
                style: TextStyle(
                  fontSize: 9 * (pageWidth / dimensions.width),
                  color: controller.text.length > dimensions.maxChars * 0.9
                      ? const Color(0xFFFF375F)
                      : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}