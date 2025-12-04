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
// Only import these on web platform
import 'dart:html' as html show IFrameElement;
import 'dart:ui' as ui show platformViewRegistry;

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
        color: themeProvider.isDarkMode ? Colors.black : Colors.white,
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
                      color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
                      color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
        return _buildMessageBubble(chatProvider.currentMessages[index], themeProvider);
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
            color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : const Color(0xFF212529),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Times New Roman',
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: _buildMessageContent(message.text, themeProvider),
        ),
      );
    }
  }

  Widget _buildMessageContent(String text, ThemeProvider themeProvider) {
    if (text.contains('<table>') && text.contains('</table>')) {
      List<Widget> widgets = [];
      int lastIndex = 0;

      final tableRegex = RegExp(r'<table>.*?</table>', dotAll: true);
      final matches = tableRegex.allMatches(text);

      for (final match in matches) {
        if (match.start > lastIndex) {
          widgets.add(
            SelectableText(
              text.substring(lastIndex, match.start),
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 15,
                height: 1.5,
                fontFamily: 'Times New Roman',
              ),
            ),
          );
        }

        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: _buildHtmlTable(match.group(0)!, themeProvider),
          ),
        );

        lastIndex = match.end;
      }

      if (lastIndex < text.length) {
        widgets.add(
          SelectableText(
            text.substring(lastIndex),
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontSize: 15,
              height: 1.5,
              fontFamily: 'Times New Roman',
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    }

    if (text.contains('<img ') && text.contains('/>')) {
      List<Widget> widgets = [];
      int lastIndex = 0;

      final imgRegex = RegExp(r'<img [^>]+/>', dotAll: true);
      final matches = imgRegex.allMatches(text);

      for (final match in matches) {
        if (match.start > lastIndex) {
          widgets.add(
            SelectableText(
              text.substring(lastIndex, match.start),
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 15,
                height: 1.5,
                fontFamily: 'Times New Roman',
              ),
            ),
          );
        }

        final imgTag = match.group(0)!;
        final srcMatch = RegExp(r'src="([^"]+)"').firstMatch(imgTag);
        final widthMatch = RegExp(r'width="([^"]+)"').firstMatch(imgTag);
        final altMatch = RegExp(r'alt="([^"]+)"').firstMatch(imgTag);

        if (srcMatch != null) {
          widgets.add(
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  srcMatch.group(1)!,
                  width: widthMatch != null ? double.tryParse(widthMatch.group(1)!) : 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Ionicons.image_outline, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            altMatch?.group(1) ?? 'Imagem',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }

        lastIndex = match.end;
      }

      if (lastIndex < text.length) {
        widgets.add(
          SelectableText(
            text.substring(lastIndex),
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontSize: 15,
              height: 1.5,
              fontFamily: 'Times New Roman',
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    }

    return SelectableText(
      text,
      style: TextStyle(
        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        fontSize: 15,
        height: 1.5,
        fontFamily: 'Times New Roman',
      ),
    );
  }

  Widget _buildHtmlTable(String htmlTable, ThemeProvider themeProvider) {
    if (!kIsWeb) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'HTML tables are only supported on web platform',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 14,
          ),
        ),
      );
    }

    final viewId = 'table-${DateTime.now().millisecondsSinceEpoch}';

    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = 'auto';

        final doc = '''
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body {
              margin: 0;
              padding: 12px;
              font-family: 'Times New Roman', serif;
              background: ${themeProvider.isDarkMode ? '#1C2128' : '#FFFFFF'};
              color: ${themeProvider.isDarkMode ? '#FFFFFF' : '#000000'};
            }
            table {
              width: 100%;
              border-collapse: collapse;
              background: ${themeProvider.isDarkMode ? '#0D1117' : '#F8F9FA'};
              border-radius: 8px;
              overflow: hidden;
            }
            th, td {
              padding: 12px;
              text-align: left;
              border: 1px solid ${themeProvider.isDarkMode ? '#2D333B' : '#DEE2E6'};
              font-size: 14px;
            }
            th {
              background: ${themeProvider.isDarkMode ? '#1C2128' : '#E9ECEF'};
              font-weight: bold;
            }
            tr:hover {
              background: ${themeProvider.isDarkMode ? '#161B22' : '#F1F3F5'};
            }
            img {
              width: 20px;
              height: 14px;
              margin-right: 6px;
              vertical-align: middle;
            }
          </style>
        </head>
        <body>
          $htmlTable
        </body>
        </html>
        ''';

        iframe.srcdoc = doc;
        return iframe;
      },
    );

    return SizedBox(
      height: 300,
      child: HtmlElementView(viewType: viewId),
    );
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
              'content': '''Você é o DocuGen AI, um assistente criativo e profissional com capacidade de buscar imagens na internet.

REGRAS OBRIGATÓRIAS:

1. 😊 Use emojis para expressar emoções e tornar respostas amigáveis
2. 📊 Para TABELAS: use SEMPRE HTML com <table></table>
3. 🖼️ Para IMAGENS: SEMPRE que mencionar pessoas, lugares, objetos, eventos - MOSTRE IMAGENS!

FORMATO DE IMAGENS (OBRIGATÓRIO):
Quando falar sobre qualquer tema visual, SEMPRE inclua imagem assim:
<img src="URL_DA_IMAGEM" width="250" alt="descrição"/>

COMO ENCONTRAR IMAGENS:
- Pessoas famosas: Busque URLs reais de fotos da pessoa (Wikipedia, sites oficiais)
- Lugares: URLs de fotos do local
- Objetos/Produtos: URLs de imagens do produto
- Eventos: Fotos do evento
- Bandeiras: https://flagcdn.com/w320/CODIGO.png (ex: pt para Portugal)

EXEMPLOS PRÁTICOS:

Usuário pergunta: "Quem é Elon Musk?"
Resposta deve incluir:
<img src="URL_REAL_FOTO_ELON_MUSK" width="250" alt="Elon Musk"/>
Elon Musk é CEO da Tesla e SpaceX... [continua]

Usuário pergunta: "Jogo Portugal vs Espanha"
Resposta com TABELA:
<table>
<tr><th>🏆 Equipa</th><th>⚽ Golos</th><th>📊 Posse</th></tr>
<tr><td><img src="https://flagcdn.com/w40/pt.png" alt="PT"/> Portugal</td><td>2</td><td>58%</td></tr>
<tr><td><img src="https://flagcdn.com/w40/es.png" alt="ES"/> Espanha</td><td>1</td><td>42%</td></tr>
</table>

Usuário pergunta: "Torre Eiffel"
Resposta deve incluir:
<img src="URL_REAL_FOTO_TORRE_EIFFEL" width="250" alt="Torre Eiffel"/>
A Torre Eiffel é... [continua]

IMPORTANTE:
- Use URLs REAIS de imagens que você conhece da internet
- SEMPRE mostre imagens quando relevante ao tema
- Imagens deixam respostas mais ricas e visuais
- Não use placeholders, use URLs reais

DOCUMENTOS HTML:
- Só crie documentos HTML completos quando pedido explicitamente
- Imagens e tabelas na conversa NÃO vão para documentos

Seja visual, criativo e sempre mostre imagens quando possível! 📸✨''',
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
            text: 'Desculpe, ocorreu um erro. Tente novamente. 😔',
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
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
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
                                ? (themeProvider.isDarkMode ? const Color(0xFF1C2128) : const Color(0xFFF8F9FA))
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
                                color: themeProvider.isDarkMode ? const Color(0xFF2D333B) : const Color(0xFFE9ECEF),
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
                              color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
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
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
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