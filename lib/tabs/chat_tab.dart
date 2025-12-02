// lib/tabs/chat_tab.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
  static bool _viewRegistered = false;
  html.InputElement? _htmlInput;
  bool _isLoading = false;
  String? _conversationTitle;
  DateTime? _conversationStartTime;
  String _currentThinkingStep = '';
  bool _isInputActive = false;

  late AnimationController _shimmerController;

  static const String _groqApiKey = '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';
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static const List<String> _thinkingSteps = [
    'Analisando o pedido',
    'Processando os requisitos',
    'Buscando melhores resultados',
    'Dando últimos toques',
    'Concluindo',
  ];

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
  void dispose() {
    _shimmerController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}d initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    if (kIsWeb && !_viewRegistered) {
      _registerWebView();
      _viewRegistered = true;
    }
  }

  void _registerWebView() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          final inputBgColor = themeProvider.isDarkMode ? '#343A40' : '#F8F9FA';
          final inputTextColor = themeProvider.isDarkMode ? '#FFFFFF' : '#212529';
          final inputPlaceholderColor = themeProvider.isDarkMode ? '#ADB5BD' : '#6C757D';

          final element = html.DivElement()
            ..id = 'chat-input-wrapper-$viewId'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.display = 'flex'
            ..style.alignItems = 'center';

          _htmlInput = html.InputElement()
            ..id = 'chatInput-$viewId'
            ..type = 'text'
            ..placeholder = 'Ask DocuGen'
            ..autocomplete = 'off'
            ..setAttribute('spellcheck', 'false')
            ..style.flex = '1'
            ..style.padding = '12px 20px'
            ..style.border = 'none'
            ..style.borderRadius = '24px'
            ..style.fontSize = '16px'
            ..style.outline = 'none'
            ..style.backgroundColor = inputBgColor
            ..style.color = inputTextColor
            ..style.fontFamily = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
            ..style.transition = 'background-color 0.3s'
            ..style.setProperty('-webkit-user-select', 'text')
            ..style.userSelect = 'text'
            ..style.setProperty('-webkit-tap-highlight-color', 'transparent');

          final style = html.StyleElement()
            ..text = '''
              #chatInput-$viewId::placeholder {
                color: $inputPlaceholderColor;
              }
              #chatInput-$viewId:focus {
                box-shadow: none !important;
                outline: none !important;
              }
            ''';

          element.append(style);
          element.append(_htmlInput!);

          _htmlInput!.onKeyPress.listen((e) {
            if (e.key == 'Enter') {
              e.preventDefault();
              _sendMessageFromHtml();
            }
          });

          _htmlInput!.onFocus.listen((_) {
            setState(() {
              _isInputActive = true;
            });
          });

          return element;
        },
      );
    } catch (e) {
      debugPrint('Error registering view: $e');
    }
  }

  void _sendMessageFromHtml() {
    if (_htmlInput != null) {
      final text = _htmlInput!.value?.trim() ?? '';
      if (text.isNotEmpty && !_isLoading) {
        _sendMessage(text);
        _htmlInput!.value = '';
        _htmlInput!.blur();
        setState(() {
          _isInputActive = false;
        });
      }
    }
  }

  void _unfocusKeyboard() {
    _focusNode.unfocus();
    if (kIsWeb && _htmlInput != null) {
      _htmlInput!.blur();
    }
    setState(() {
      _isInputActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(themeProvider),
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Ionicons.chatbubble_ellipses_outline,
                              size: 64,
                              color: themeProvider.isDarkMode 
                                  ? Colors.grey.shade700 
                                  : Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Comece uma conversa',
                              style: TextStyle(
                                color: themeProvider.isDarkMode 
                                    ? Colors.grey.shade600 
                                    : Colors.grey.shade400,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Envie uma mensagem para iniciar',
                              style: TextStyle(
                                color: themeProvider.isDarkMode 
                                    ? Colors.grey.shade600 
                                    : Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          if (_conversationTitle != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                              child: Column(
                                children: [
                                  Text(
                                    _conversationTitle!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: themeProvider.isDarkMode 
                                          ? Colors.white 
                                          : const Color(0xFF212529),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  if (_conversationStartTime != null)
                                    Text(
                                      DateFormat('dd/MM/yyyy \'at\' HH:mm').format(_conversationStartTime!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeProvider.isDarkMode 
                                            ? Colors.grey.shade500 
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                              itemCount: _messages.length + (_isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (_isLoading && index == _messages.length) {
                                  return _buildThinkingIndicator(themeProvider);
                                }
                                return _buildMessageBubble(_messages[index], themeProvider);
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          _buildInputArea(themeProvider),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeProvider themeProvider) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: (themeProvider.isDarkMode 
            ? const Color(0xFF212529) 
            : Colors.white).withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: themeProvider.isDarkMode 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            child: Text(
              'DocuGen Chat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode 
                    ? Colors.white 
                    : const Color(0xFF212529),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingIndicator(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.only(right: 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFC0C0C0).withOpacity(0.3),
                    const Color(0xFFE8E8E8).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFC0C0C0).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC0C0C0).withOpacity(0.2 + _shimmerController.value * 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Ionicons.bulb,
                    size: 18,
                    color: const Color(0xFF808080),
                  ),
                  const SizedBox(width: 12),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF808080),
                          const Color(0xFFC0C0C0),
                          const Color(0xFF808080),
                        ],
                        stops: [
                          0.0,
                          _shimmerController.value,
                          1.0,
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      _currentThinkingStep,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
            color: themeProvider.isDarkMode 
                ? const Color(0xFF343A40) 
                : const Color(0xFF212529),
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
      // Mensagem da IA sem container
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
    // Verificar se contém HTML
    if (text.contains('<!DOCTYPE html>') || text.contains('<html')) {
      // Extrair texto antes do HTML
      int htmlStart = text.indexOf('<!DOCTYPE html>');
      if (htmlStart == -1) {
        htmlStart = text.indexOf('<html');
      }
      
      String textBeforeHtml = htmlStart > 0 ? text.substring(0, htmlStart).trim() : '';
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (textBeforeHtml.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                textBeforeHtml,
                style: TextStyle(
                  color: themeProvider.isDarkMode 
                      ? Colors.white 
                      : const Color(0xFF212529),
                  fontSize: 15,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode 
                  ? const Color(0xFF343A40).withOpacity(0.5)
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Ionicons.code_slash,
                  size: 16,
                  color: themeProvider.isDarkMode 
                      ? Colors.grey.shade400 
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Documento HTML gerado',
                  style: TextStyle(
                    color: themeProvider.isDarkMode 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade600,
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
    
    // Texto normal
    return Text(
      text,
      style: TextStyle(
        color: themeProvider.isDarkMode 
            ? Colors.white 
            : const Color(0xFF212529),
        fontSize: 15,
      ),
    );
  }

  Widget _buildInputArea(ThemeProvider themeProvider) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: (themeProvider.isDarkMode 
              ? const Color(0xFF212529) 
              : Colors.white).withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isInputActive && kIsWeb && _htmlInput != null) {
                            _htmlInput!.focus();
                            setState(() {
                              _isInputActive = true;
                            });
                          } else if (!_isInputActive && !kIsWeb) {
                            _focusNode.requestFocus();
                            setState(() {
                              _isInputActive = true;
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode 
                                ? const Color(0xFF343A40) 
                                : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: kIsWeb
                              ? IgnorePointer(
                                  ignoring: !_isInputActive,
                                  child: Opacity(
                                    opacity: _isInputActive ? 1.0 : 0.7,
                                    child: HtmlElementView(
                                      viewType: _viewType,
                                      key: ValueKey(themeProvider.isDarkMode),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: TextField(
                                    controller: _messageController,
                                    focusNode: _focusNode,
                                    enabled: _isInputActive,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: themeProvider.isDarkMode 
                                          ? Colors.white 
                                          : const Color(0xFF212529),
                                    ),
                                    decoration: InputDecoration.collapsed(
                                      hintText: 'Ask DocuGen',
                                      hintStyle: TextStyle(
                                        color: themeProvider.isDarkMode 
                                            ? Colors.white54 
                                            : const Color(0xFFADB5BD),
                                        fontSize: 16,
                                      ),
                                    ),
                                    cursorColor: themeProvider.isDarkMode 
                                        ? Colors.white 
                                        : const Color(0xFF212529),
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    onTap: () {
                                      setState(() {
                                        _isInputActive = true;
                                      });
                                    },
                                    onSubmitted: (_) => _sendMessageNative(),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _isLoading ? null : (kIsWeb ? _sendMessageFromHtml : _sendMessageNative),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode 
                              ? const Color(0xFF495057) 
                              : const Color(0xFF212529),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? SvgPicture.string(
                                  _stopIconSvg,
                                  width: 20,
                                  height: 20,
                                )
                              : SvgPicture.string(
                                  _sendIconSvg,
                                  width: 24,
                                  height: 24,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessageNative() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;
    _sendMessage(text);
    _messageController.clear();
    _focusNode.unfocus();
    setState(() {
      _isInputActive = false;
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    if (!mounted) return;

    if (_conversationStartTime == null) {
      _conversationStartTime = DateTime.now();
    }

    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _isLoading = true;
      _currentThinkingStep = _thinkingSteps[0];
    });

    _scrollToBottom();
    _animateThinkingSteps();

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
5. Após gerar o HTML, SEMPRE termine sua resposta com exatamente esta frase: "Trabalho concluído! Carregando o preview..."

EXEMPLO DE ESTRUTURA:
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
</html>

Trabalho concluído! Carregando o preview...''',
            },
            ..._buildMessageHistory(),
          ],
          'temperature': 0.3,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];

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

          if (_conversationTitle == null && _messages.length == 2) {
            _generateConversationTitle();
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

  Future<void> _animateThinkingSteps() async {
    for (int i = 0; i < _thinkingSteps.length; i++) {
      if (!_isLoading) break;
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && _isLoading) {
        setState(() {
          _currentThinkingStep = _thinkingSteps[i];
        });
      }
    }
  }

  List<Map<String, String>> _buildMessageHistory() {
    return _messages
        .map((msg) => {
              'role': msg.isUser ? 'user' : 'assistant',
              'content': msg.text,
            })
        .toList();
  }

  Future<void> _generateConversationTitle() async {
    if (_messages.isEmpty) return;

    try {
      final firstMessage = _messages.first.text;
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
              'content': 'Gere um título curto e descritivo (máximo 5 palavras) para esta conversa. Responda apenas com o título, sem pontuação no final.',
            },
            {
              'role': 'user',
              'content': firstMessage,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 20,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final title = data['choices'][0]['message']['content'].trim();

        if (mounted) {
          setState(() {
            _conversationTitle = title;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao gerar título: $e');
    }
  }

  void _scrollToBottom():
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

  @override
  void dispose() {
    _shimmerController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}