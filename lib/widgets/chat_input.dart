// lib/widgets/chat_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ionicons/ionicons.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Conditional imports corrigidos
import 'chat_input_web_html_stub.dart'
    if (dart.library.html) 'dart:html' as html;
import 'chat_input_web_ui_stub.dart'
    if (dart.library.html) 'dart:ui_web' as ui_web;

class ChatInput extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final bool isDarkMode;
  final bool isLoading;
  final bool isEditing;
  final Future<void> Function(String text) onSend;
  final VoidCallback? onCancelEdit;

  const ChatInput({
    Key? key,
    required this.messageController,
    required this.focusNode,
    required this.isDarkMode,
    required this.isLoading,
    this.isEditing = false,
    required this.onSend,
    this.onCancelEdit,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  static const String _viewType = 'chat-input-only';
  static bool _viewRegistered = false;
  html.InputElement? _htmlInput;
  bool _isInputActive = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && !_viewRegistered) {
      _registerWebView();
      _viewRegistered = true;
    }
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (kIsWeb && widget.isEditing && _htmlInput != null) {
      _htmlInput!.value = widget.messageController.text;
      _htmlInput!.focus();
      setState(() => _isInputActive = true);
    }

    if (kIsWeb && !widget.isEditing && oldWidget.isEditing && _htmlInput != null) {
      _htmlInput!.value = '';
    }
  }

  void _registerWebView() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final inputBgColor = widget.isDarkMode ? '#2D333B' : '#F1F3F5';
        final inputTextColor = widget.isDarkMode ? '#FFFFFF' : '#212529';
        final inputPlaceholderColor = widget.isDarkMode ? '#ADB5BD' : '#6C757D';

        final wrapper = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.alignItems = 'center';

        _htmlInput = html.InputElement()
          ..id = 'chatInput-$viewId'
          ..type = 'text'
          ..placeholder = 'Ask DocuGen'
          ..setAttribute('autocomplete', 'off')
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
            #chatInput-$viewId::placeholder { color: $inputPlaceholderColor; }
            #chatInput-$viewId:focus { 
              box-shadow: none !important;
              outline: none !important;
            }
          ''';

        wrapper.append(style);
        wrapper.append(_htmlInput!);

        _htmlInput!.onKeyPress.listen((e) {
          if (e.key == 'Enter') {
            e.preventDefault();
            final text = _htmlInput!.value?.trim() ?? '';
            if (text.isNotEmpty && !widget.isLoading) {
              widget.onSend(text);
              if (!widget.isEditing) {
                _htmlInput!.value = '';
                _htmlInput!.blur();
                setState(() => _isInputActive = false);
              }
            }
          }
        });

        _htmlInput!.onInput.listen((_) {
          if (!kIsWeb) {
            widget.messageController.text = _htmlInput!.value ?? '';
          }
        });

        _htmlInput!.onFocus.listen((_) {
          setState(() => _isInputActive = true);
        });

        _htmlInput!.onBlur.listen((_) {
          if (!widget.isEditing) {
            setState(() => _isInputActive = false);
          }
        });

        return wrapper;
      });
    } catch (e) {
      debugPrint('Error registering chat input view: $e');
    }
  }

  void _handleSend() {
    if (kIsWeb) {
      final text = _htmlInput?.value?.trim() ?? '';
      if (text.isEmpty) return;
      widget.onSend(text);
      if (!widget.isEditing) {
        _htmlInput?.value = '';
        _htmlInput?.blur();
        setState(() => _isInputActive = false);
      }
      return;
    }

    final text = widget.messageController.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    if (!widget.isEditing) {
      widget.messageController.clear();
      widget.focusNode.unfocus();
      setState(() => _isInputActive = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? const Color(0xFF1C2128) : Colors.white;
    final inputBgColor = widget.isDarkMode ? const Color(0xFF2D333B) : const Color(0xFFF1F3F5);
    final circleColor = widget.isDarkMode ? Colors.white : const Color(0xFF212529);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDarkMode ? 0.2 : 0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDarkMode ? 0.1 : 0.03),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isEditing)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isDarkMode
                          ? [
                              const Color(0xFF2A2A2A),
                              const Color(0xFF1F1F1F),
                            ]
                          : [
                              const Color(0xFFF8F9FA),
                              const Color(0xFFFFFFFF),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.06),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/edit.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF667eea),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Editando mensagem',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white : const Color(0xFF212529),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onCancelEdit,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.isDarkMode 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/close.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!_isInputActive && kIsWeb && _htmlInput != null) {
                          _htmlInput!.focus();
                          setState(() => _isInputActive = true);
                        } else if (!_isInputActive && !kIsWeb) {
                          widget.focusNode.requestFocus();
                          setState(() => _isInputActive = true);
                        }
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: inputBgColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: kIsWeb
                            ? IgnorePointer(
                                ignoring: !_isInputActive && !widget.isEditing,
                                child: Opacity(
                                  opacity: _isInputActive || widget.isEditing ? 1.0 : 0.7,
                                  child: HtmlElementView(
                                    viewType: _viewType,
                                    key: ValueKey('${widget.isDarkMode}-${widget.isEditing}'),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: TextField(
                                  controller: widget.messageController,
                                  focusNode: widget.focusNode,
                                  enabled: true,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: widget.isDarkMode ? Colors.white : const Color(0xFF212529),
                                  ),
                                  decoration: InputDecoration.collapsed(
                                    hintText: widget.isEditing ? 'Editar mensagem...' : 'Ask DocuGen',
                                    hintStyle: TextStyle(
                                      color: widget.isDarkMode ? Colors.white54 : const Color(0xFFADB5BD),
                                      fontSize: 16,
                                    ),
                                  ),
                                  cursorColor: widget.isDarkMode ? Colors.white : const Color(0xFF212529),
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  onTap: () => setState(() => _isInputActive = true),
                                  onSubmitted: (_) => _handleSend(),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: widget.isLoading ? null : _handleSend,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          widget.isLoading
                              ? Ionicons.stop
                              : widget.isEditing
                                  ? Ionicons.checkmark
                                  : Ionicons.arrow_up,
                          color: widget.isDarkMode ? const Color(0xFF212529) : Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}