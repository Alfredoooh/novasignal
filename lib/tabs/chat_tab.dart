// lib/tabs/chat_tab.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../widgets/chat_input.dart';
import '../models/chat_message.dart';
import 'package:ionicons/ionicons.dart';

class ChatTab extends StatefulWidget {
  final Function(String htmlContent)? onDocumentGenerated;

  const ChatTab({Key? key, this.onDocumentGenerated}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  static const String _viewType = 'chat-input-only';

  bool _isLoading = false;
  late AnimationController _loadingController;

  static const String _groqApiKey = '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';
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static const String _sendIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 5V19M12 5L6 11M12 5L18 11" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  static const String _stopIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect x="6" y="6" width="12" height="12" rx="2" fill="#FFFFFF"/>
</svg>
''';

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openConversationsScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _ConversationsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: themeProvider.isDarkMode ? const Color(0xFF050810) : Colors.white,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: chatProvider.currentMessages.isEmpty
                      ? _buildEmptyState(themeProvider)
                      : _buildMessageList(themeProvider, chatProvider),
                ),
              ],
            ),
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => _openConversationsScreen(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Ionicons.menu_outline,
                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => chatProvider.createNewConversation(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Ionicons.add_outline,
                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            _buildInputArea(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.chatbubble_ellipses_outline,
            size: 64,
            color: themeProvider.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Comece uma conversa',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envie uma mensagem para iniciar',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeProvider themeProvider, ChatProvider chatProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 120),
      itemCount: chatProvider.currentMessages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == chatProvider.currentMessages.length) {
          return _buildLoadingIndicator(themeProvider);
        }
        return _buildMessageBubble(chatProvider.currentMessages[index], themeProvider, index);
      },
    );
  }

  Widget _buildLoadingIndicator(ThemeProvider themeProvider) {
    final dotColor = themeProvider.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 28,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _animatedDot(0, dotColor),
              const SizedBox(width: 6),
              _animatedDot(1, dotColor),
              const SizedBox(width: 6),
              _animatedDot(2, dotColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedDot(int index, Color color) {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        final phase = _loadingController.value * 2 * math.pi;
        final offsetY = math.sin(phase + index * 0.9) * 8;
        final scale = 0.8 + (math.sin(phase + index * 0.9) + 1) * 0.1;
        return Transform.translate(
          offset: Offset(0, -offsetY),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeProvider themeProvider, int index) {
    if (message.isUser) {
      return GestureDetector(
        onTap: () => _showEditDialog(context, message, index, themeProvider),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : const Color(0xFF212529),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAiResponseContent(message.text, themeProvider),
              const SizedBox(height: 12),
              _buildActionButtons(message.text, themeProvider),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActionButtons(String messageText, ThemeProvider themeProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Ionicons.copy_outline,
          onTap: () {
            Clipboard.setData(ClipboardData(text: messageText));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Copiado!'),
                duration: const Duration(seconds: 2),
                backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0D1117) : const Color(0xFF212529),
              ),
            );
          },
          themeProvider: themeProvider,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Ionicons.share_outline,
          onTap: () {
            // Implementar compartilhamento
          },
          themeProvider: themeProvider,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Ionicons.refresh_outline,
          onTap: () {
            // Implementar regeneração
          },
          themeProvider: themeProvider,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Ionicons.thumbs_up_outline,
          onTap: () {
            // Implementar feedback positivo
          },
          themeProvider: themeProvider,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Ionicons.thumbs_down_outline,
          onTap: () {
            // Implementar feedback negativo
          },
          themeProvider: themeProvider,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ChatMessage message, int index, ThemeProvider themeProvider) {
    final controller = TextEditingController(text: message.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0D1117) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Editar mensagem',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              chatProvider.updateMessage(index, controller.text);
              Navigator.pop(context);
            },
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiResponseContent(String text, ThemeProvider themeProvider) {
    if (text.contains('<!DOCTYPE html>') || text.contains('<html')) {
      return _buildDocumentPreview(text, themeProvider);
    }

    return _buildFormattedText(text, themeProvider);
  }

  Widget _buildDocumentPreview(String text, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E88E5).withOpacity(0.1),
                const Color(0xFF1976D2).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1E88E5).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Ionicons.document_text,
                      color: Color(0xFF1E88E5),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📄 Documento Criado',
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'HTML profissional gerado com sucesso',
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Ionicons.checkmark_circle,
                          color: Colors.green.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Destaques do documento:',
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildHighlight('Design responsivo e moderno', themeProvider),
                    _buildHighlight('Otimizado para todos os dispositivos', themeProvider),
                    _buildHighlight('Código limpo e profissional', themeProvider),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        if (widget.onDocumentGenerated != null) {
                          widget.onDocumentGenerated!(_extractHtmlFromResponse(text));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Ionicons.eye_outline, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Veja o Preview!',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlight(String text, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF1E88E5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text, ThemeProvider themeProvider) {
    final color = themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529);
    final accentBlue = const Color(0xFF1E88E5);

    if (text.contains('```')) {
      final parts = text.split('```');
      List<Widget> widgets = [];
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (i % 2 == 0) {
          widgets.addAll(_buildWidgetsFromLines(part, color, accentBlue, themeProvider));
        } else {
          widgets.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Icon(Ionicons.code_slash, size: 16, color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                    const SizedBox(width: 8),
                    SelectableText(
                      part.trim(),
                      style: TextStyle(
                        fontFamily: kIsWeb ? 'monospace' : 'Courier',
                        fontSize: 13,
                        color: themeProvider.isDarkMode ? Colors.grey.shade200 : Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    }

    final children = _buildWidgetsFromLines(text, color, accentBlue, themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<Widget> _buildWidgetsFromLines(String text, Color color, Color accentBlue, ThemeProvider themeProvider) {
    List<Widget> widgets = [];
    final lines = text.replaceAll('\r', '').split('\n');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trimRight();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      final lower = line.toLowerCase();

      // Tabelas HTML
      if (line.trim().startsWith('<table') || (i > 0 && lines[i - 1].contains('<table'))) {
        String tableHtml = '';
        int j = i;
        while (j < lines.length && !lines[j].contains('</table>')) {
          tableHtml += lines[j] + '\n';
          j++;
        }
        if (j < lines.length) {
          tableHtml += lines[j];
        }
        
        // Aqui você pode usar um WebView ou HtmlWidget para renderizar a tabela
        // Por simplicidade, vou criar um placeholder
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Ionicons.grid_outline, size: 20, color: accentBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Tabela',
                      style: TextStyle(
                        color: accentBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tabela HTML renderizada',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
        i = j;
        continue;
      }

      // Info boxes
      if (lower.contains('importante') || lower.contains('atenção') || lower.contains('nota:') || line.startsWith('Info:') || line.contains('[info]')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.blue.withOpacity(0.08) : accentBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeProvider.isDarkMode ? Colors.blue.withOpacity(0.2) : accentBlue.withOpacity(0.15), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Ionicons.information_circle, size: 22, color: accentBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    line,
                    style: TextStyle(
                      color: accentBlue,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // H1
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: accentBlue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                line.substring(2).trim(),
                style: TextStyle(
                  color: accentBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        );
        continue;
      }
      // H2
      else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Text(
              line.substring(3).trim(),
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.35,
                letterSpacing: -0.3,
              ),
            ),
          ),
        );
        continue;
      }
      // H3
      else if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Text(
              line.substring(4).trim(),
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        );
        continue;
      }

      // Bullet points
      if (line.startsWith('- ') || line.startsWith('• ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 10),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: _parseInlineFormatting(line.substring(2), color)),
                    textAlign: TextAlign.left,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Numbered lists
      if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  margin: const EdgeInsets.only(right: 8),
                  child: Text(
                    line.split(' ')[0],
                    style: TextStyle(
                      color: accentBlue,
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: _parseInlineFormatting(line.substring(line.indexOf(' ') + 1), color)),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Regular text with bold
      if (line.contains('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text.rich(
              TextSpan(children: _parseInlineFormatting(line, color)),
            ),
          ),
        );
        continue;
      }

      // Plain text
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            line,
            style: TextStyle(
              color: color,
              fontSize: 15,
              height: 1.65,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  List<InlineSpan> _parseInlineFormatting(String text, Color color) {
    List<InlineSpan> spans = [];
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in boldRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: color, fontSize: 15, height: 1.65),
        ));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          height: 1.65,
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: color, fontSize: 15, height: 1.65),
      ));
    }

    return spans;
  }

  Widget _buildInputArea(ThemeProvider themeProvider) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ChatInput(
        messageController: _messageController,
        focusNode: _focusNode,
        isDarkMode: themeProvider.isDarkMode,
        isLoading: _isLoading,
        onSend: (text) async {
          await _sendMessage(text);
        },
        viewType: _viewType,
        sendIconSvg: _sendIconSvg,
        stopIconSvg: _stopIconSvg,
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    if (!mounted) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (mounted) {
      setState(() {
        chatProvider.addMessage(ChatMessage(text: text.trim(), isUser: true));
        _isLoading = true;
      });
    }

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': '''Você é o DocuGen AI, um assistente extremamente profissional e sofisticado.

REGRAS CRÍTICAS DE FORMATAÇÃO:

1. NUNCA mencione ou mostre asteriscos (**) ou símbolos de markdown na resposta final
2. NUNCA explique como você formata o texto
3. NUNCA diga "vou usar negrito" ou "formatado com **"
4. Responda NATURALMENTE como se estivesse escrevendo diretamente

FORMATAÇÃO PARA SUAS RESPOSTAS:

Use # para títulos principais (H1) - destaque máximo com linha inferior azul
Use ## para subtítulos (H2) - importantes e destacados
Use ### para seções menores (H3)
Use **texto** para negrito (mas NUNCA mostre os asteriscos na resposta)
Use - ou • para listas com bullets
Use números 1. 2. 3. para listas ordenadas
Use Importante:, Atenção:, Nota: para caixas de informação destacadas
Use ``` para blocos de código

PARA TABELAS:
SEMPRE use HTML puro com a tag <table>, NUNCA use caracteres ASCII
Exemplo de tabela HTML:
<table style="width:100%; border-collapse: collapse; margin: 16px 0;">
  <thead>
    <tr style="background-color: #f0f0f0;">
      <th style="padding: 12px; border: 1px solid #ddd; text-align: left;">Coluna 1</th>
      <th style="padding: 12px; border: 1px solid #ddd; text-align: left;">Coluna 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 12px; border: 1px solid #ddd;">Dado 1</td>
      <td style="padding: 12px; border: 1px solid #ddd;">Dado 2</td>
    </tr>
  </tbody>
</table>

EXEMPLO DE BOA RESPOSTA:

# Inteligência Artificial

A inteligência artificial está revolucionando o mundo moderno de formas impressionantes.

## Principais Benefícios

A IA oferece vantagens significativas em diversas áreas:

- Automação de processos complexos e repetitivos
- Análise de grandes volumes de dados em tempo real
- Tomada de decisões mais precisas e baseadas em dados

### Aplicações Práticas

1. Saúde: diagnósticos mais precisos e tratamentos personalizados
2. Finanças: detecção de fraudes e análise de risco
3. Educação: personalização do aprendizado para cada aluno

Importante: A implementação de IA deve sempre considerar questões éticas e de privacidade.

CRIAÇÃO DE DOCUMENTOS HTML:

APENAS crie documentos HTML quando o usuário pedir EXPLICITAMENTE:
- "crie um documento"
- "gere um HTML"
- "faça um site"
- "monte uma página"
- "desenvolva um website"

Para perguntas normais, explicações, conversas: use APENAS a formatação markdown acima

Quando criar HTML:
1. Crie um documento HTML5 completo e profissional
2. Use CSS moderno e responsivo
3. Inclua meta tags apropriadas
4. Design limpo e elegante
5. Totalmente funcional

Seja claro, direto, profissional e extremamente bem organizado em todas as respostas.''',
            },
            ...chatProvider.buildMessageHistory(),
          ],
          'temperature': 0.7,
          'max_tokens': 4096,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;

        if (mounted) {
          setState(() {
            chatProvider.addMessage(ChatMessage(text: aiResponse, isUser: false));
            _isLoading = false;
          });

          if (aiResponse.contains('<!DOCTYPE html>') || aiResponse.contains('<html')) {
            final htmlContent = _extractHtmlFromResponse(aiResponse);
            if (htmlContent.isNotEmpty && widget.onDocumentGenerated != null) {
              widget.onDocumentGenerated!(htmlContent);
            }
          }
        }
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao enviar mensagem: $e');
      if (mounted) {
        setState(() {
          chatProvider.addMessage(ChatMessage(
            text: 'Desculpe, ocorreu um erro. Tente novamente.',
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  String _extractHtmlFromResponse(String response) {
    int htmlStart = response.indexOf('<!DOCTYPE html>');
    if (htmlStart == -1) {
      htmlStart = response.indexOf('<html');
    }

    if (htmlStart != -1) {
      final htmlEnd = response.indexOf('</html>', htmlStart);
      if (htmlEnd != -1) {
        return response.substring(htmlStart, htmlEnd + 7);
      }
    }

    final codeBlockStart = response.indexOf('```html');
    if (codeBlockStart != -1) {
      final contentStart = response.indexOf('\n', codeBlockStart) + 1;
      final codeBlockEnd = response.indexOf('```', contentStart);
      if (codeBlockEnd != -1) {
        return response.substring(contentStart, codeBlockEnd).trim();
      }
    }

    return '';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _ConversationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF050810) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Ionicons.chatbubbles_outline,
                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Conversas',
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Ionicons.close_outline,
                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            ),
            Expanded(
              child: chatProvider.conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Ionicons.file_tray_outline,
                            size: 48,
                            color: themeProvider.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma conversa',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: chatProvider.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = chatProvider.conversations[index];
                        final isSelected = chatProvider.currentConversation?.id == conversation.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (themeProvider.isDarkMode ? const Color(0xFF0D1117) : const Color(0xFFF8F9FA))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () {
                              chatProvider.switchConversation(conversation.id);
                              Navigator.pop(context);
                            },
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode ? const Color(0xFF161B22) : const Color(0xFFE9ECEF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Ionicons.chatbubble_outline,
                                size: 18,
                                color: themeProvider.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                              ),
                            ),
                            title: Text(
                              conversation.title,
                              style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _formatDate(conversation.lastUpdated),
                              style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: Icon(
                                Ionicons.ellipsis_horizontal,
                                color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                size: 20,
                              ),
                              color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Ionicons.trash_outline,
                                        size: 18,
                                        color: Colors.red.shade400,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Excluir',
                                        style: TextStyle(
                                          color: Colors.red.shade400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeleteDialog(context, themeProvider, chatProvider, conversation.id);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? "semana" : "semanas"} atrás';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? "mês" : "meses"} atrás';
    }
  }

  void _showDeleteDialog(BuildContext context, ThemeProvider themeProvider, ChatProvider chatProvider, String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0D1117) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir conversa',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta conversa? Esta ação não pode ser desfeita.',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              chatProvider.deleteConversation(conversationId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Excluir',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}