// lib/tabs/chat_tab.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../widgets/chat_input.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:ionicons/ionicons.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class ChatTab extends StatefulWidget {
  final Function(String htmlContent)? onDocumentGenerated;

  const ChatTab({Key? key, this.onDocumentGenerated}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(
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
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isLoading && index == _messages.length) {
                            return _buildLoadingIndicator(themeProvider);
                          }
                          return _buildMessageBubble(_messages[index], themeProvider);
                        },
                      ),
              ),
            ],
          ),
          _buildInputArea(themeProvider),
        ],
      ),
    );
  }

  // substitui o efeito anterior por três pontos animados
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
        // animação com fase para cada ponto; sai ~ -8..8 em Y
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

  Widget _buildMessageBubble(ChatMessage message, ThemeProvider themeProvider) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFF343A40) : const Color(0xFF212529),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
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
          child: _buildAiResponseContent(message.text, themeProvider),
        ),
      );
    }
  }

  Widget _buildAiResponseContent(String text, ThemeProvider themeProvider) {
    // se tiver HTML, mostra uma pré-visualização com ícone de código
    if (text.contains('<!DOCTYPE html>') || text.contains('<html')) {
      int htmlStart = text.indexOf('<!DOCTYPE html>');
      if (htmlStart == -1) htmlStart = text.indexOf('<html');

      String textBeforeHtml = htmlStart > 0 ? text.substring(0, htmlStart).trim() : '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (textBeforeHtml.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildFormattedText(textBeforeHtml, themeProvider),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1F2933) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Ionicons.code_slash,
                  size: 16,
                  color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Documento HTML gerado',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // caso contrário, usa formatação avançada
    return _buildFormattedText(text, themeProvider);
  }

  Widget _buildFormattedText(String text, ThemeProvider themeProvider) {
    final color = themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529);
    final accentBlue = const Color(0xFF1E88E5);

    // suporte a blocos de código delimitados por ```
    if (text.contains('```')) {
      final parts = text.split('```');
      List<Widget> widgets = [];
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (i % 2 == 0) {
          // texto normal
          widgets.addAll(_buildWidgetsFromLines(part, color, accentBlue, themeProvider));
        } else {
          // bloco de código
          widgets.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.black.withOpacity(0.6) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.06)),
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

    // se não tiver blocos de código, gera widgets a partir das linhas
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
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      final lower = line.toLowerCase();

      // Linha com marcador de "informação crítica" - pinta em azul e adiciona ícone
      if (lower.contains('importante') || lower.contains('atenção') || line.startsWith('Info:') || line.contains('[info]')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.blue.withOpacity(0.06) : accentBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: themeProvider.isDarkMode ? Colors.blue.withOpacity(0.14) : accentBlue.withOpacity(0.12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Ionicons.information_circle_outline, size: 18, color: accentBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line,
                    style: TextStyle(
                      color: accentBlue,
                      fontSize: 15,
                      height: 1.45,
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

      // Títulos
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    line.substring(2).trim(),
                    style: TextStyle(
                      color: accentBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Text(
              line.substring(3).trim(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        );
        continue;
      } else if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Text(
              line.substring(4).trim(),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        );
        continue;
      }

      // Lista com bullet
      if (line.startsWith('- ') || line.startsWith('• ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: color, fontSize: 15, height: 1.6)),
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

      // Lista numerada
      if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    line.split(' ')[0],
                    style: TextStyle(color: color, fontSize: 15, height: 1.6),
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

      // Se contém negrito inline ou outros marcadores, utiliza parse
      if (line.contains('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text.rich(
              TextSpan(children: _parseInlineFormatting(line, color)),
            ),
          ),
        );
        continue;
      }

      // Texto simples
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            line,
            style: TextStyle(
              color: color,
              fontSize: 15,
              height: 1.6,
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
          style: TextStyle(color: color, fontSize: 15, height: 1.6),
        ));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          height: 1.6,
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: color, fontSize: 15, height: 1.6),
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

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: text.trim(), isUser: true));
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
          'model': 'groq/compound',
          'messages': [
            {
              'role': 'system',
              'content': '''Você é o DocuGen AI, um assistente especializado em criar documentos HTML profissionais e estilizados.

REGRAS IMPORTANTES:
1. Quando o usuário pedir para criar um documento, SEMPRE gere HTML completo com estrutura <!DOCTYPE html>
2. Use CSS inline moderno e elegante
3. Garanta que o documento seja responsivo e profissional
4. Use fontes web-safe ou Google Fonts
5. Para respostas de chat normais, use formatação markdown simples:
   - Use # para títulos principais
   - Use ## para subtítulos
   - Use **texto** para negrito
   - Use - ou • para listas
   - Use números (1., 2., etc) para listas ordenadas
6. Seja claro, direto e bem formatado nas respostas

EXEMPLO DE ESTRUTURA HTML:
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Documento</title>
  <style>
    body { font-family: 'Arial', sans-serif; line-height: 1.6; color: #333; padding: 40px; max-width: 800px; margin: 0 auto; }
    h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
    p { margin: 15px 0; }
  </style>
</head>
<body>
  <h1>Título do Documento</h1>
  <p>Conteúdo aqui...</p>
</body>
</html>''',
            },
            ..._buildMessageHistory(),
          ],
          'temperature': 0.3,
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;

        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(text: aiResponse, isUser: false));
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
          _messages.add(ChatMessage(
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

  List<Map<String, String>> _buildMessageHistory() {
    return _messages
        .map((msg) => {
              'role': msg.isUser ? 'user' : 'assistant',
              'content': msg.text,
            })
        .toList();
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