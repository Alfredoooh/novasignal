// lib/tabs/chat_tab.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/chat_input.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

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
      duration: const Duration(milliseconds: 1500),
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

  Widget _buildLoadingIndicator(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedBuilder(
          animation: _loadingController,
          builder: (context, child) {
            return Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    (themeProvider.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                    (themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500),
                    (themeProvider.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                  ],
                  stops: [
                    0.0,
                    _loadingController.value,
                    1.0,
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
              color: themeProvider.isDarkMode ? const Color(0xFF343A40).withOpacity(0.5) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
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
                    color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
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

    return _buildFormattedText(text, themeProvider);
  }

  Widget _buildFormattedText(String text, ThemeProvider themeProvider) {
    final color = themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529);
    
    // Detectar marcadores comuns de formatação
    List<InlineSpan> spans = [];
    final lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      
      // Títulos (linhas que começam com #)
      if (line.startsWith('# ')) {
        spans.add(TextSpan(
          text: line.substring(2) + '\n',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ));
      }
      // Subtítulos
      else if (line.startsWith('## ')) {
        spans.add(TextSpan(
          text: line.substring(3) + '\n',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ));
      }
      // Lista com bullet points
      else if (line.trim().startsWith('- ') || line.trim().startsWith('• ')) {
        spans.add(TextSpan(
          text: '  • ' + line.trim().substring(2) + '\n',
          style: TextStyle(
            color: color,
            fontSize: 15,
            height: 1.6,
          ),
        ));
      }
      // Lista numerada
      else if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        spans.add(TextSpan(
          text: '  ' + line.trim() + '\n',
          style: TextStyle(
            color: color,
            fontSize: 15,
            height: 1.6,
          ),
        ));
      }
      // Negrito simples
      else if (line.contains('**')) {
        spans.addAll(_parseInlineFormatting(line + (i < lines.length - 1 ? '\n' : ''), color));
      }
      // Texto normal
      else {
        spans.add(TextSpan(
          text: line + (i < lines.length - 1 ? '\n' : ''),
          style: TextStyle(
            color: color,
            fontSize: 15,
            height: 1.6,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  List<InlineSpan> _parseInlineFormatting(String text, Color color) {
    List<InlineSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Texto antes do negrito
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: color, fontSize: 15, height: 1.6),
        ));
      }

      // Texto em negrito
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

    // Texto restante
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