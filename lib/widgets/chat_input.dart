// lib/widgets/chat_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

// Web-only imports
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: prefer_relative_imports
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
  html.TextAreaElement? _htmlTextarea;
  bool _isInputActive = false;

  // parâmetros para auto-resize (web)
  final int _maxVisibleLines = 10;
  final int _lineHeightPx = 22; // ajuste se necessário

  @override
  void initState() {
    super.initState();
    try {
      widget.focusNode.canRequestFocus = true;
    } catch (_) {}
    if (kIsWeb && !_viewRegistered) {
      _registerWebView();
      _viewRegistered = true;
    }
  }

  void _registerWebView() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(widget.viewType, (int viewId) {
        // O tom do bottom tabbar: escuro 0xFF1C2128 ; claro: #FFFFFF
        final inputBgColor = widget.isDarkMode ? '#1C2128' : '#FFFFFF';
        final inputTextColor = widget.isDarkMode ? '#FFFFFF' : '#212529';
        final inputPlaceholderColor = widget.isDarkMode ? '#ADB5BD' : '#6C757D';
        final maxHeightPx = (_maxVisibleLines * _lineHeightPx);

        final wrapper = html.DivElement()
          ..style.width = '100%'
          ..style.display = 'flex'
          ..style.alignItems = 'center';

        _htmlTextarea = html.TextAreaElement()
          ..id = 'chatTextarea-$viewId'
          ..placeholder = 'Ask DocuGen'
          ..setAttribute('autocomplete', 'off')
          ..setAttribute('spellcheck', 'false')
          ..style.width = '100%'
          ..style.boxSizing = 'border-box'
          ..style.padding = '10px 16px'
          ..style.border = 'none'
          ..style.borderRadius = '24px'
          ..style.fontSize = '16px'
          ..style.outline = 'none'
          ..style.backgroundColor = inputBgColor
          ..style.color = inputTextColor
          ..style.resize = 'none'
          ..style.overflowY = 'auto'
          ..style.overflowX = 'hidden'
          ..style.maxHeight = '${maxHeightPx}px'
          ..style.lineHeight = '${_lineHeightPx}px'
          ..style.fontFamily = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
          ..style.transition = 'background-color 0.2s, height 0.08s'
          ..style.setProperty('-webkit-user-select', 'text')
          ..style.userSelect = 'text'
          ..setAttribute('rows', '1')
          ..setAttribute('wrap', 'soft')
          ..style.whiteSpace = 'pre-wrap'
          ..style.wordWrap = 'break-word';

        // tabindex no elemento (não em style)
        _htmlTextarea!.tabIndex = 0;

        final style = html.StyleElement()
          ..text = '''
            #chatTextarea-$viewId::placeholder { color: $inputPlaceholderColor; }
            #chatTextarea-$viewId:focus { box-shadow: none !important; outline: none !important; }
            #chatTextarea-$viewId { scrollbar-width: thin; }
          ''';

        wrapper.append(style);
        wrapper.append(_htmlTextarea!);

        void resize() {
          try {
            _htmlTextarea!.style.height = 'auto';
            final scrollH = _htmlTextarea!.scrollHeight ?? 0;
            final cap = maxHeightPx;
            final newH = math.min(scrollH, cap);
            final minH = _lineHeightPx + 12; // linha + padding
            _htmlTextarea!.style.height = '${math.max(newH, minH)}px';
          } catch (_) {}
        }

        _htmlTextarea!.onInput.listen((_) => resize());

        _htmlTextarea!.onKeyPress.listen((e) {
          if (e.key == 'Enter' && !e.shiftKey) {
            e.preventDefault();
            final text = _htmlTextarea!.value?.trim() ?? '';
            if (text.isNotEmpty && !widget.isLoading) {
              widget.onSend(text);
              _htmlTextarea!.value = '';
              resize();
              setState(() => _isInputActive = false);
            }
          }
        });

        _htmlTextarea!.onFocus.listen((_) {
          setState(() => _isInputActive = true);
          resize();
        });

        _htmlTextarea!.onBlur.listen((_) {
          setState(() => _isInputActive = false);
        });

        Future.delayed(const Duration(milliseconds: 20), () => resize());

        return wrapper;
      });
    } catch (e) {
      debugPrint('Error registering chat input view: $e');
    }
  }

  void _handleSend() {
    if (kIsWeb) {
      final text = _htmlTextarea?.value?.trim() ?? '';
      if (text.isEmpty) return;
      widget.onSend(text);
      _htmlTextarea?.value = '';
      try {
        _htmlTextarea?.style.height = 'auto';
      } catch (_) {}
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
    // Match do bottom tabbar:
    final bgColor = widget.isDarkMode ? const Color(0xFF1C2128) : Colors.white;
    final inputBgColor = bgColor; // input com o mesmo tom do tabbar
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
            crossAxisAlignment: CrossAxisAlignment.center, // mantém alinhamento vertical original
            children: [
              // ESTE GestureDetector + IgnorePointer + Opacity RESTAURA o comportamento anterior
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!_isInputActive && kIsWeb && _htmlTextarea != null) {
                      _htmlTextarea!.focus();
                      setState(() => _isInputActive = true);
                    } else if (!_isInputActive && !kIsWeb) {
                      widget.focusNode.requestFocus();
                      setState(() => _isInputActive = true);
                    }
                  },
                  child: Container(
                    // mantemos uma altura mínima para que a posição não mude
                    constraints: const BoxConstraints(minHeight: 50),
                    decoration: BoxDecoration(color: inputBgColor, borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: kIsWeb
                          ? IgnorePointer(
                              ignoring: !_isInputActive,
                              child: Opacity(
                                opacity: _isInputActive ? 1.0 : 0.85,
                                child: HtmlElementView(viewType: widget.viewType, key: ValueKey(widget.isDarkMode)),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: _maxVisibleLines * _lineHeightPx.toDouble() + 24,
                                ),
                                child: Scrollbar(
                                  child: TextField(
                                    controller: widget.messageController,
                                    focusNode: widget.focusNode,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    minLines: 1,
                                    maxLines: _maxVisibleLines,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: widget.isDarkMode ? Colors.white : const Color(0xFF212529),
                                      height: 1.2,
                                    ),
                                    decoration: InputDecoration.collapsed(
                                      hintText: 'Ask DocuGen',
                                      hintStyle: TextStyle(
                                        color: widget.isDarkMode ? Colors.white54 : const Color(0xFFADB5BD),
                                        fontSize: 16,
                                      ),
                                    ),
                                    cursorColor: widget.isDarkMode ? Colors.white : const Color(0xFF212529),
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    onSubmitted: (_) => _handleSend(),
                                  ),
                                ),
                              ),
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