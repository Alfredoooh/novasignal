import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:ui';

class FormattingToolbar extends StatelessWidget {
  final double fontSize;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final TextAlign textAlign;
  final String currentFont;
  final Function(double) onFontSizeChanged;
  final VoidCallback onBoldToggle;
  final VoidCallback onItalicToggle;
  final VoidCallback onUnderlineToggle;
  final Function(TextAlign) onAlignChanged;
  final Function(String) onFontChanged;
  final VoidCallback onAddPage;
  final VoidCallback onExport;

  const FormattingToolbar({
    super.key,
    required this.fontSize,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.textAlign,
    required this.currentFont,
    required this.onFontSizeChanged,
    required this.onBoldToggle,
    required this.onItalicToggle,
    required this.onUnderlineToggle,
    required this.onAlignChanged,
    required this.onFontChanged,
    required this.onAddPage,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildToolbarButton(
                    icon: Ionicons.text_outline,
                    isActive: false,
                    onTap: () => _showFontPicker(context),
                  ),
                  const SizedBox(width: 4),
                  _buildToolbarButton(
                    icon: Ionicons.resize_outline,
                    isActive: false,
                    onTap: () => _showFontSizePicker(context),
                  ),
                  const SizedBox(width: 12),
                  _buildToolbarButton(
                    icon: Ionicons.bold,
                    isActive: isBold,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onBoldToggle();
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildToolbarButton(
                    icon: Ionicons.italic,
                    isActive: isItalic,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onItalicToggle();
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildToolbarButton(
                    icon: Ionicons.underline_outline,
                    isActive: isUnderline,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onUnderlineToggle();
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildToolbarButton(
                    icon: Ionicons.text_outline,
                    isActive: textAlign == TextAlign.left,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onAlignChanged(TextAlign.left);
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildToolbarButton(
                    icon: Ionicons.reorder_two_outline,
                    isActive: textAlign == TextAlign.center,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onAlignChanged(TextAlign.center);
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildToolbarButton(
                    icon: Ionicons.text_outline,
                    isActive: textAlign == TextAlign.right,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onAlignChanged(TextAlign.right);
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildToolbarButton(
                    icon: Ionicons.reorder_four_outline,
                    isActive: textAlign == TextAlign.justify,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onAlignChanged(TextAlign.justify);
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildToolbarButton(
                    icon: Ionicons.add_circle_outline,
                    isActive: false,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onAddPage();
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildToolbarButton(
                    icon: Ionicons.share_outline,
                    isActive: false,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onExport();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFFFF375F).withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive 
                ? const Color(0xFFFF375F)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFFFF375F) : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _showFontPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    
    final fonts = [
      'Roboto',
      'Arial',
      'Times New Roman',
      'Courier New',
      'Georgia',
      'Verdana',
      'Comic Sans MS',
      'Impact',
      'Palatino',
      'Garamond',
      'Bookman',
      'Trebuchet MS',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E).withOpacity(0.95),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selecionar Fonte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: fonts.length,
                    itemBuilder: (context, index) {
                      final font = fonts[index];
                      final isSelected = font == currentFont;
                      
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onFontChanged(font);
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF375F).withOpacity(0.2)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF375F)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            font,
                            style: TextStyle(
                              fontFamily: font,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFontSizePicker(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E).withOpacity(0.95),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tamanho da Fonte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  '${fontSize.toInt()}pt',
                  style: const TextStyle(
                    color: Color(0xFFFF375F),
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFFFF375F),
                    inactiveTrackColor: Colors.white.withOpacity(0.2),
                    thumbColor: const Color(0xFFFF375F),
                    overlayColor: const Color(0xFFFF375F).withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: fontSize,
                    min: 8,
                    max: 72,
                    divisions: 64,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      onFontSizeChanged(value);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '8pt',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '72pt',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}