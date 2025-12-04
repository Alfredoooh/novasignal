// lib/tabs/chat_tab.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
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

    final bgColor = themeProvider.isDarkMode ? const Color(0xFF0A0E14) : Colors.white;
    final foregroundOnly = themeProvider.isDarkMode ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: bgColor,
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
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Ionicons.menu_outline,
                      color: foregroundOnly,
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
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Ionicons.add_outline,
                      color: foregroundOnly,
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
    final foregroundOnly = themeProvider.isDarkMode ? Colors.white : Colors.black;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.chatbubble_ellipses_outline,
            size: 64,
            color: foregroundOnly,
          ),
          const SizedBox(height: 16),
          Text(
            'Comece uma conversa',
            style: TextStyle(
              color: foregroundOnly,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envie uma mensagem para iniciar',
            style: TextStyle(
              color: foregroundOnly,
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
        return _buildMessageBubble(chatProvider.currentMessages[index], themeProvider);
      },
    );
  }

  Widget _buildLoadingIndicator(ThemeProvider themeProvider) {
    final dotColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
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

  Widget _buildMessageBubble(ChatMessage message, ThemeProvider themeProvider) {
    final fg = themeProvider.isDarkMode ? Colors.white : Colors.black;

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {
            // Permite editar a mensagem do utilizador ao tocar nela
            _messageController.text = message.text;
            _focusNode.requestFocus();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(8), // menos curvo na lateral direita inferior
              ),
              border: Border.all(color: fg.withOpacity(0.08)),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
    } else {
      // IA: NÃO usar Container de fundo — renderizar texto simples
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            child: _buildAiResponseContent(message.text, themeProvider),
          ),
        ),
      );
    }
  }

  Widget _buildAiResponseContent(String text, ThemeProvider themeProvider) {
    final fg = themeProvider.isDarkMode ? Colors.white : Colors.black;

    // Detecta HTML completo
    if (text.contains('<!DOCTYPE html>') || text.contains('<html')) {
      // Extrai HTML para enviar para callback se for necessário
      final htmlContent = _extractHtmlFromResponse(text);
      if (htmlContent.isNotEmpty && widget.onDocumentGenerated != null) {
        widget.onDocumentGenerated!(htmlContent);
      }

      // Mostra apenas um H1 com emoji de papel e algumas opções (sem container)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // H1 com emoji de papel
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 8),
            child: Text(
              '📄 Documento criado',
              style: TextStyle(
                color: fg,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),

          // Pequena descrição (texto simples)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'O documento foi gerado. Veja as opções abaixo para pré-visualizar, destacar ou partilhar.',
              style: TextStyle(color: fg, fontSize: 14),
            ),
          ),

          // Botões de ação (sem container)
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  // ação preview - o callback onDocumentGenerated já foi chamado
                  // Se quiseres abrir um preview inline, implementa aqui
                },
                icon: Icon(Ionicons.eye_outline, size: 16, color: fg),
                label: Text('Veja o preview!', style: TextStyle(color: fg)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
              ),
              TextButton.icon(
                onPressed: () {
                  // Destaques - placeholder
                },
                icon: Icon(Ionicons.flash_outline, size: 16, color: fg),
                label: Text('Destaques', style: TextStyle(color: fg)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
              ),
              TextButton.icon(
                onPressed: () {
                  // Partilhar - placeholder
                },
                icon: Icon(Ionicons.share_social_outline, size: 16, color: fg),
                label: Text('Partilhar', style: TextStyle(color: fg)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
              ),
            ],
          ),
        ],
      );
    }

    // Se contém tag <table>, mostrar bloco de HTML (tabela) como texto selecionável (monospace)
    if (text.contains('<table')) {
      // apresentar a parte que inclui <table> até </table> se possível
      final start = text.indexOf('<table');
      final end = text.indexOf('</table>', start);
      final tableHtml = (start != -1 && end != -1) ? text.substring(start, end + 8) : text;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texto explicativo (sem containers)
          Text(
            'Tabela (HTML):',
            style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SelectableText(
            tableHtml,
            style: TextStyle(
              fontFamily: kIsWeb ? 'monospace' : 'Courier',
              fontSize: 13,
              color: fg,
            ),
          ),
          const SizedBox(height: 8),
          // Botões de ação básicos (copiar, partilhar, regenerar, feedback)
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  // copiar tabela
                },
                icon: Icon(Ionicons.copy_outline, size: 16, color: fg),
                label: Text('Copiar', style: TextStyle(color: fg)),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Ionicons.share_social_outline, size: 16, color: fg),
                label: Text('Partilhar', style: TextStyle(color: fg)),
              ),
              TextButton.icon(
                onPressed: () {
                  // regenerar - stub
                },
                icon: Icon(Ionicons.reload_outline, size: 16, color: fg),
                label: Text('Regenerar', style: TextStyle(color: fg)),
              ),
              TextButton.icon(
                onPressed: () {
                  // feedback - stub
                },
                icon: Icon(Ionicons.chatbubble_ellipses_outline, size: 16, color: fg),
                label: Text('Feedback', style: TextStyle(color: fg)),
              ),
            ],
          ),
        ],
      );
    }

    return _buildFormattedText(text, themeProvider);
  }

  Widget _buildFormattedText(String text, ThemeProvider themeProvider) {
    final color = themeProvider.isDarkMode ? Colors.white : Colors.black;

    // Mantemos o suporte a blocos de código (```), listas, headers, etc.
    if (text.contains('```')) {
      final parts = text.split('```');
      List<Widget> widgets = [];
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (i % 2 == 0) {
          widgets.addAll(_buildWidgetsFromLines(part, color, themeProvider));
        } else {
          widgets.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.08)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Icon(Ionicons.code_slash, size: 16, color: color),
                    const SizedBox(width: 8),
                    SelectableText(
                      part.trim(),
                      style: TextStyle(
                        fontFamily: kIsWeb ? 'monospace' : 'Courier',
                        fontSize: 13,
                        color: color,
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

    final children = _buildWidgetsFromLines(text, color, themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<Widget> _buildWidgetsFromLines(String text, Color color, ThemeProvider themeProvider) {
    List<Widget> widgets = [];
    final lines = text.replaceAll('\r', '').split('\n');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trimRight();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      final lower = line.toLowerCase();

      // Info boxes replaced by simple bolded intro line (sem cores)
      if (lower.contains('importante') || lower.contains('atenção') || lower.contains('nota:') || line.startsWith('Info:') || line.contains('[info]')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Ionicons.information_circle_outline, size: 20, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    line,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Headers - H1 (# )
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              line.substring(2).trim(),
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
          ),
        );
        continue;
      } 
      // Headers - H2 (## )
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
      // Headers - H3 (### )
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
                    color: color,
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
                      color: color,
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w700,
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

      // Regular text with bold or inline formatting
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
            // limpa asteriscos soltos que porventura o modelo tenha deixado
            line.replaceAll('*', ''),
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
    // Este parser:
    // - Extrai conteúdo entre **...** como bold.
    // - Remove asteriscos soltos fora de blocos de código.
    // - Não deixa ** ou * visíveis na UI.
    List<InlineSpan> spans = [];

    // Primeiro localiza blocos de bold com regex não-gulosa
    final boldRegex = RegExp(r'\*\*(.+?)\*\*', dotAll: true);
    int lastIndex = 0;

    for (final match in boldRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        String normalText = text.substring(lastIndex, match.start);
        // remover asteriscos soltos
        normalText = normalText.replaceAll('*', '');
        if (normalText.isNotEmpty) {
          spans.add(TextSpan(
            text: normalText,
            style: TextStyle(color: color, fontSize: 15, height: 1.65),
          ));
        }
      }

      // Conteúdo em negrito (sem asteriscos)
      final boldContent = match.group(1)?.replaceAll('*', '') ?? '';
      spans.add(TextSpan(
        text: boldContent,
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
      String remaining = text.substring(lastIndex);
      remaining = remaining.replaceAll('*', '');
      if (remaining.isNotEmpty) {
        spans.add(TextSpan(
          text: remaining,
          style: TextStyle(color: color, fontSize: 15, height: 1.65),
        ));
      }
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
          'model': 'groq/compound',
          'messages': [
            {
              'role': 'system',
              'content': '''Você é o DocuGen AI, um assistente especializado em criar documentos HTML profissionais e fornecer respostas extremamente bem estruturadas e organizadas.

INSTRUÇÕES FORÇADAS (seguir estritamente):

1) CORES: em todas as respostas use apenas COR PRETA (modo claro) ou COR BRANCA (modo escuro). Não use outras cores, gradientes ou destaques coloridos.

2) TÍTULOS/SEÇÕES:
   - Use # para título principal (H1)
   - Use ## para subtítulo (H2)
   - Use ### para seções menores (H3)
   - Não inclua outros marcadores visuais além de texto (nenhum background colorido)

3) NEGRITO: use **conteúdo em negrito**. **Nunca** produza asteriscos visíveis. Se for necessário emular negrito, envolva com ** sem repetir asteriscos extras. Se já existe negrito, não duplique.

4) LISTAS: use '-' ou '•' para bullets e '1.' para numeradas. Para tabelas solicitadas PELO UTILIZADOR NA CONVERSA, gere explicitamente uma `<table>...</table>` em HTML — NÃO use caracteres ASCII para desenhar a tabela.

5) HTML: NUNCA crie um documento HTML completo a menos que o usuário peça explicitamente. 
   - Se o usuário pedir "gere um HTML" ou similar, gerarás o HTML completo.
   - Se o modelo gerar HTML e for um documento, a aplicação mostrará apenas: "📄 Documento criado" (H1) e opções de preview / destaques / partilhar.

6) SAÍDA: sempre comece com uma breve introdução, se pertinente, e termine com próximos passos quando necessário.

7) CÓDIGO: use ```código``` para blocos de código e `texto` para inline code.

8) TABELAS NA CONVERSA: quando o usuário pedir uma tabela **na própria conversa**, entregue-a em HTML com <table>, <thead>, <tbody>, <tr>, <td>. Isso garante que a UI possa capturar a tabela como HTML.

9) PRIVACIDADE: não inclua chaves API, senhas ou dados sensíveis em qualquer resposta.

Seja preciso, claro e siga estas regras ao pé da letra.''',
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
    if (htmlStart == -1) htmlStart = response.indexOf('<html');

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

    final fg = themeProvider.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0A0E14) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Ionicons.chatbubbles_outline,
                    color: fg,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Conversas',
                      style: TextStyle(
                        color: fg,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Ionicons.close_outline,
                      color: fg,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: fg.withOpacity(0.08),
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
                            color: fg,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma conversa',
                            style: TextStyle(
                              color: fg,
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
                            color: isSelected ? (themeProvider.isDarkMode ? Colors.black : Colors.white) : Colors.transparent,
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
                                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Ionicons.chatbubble_outline,
                                size: 18,
                                color: fg,
                              ),
                            ),
                            title: Text(
                              conversation.title,
                              style: TextStyle(
                                color: fg,
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _formatDate(conversation.lastUpdated),
                              style: TextStyle(
                                color: fg.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: Icon(
                                Ionicons.ellipsis_horizontal,
                                color: fg,
                                size: 20,
                              ),
                              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
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
    final fg = themeProvider.isDarkMode ? Colors.white : Colors.black;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir conversa',
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta conversa? Esta ação não pode ser desfeita.',
          style: TextStyle(
            color: fg,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: fg,
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