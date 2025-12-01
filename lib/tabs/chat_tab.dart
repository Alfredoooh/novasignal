import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

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

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerWebView();
      _setupMessageListener();
    }
  }

  void _registerWebView() {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final element = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%';

        element.setInnerHtml(
          '''
          <div style="display: flex; align-items: center; gap: 12px; width: 100%; height: 100%; padding: 0;">
            <input 
              type="text" 
              id="chatInput" 
              placeholder="Type a message..."
              autocomplete="off"
              spellcheck="false"
              style="
                flex: 1;
                padding: 12px 20px;
                border: none;
                border-radius: 24px;
                font-size: 16px;
                outline: none;
                background-color: #F8F9FA;
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
              <svg fill="currentColor" width="20" height="20" viewBox="0 0 512 512" style="transform: rotate(-90deg);">
                <path d="M233.4 406.6c12.5 12.5 32.8 12.5 45.3 0l192-192c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L256 338.7 86.6 169.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3l192 192z"/>
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
            
            #chatInput {
              -webkit-user-select: text !important;
              user-select: text !important;
            }
            
            #chatInput:focus {
              background-color: #FFFFFF;
              box-shadow: 0 0 0 2px rgba(33, 37, 41, 0.1);
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
              if (msg) {
                window.parent.postMessage({type: 'chat-message', message: msg}, '*');
                input.value = '';
              }
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
            
            // Prevenir comportamentos indesejados
            input.addEventListener('touchstart', (e) => {
              e.stopPropagation();
            });
            
            btn.addEventListener('touchstart', (e) => {
              e.stopPropagation();
            });
          </script>
          ''',
          treeSanitizer: html.NodeTreeSanitizer.trusted,
        );

        return element;
      },
    );
  }

  void _setupMessageListener() {
    html.window.onMessage.listen((event) {
      if (event.data is Map && event.data['type'] == 'chat-message') {
        _sendMessage(event.data['message']);
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
                      child: Text(
                        'Crie algo Novo',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
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
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF212529),
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(
                  color: Color(0xFFADB5BD),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessageNative(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
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
          child: IconButton(
            onPressed: _sendMessageNative,
            icon: Transform.rotate(
              angle: -1.5708, // -90 graus em radianos
              child: const Icon(Ionicons.chevron_down),
            ),
            color: Colors.white,
            iconSize: 20,
            padding: const EdgeInsets.all(14),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ),
      ],
    );
  }

  void _sendMessageNative() {
    if (_messageController.text.trim().isEmpty) return;
    _sendMessage(_messageController.text.trim());
    _messageController.clear();
    _focusNode.unfocus();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text.trim(),
        isUser: true,
      ));
    });

    Future.delayed(const Duration(milliseconds: 100), () {
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