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
    // remove indicadores de foco do FocusNode (não forçamos autofocus)
    try {
      widget.focusNode.canRequestFocus = true; // allow focus if user taps
    } catch (_) {}
    if (kIsWeb && !_viewRegistered) {
      _registerWebView();
      _viewRegistered = true;
    }
  }

  void _registerWebView() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(widget.viewType, (int viewId) {
        // usar as mesmas cores do bottom tabbar: escuro 0xFF1C2128 ou branco no claro
        final inputBgColor = widget.isDarkMode ? '#1C2128' : '#FFFFFF';
        final inputTextColor = widget.isDarkMode ? '#FFFFFF' : '#212529';
        final inputPlaceholderColor = widget.isDarkMode ? '#ADB5BD' : '#6C757D';
        final maxHeightPx = (_maxVisibleLines * _lineHeightPx);

        final wrapper = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.alignItems = 'center';

        // textarea para suportar múltiplas linhas e auto-resize
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
          ..style.resize = 'none' // impedir redimensionamento manual horizontal
          ..style.overflowY = 'auto'
          ..style.overflowX = 'hidden'
          ..style.maxHeight = '${maxHeightPx}px'
          ..style.lineHeight = '${_lineHeightPx}px'
          ..style.fontFamily = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
          ..style.transition = 'background-color 0.3s, height 0.08s'
          ..style.setProperty('-webkit-user-select', 'text')
          ..style.userSelect = 'text'
          ..setAttribute('rows', '1')
          ..setAttribute('wrap', 'soft')
          ..setAttribute('spellcheck', 'false')
          ..style.whiteSpace = 'pre-wrap'
          ..style.wordWrap = 'break-word'
          ..style.tabIndex = '0'; // mantém acessível por tab / clique

        // estilo extra para placeholder + remoção de foco visual
        final style = html.StyleElement()
          ..text = '''
            #chatTextarea-$viewId::placeholder { color: $inputPlaceholderColor; }
            #chatTextarea-$viewId:focus { box-shadow: none !important; outline: none !important; }
            #chatTextarea-$viewId { scrollbar-width: thin; }
          ''';

        wrapper.append(style);
        wrapper.append(_htmlTextarea!);

        // auto-resize handler
        void resize() {
          // reset height to auto to measure scrollHeight
          _htmlTextarea!.style.height = 'auto';
          final scrollH = _htmlTextarea!.scrollHeight!;
          final cap = maxHeightPx;
          final newH = math.min(scrollH, cap);
          // garantir altura mínima de uma linha
          final minH = _lineHeightPx + 12; // lineHeight + padding
          _htmlTextarea!.style.height = '${math.max(newH, minH)}px';
        }

        // listeners
        _htmlTextarea!.onInput.listen((_) {
          resize();
        });

        _htmlTextarea!.onKeyPress.listen((e) {
          if (e.key == 'Enter' && !e.shiftKey) {
            // Enter envia (Shift+Enter adiciona nova linha)
            e.preventDefault();
            final text = _htmlTextarea!.value?.trim() ?? '';
            if (text.isNotEmpty && !widget.isLoading) {
              widget.onSend(text);
              _htmlTextarea!.value = '';
              resize();
              // mantemos sem foco visual (mas não fazemos blur automático)
              setState(() => _isInputActive = false);
            }
          }
        });

        _htmlTextarea!.onFocus.listen((_) {
          // removemos qualquer foco visual (CSS já cuida), e marcamos ativo
          setState(() => _isInputActive = true);
          resize();
        });

        _htmlTextarea!.onBlur.listen((_) {
          setState(() => _isInputActive = false);
        });

        // inicial resize
        // pequena microtask para garantir que o elemento foi inserido antes de medir
        Future.delayed(const Duration(milliseconds: 20), () {
          try {
            resize();
          } catch (_) {}
        });

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
      // ajustar altura após limpar
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
    // **Match do bottom tabbar**:
    // bottom tabbar usa: escuro 0xFF1C2128 ; claro: Colors.white
    final bgColor = widget.isDarkMode ? const Color(0xFF1C2128) : Colors.white;
    final inputBgColor = bgColor; // input icónico com o mesmo tom
    final circleColor = widget.isDarkMode ? Colors.white : const Color(0xFF212529);

    // remover outline/box-shadow visível ao focar (TextField)
    final inputDecoration = const InputDecoration.collapsed(
      hintText: 'Ask DocuGen',
    );

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        // mantive a sombra do container - se quiser remover, diga
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  // o input deve ter o mesmo tom do bottom tabbar
                  decoration: BoxDecoration(color: inputBgColor, borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  constraints: const BoxConstraints(minHeight: 50),
                  child: kIsWeb
                      ? // Web: Html textarea view
                      HtmlElementView(viewType: widget.viewType, key: ValueKey(widget.isDarkMode))
                      : // Mobile/Desktop: TextField multiline com auto-expand até 10 linhas
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: _maxVisibleLines * _lineHeightPx.toDouble() + 24),
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
                                decoration: inputDecoration.copyWith(
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
                                // remover foco visual: usamos Focus to control overlay
                                // (o TextField continuará a receber foco normalmente, mas não terá outline)
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
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: Offset(0, 2))
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