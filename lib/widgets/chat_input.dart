// lib/widgets/chat_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class ChatInput extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final bool isDarkMode;
  final bool isLoading;
  final Future<void> Function(String text) onSend;
  final String viewType;
  final String sendIconSvg;
  final String stopIconSvg;

  const ChatInput({
    Key? key,
    required this.messageController,
    required this.focusNode,
    required this.isDarkMode,
    required this.isLoading,
    required this.onSend,
    this.viewType = 'chat-input-only',
    required this.sendIconSvg,
    required this.stopIconSvg,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  static bool _viewRegistered = false;
  html.TextAreaElement? _htmlInput;
  bool _isInputActive = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && !_viewRegistered) {
      _registerWebView();
      _viewRegistered = true;
    }
  }

  void _registerWebView() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(widget.viewType, (int viewId) {
        final inputBgColor = widget.isDarkMode ? '#343A40' : '#F8F9FA';
        final inputTextColor = widget.isDarkMode ? '#FFFFFF' : '#212529';
        final inputPlaceholderColor = widget.isDarkMode ? '#ADB5BD' : '#6C757D';

        final wrapper = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.alignItems = 'center';

        _htmlInput = html.TextAreaElement()
          ..id = 'chatInput-$viewId'
          ..placeholder = 'Ask DocuGen'
          ..autocomplete = 'off'
          ..setAttribute('spellcheck', 'false')
          ..rows = 1
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
          ..style.resize = 'none'
          ..style.overflow = 'hidden'
          ..style.minHeight = '26px'
          ..style.maxHeight = '120px'
          ..style.lineHeight = '1.4'
          ..style.setProperty('-webkit-user-select', 'text')
          ..style.userSelect = 'text'
          ..style.setProperty('-webkit-tap-highlight-color', 'transparent');

        final style = html.StyleElement()
          ..text = '''
            #chatInput-$viewId::placeholder { color: $inputPlaceholderColor; }
            #chatInput-$viewId:focus { box-shadow: none !important; outline: none !important; }
            #chatInput-$viewId::-webkit-scrollbar { width: 4px; }
            #chatInput-$viewId::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.2); border-radius: 4px; }
          ''';

        wrapper.append(style);
        wrapper.append(_htmlInput!);

        _htmlInput!.onInput.listen((_) {
          _adjustHeight();
        });

        _htmlInput!.onKeyDown.listen((e) {
          if (e.key == 'Enter' && !e.shiftKey) {
            e.preventDefault();
            final text = _htmlInput!.value?.trim() ?? '';
            if (text.isNotEmpty && !widget.isLoading) {
              widget.onSend(text);
              _htmlInput!.value = '';
              _resetHeight();
              _htmlInput!.blur();
              setState(() => _isInputActive = false);
            }
          }
        });

        _htmlInput!.onFocus.listen((_) {
          setState(() => _isInputActive = true);
        });

        _htmlInput!.onBlur.listen((_) {
          setState(() => _isInputActive = false);
        });

        return wrapper;
      });
    } catch (e) {
      debugPrint('Error registering chat input view: $e');
    }
  }

  void _adjustHeight() {
    if (_htmlInput == null) return;
    _htmlInput!.style.height = 'auto';
    _htmlInput!.style.height = '${_htmlInput!.scrollHeight}px';
  }

  void _resetHeight() {
    if (_htmlInput == null) return;
    _htmlInput!.style.height = '26px';
  }

  void _handleSend() {
    if (kIsWeb) {
      final text = _htmlInput?.value?.trim() ?? '';
      if (text.isEmpty) return;
      widget.onSend(text);
      _htmlInput?.value = '';
      _resetHeight();
      _htmlInput?.blur();
      setState(() => _isInputActive = false);
      return;
    }

    final text = widget.messageController.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    widget.messageController.clear();
    widget.focusNode.unfocus();
    setState(() => _isInputActive = false);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? const Color(0xFF343A40) : Colors.white;
    final inputBgColor = widget.isDarkMode ? const Color(0xFF343A40) : const Color(0xFFF8F9FA);
    final circleColor = widget.isDarkMode ? Colors.white : const Color(0xFF212529);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
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
                    constraints: const BoxConstraints(minHeight: 50),
                    decoration: BoxDecoration(color: inputBgColor, borderRadius: BorderRadius.circular(24)),
                    child: kIsWeb
                        ? IgnorePointer(
                            ignoring: !_isInputActive,
                            child: Opacity(
                              opacity: _isInputActive ? 1.0 : 0.7,
                              child: HtmlElementView(viewType: widget.viewType, key: ValueKey(widget.isDarkMode)),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: TextField(
                              controller: widget.messageController,
                              focusNode: widget.focusNode,
                              enabled: true,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(fontSize: 16, color: widget.isDarkMode ? Colors.white : const Color(0xFF212529)),
                              decoration: InputDecoration.collapsed(
                                hintText: 'Ask DocuGen',
                                hintStyle: TextStyle(color: widget.isDarkMode ? Colors.white54 : const Color(0xFFADB5BD), fontSize: 16),
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
                  decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle, boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))
                  ]),
                  child: Center(
                    child: widget.isLoading
                        ? SvgPicture.string(
                            widget.stopIconSvg,
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              widget.isDarkMode ? const Color(0xFF212529) : Colors.white,
                              BlendMode.srcIn,
                            ),
                          )
                        : SvgPicture.string(
                            widget.sendIconSvg,
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              widget.isDarkMode ? const Color(0xFF212529) : Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}