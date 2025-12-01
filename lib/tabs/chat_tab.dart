import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:js_util' as js_util; // para registar função global JS

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  static const String _viewType = 'chat-input-view';
  static bool _viewRegistered = false;

  // SVG fornecido pelo utilizador (usado na versão nativa via flutter_svg)
  static const String _userArrowSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <path d="M12 5V19M12 5L6 11M12 5L18 11" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path> </g></svg>
''';

  @override
  void initState() {
    super.initState();
    if (kIsWeb && !_viewRegistered) {
      _registerWebView();
      _viewRegistered = true;
    }
    if (kIsWeb) {
      _setupMessageListener();
      // Registar função global JS para chamada direta (fallback robusto)
      try {
        js_util.setProperty(html.window, 'flutterReceiveMessage',
            (dynamic msg) {
          // debug
          // ignore: avoid_print
          print('flutterReceiveMessage called from JS with: $msg');
          if (msg != null && msg.toString().trim().isNotEmpty && mounted) {
            _sendMessage(msg.toString().trim());
          }
        });
      } catch (e) {
        // ignore: avoid_print
        print('Erro ao registar flutterReceiveMessage: $e');
      }
    }
  }

  void _registerWebView() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final element = html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%';

          element.setInnerHtml(
            // placeholder "Ask DocuGen" e SVG de envio; envio faz postMessage + chamada direta a flutterReceiveMessage
            '''
            <div style="display: flex; align-items: center; gap: 12px; width: 100%; height: 100%; padding: 0;">
              <input 
                type="text" 
                id="chatInput" 
                placeholder="Ask DocuGen"
                autocomplete="off"
                spellcheck="false"
                style="
                  flex: 1;
                  padding: 12px 20px;
                  border: none;
                  border-radius: 24px;
                  font-size: 16px;
                  outline: none;
                  background-color: #FFFFFF;
                  color: #212529;
                  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                  transition: all 0.3s;
                  -webkit-user-select: text;
                  user-select: text;
                  -webkit-tap-highlight-color: transparent;
                "
              >
              <button 
                id="sendBtn"
                type="button"
                style="
                  width: 48px;
                  height: 48px;
                  border: none;
                  border-radius: 50%;
                  background-color: #212529;
                  color: white;
                  cursor: pointer;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  flex-shrink: 0;
                  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
                  transition: all 0.2s;
                  -webkit-tap-highlight-color: transparent;
                "
              >
                <!-- SVG 'arrow' -->
                <svg width="20" height="20" viewBox="0 0 48 48" fill="currentColor" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                  <rect x="20" y="16" width="8" height="24" rx="4"/>
                  <path d="M24 4L12 16H20V20H28V16H36L24 4Z"/>
                </svg>
              </button>
            </div>
            <style>
              * {
                -webkit-touch-callout: none;
                -webkit-user-select: none;
                -moz-user-select: none;
                -ms-user-select: none;
                user-select: none;
              }
              
              /* permitir seleção apenas no input */
              #chatInput {
                -webkit-user-select: text !important;
                user-select: text !important;
              }

              /* remover efeitos visuais de foco */
              #chatInput:focus {
                background-color: #FFFFFF;
                box-shadow: none !important;
                outline: none !important;
              }
              
              #chatInput::placeholder {
                color: #ADB5BD;
              }
              
              #sendBtn:hover {
                background-color: #343A40;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
              }
              
              #sendBtn:active {
                transform: scale(0.95);
                background-color: #495057;
              }
            </style>
            <script>
              const input = document.getElementById('chatInput');
              const btn = document.getElementById('sendBtn');

              function send() {
                const msg = input.value.trim();
                if (!msg) return;

                const payload = { type: 'chat-message', message: msg };

                // TENTATIVAS MULTIPLAS: postMessage + dispatchEvent + chamada direta se existir
                try { window.parent.postMessage(payload, '*'); } catch(e) {}
                try { window.postMessage(payload, '*'); } catch(e) {}
                try { window.dispatchEvent(new MessageEvent('message', { data: payload })); } catch(e) {}

                // Chamada direta para flutterReceiveMessage (registered by Dart)
                try {
                  if (typeof window.flutterReceiveMessage === 'function') {
                    window.flutterReceiveMessage(msg);
                  }
                } catch (e) {}

                input.value = '';
              }

              btn.addEventListener('click', (e) => {
                e.preventDefault();
                send();
              });

              input.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                  e.preventDefault();
                  send();
                }
              });

              input.addEventListener('touchstart', (e) => {
                e.stopPropagation();
              });

              btn.addEventListener('touchstart', (e) => {
                e.stopPropagation();
              });

              input.addEventListener('focus', (e) => {
                input.style.outline = 'none';
                input.style.boxShadow = 'none';
              });

              // botão de teste no HTML (não visível por padrão) -- comentado por segurança
              // const testBtn = document.createElement('button'); testBtn.innerText = 'TEST'; testBtn.style.display='none'; document.body.appendChild(testBtn);
            </script>
            ''',
            treeSanitizer: html.NodeTreeSanitizer.trusted,
          );

          return element;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error registering view: $e');
    }
  }

  void _setupMessageListener() {
    // Listener padrão de message events
    html.window.onMessage.listen((event) {
      // debug
      // ignore: avoid_print
      print('Message received (raw): ${event.data}');

      String? message;
      final data = event.data;

      try {
        if (data == null) {
          // nada
        } else if (data is Map) {
          if (data['type'] == 'chat-message') {
            message = data['message']?.toString();
          }
        } else if (data is String) {
          try {
            final parsed = jsonDecode(data);
            if (parsed is Map && parsed['type'] == 'chat-message') {
              message = parsed['message']?.toString();
            } else {
              // fallback: tratar a string como mensagem direta
              message = data;
            }
          } catch (_) {
            // fallback: tratar a string como mensagem direta
            message = data;
          }
        } else {
          // tentativa genérica
          try {
            final dyn = data as dynamic;
            final t = dyn['type'];
            final m = dyn['message'];
            if (t == 'chat-message') {
              message = m?.toString();
            }
          } catch (_) {
            message = data.toString();
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('Erro ao processar event.data: $e');
        message = data?.toString();
      }

      if (message != null && message.trim().isNotEmpty && mounted) {
        _sendMessage(message.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Comece uma conversa',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Envie uma mensagem para iniciar',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
          ],
        ),
        _buildInputArea(),
        // pequeno botão de debug (nativo) no canto inferior direito — útil para testar envio direto
        Positioned(
          right: 16,
          bottom: 80,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              _sendMessage('Mensagem de teste (debug)');
            },
            child: const Icon(Icons.bug_report),
            backgroundColor: const Color(0xFF212529),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF212529)
              : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : const Color(0xFF212529),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 50,
              child: kIsWeb
                  ? HtmlElementView(viewType: _viewType)
                  : _buildNativeInput(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNativeInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF212529),
              ),
              decoration: const InputDecoration.collapsed(
                hintText: 'Ask DocuGen',
                hintStyle: TextStyle(
                  color: Color(0xFFADB5BD),
                  fontSize: 16,
                ),
              ),
              cursorColor: const Color(0xFF212529),
              enableSuggestions: false,
              autocorrect: false,
              onSubmitted: (_) => _sendMessageNative(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botão com SVG fornecido
        GestureDetector(
          onTap: _sendMessageNative,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Center(
              child: SvgPicture.string(
                _userArrowSvg,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _sendMessageNative() {
    final text = _messageController.text.trim();
    // ignore: avoid_print
    print('Native send: $text');
    if (text.isEmpty) return;

    _sendMessage(text);
    _messageController.clear();
    _focusNode.unfocus();
  }

  void _sendMessage(String text) {
    // ignore: avoid_print
    print('Adding message: $text');
    if (text.trim().isEmpty) return;
    if (!mounted) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text.trim(),
        isUser: true,
      ));
      // ignore: avoid_print
      print('Messages count: ${_messages.length}');
    });

    // scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
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