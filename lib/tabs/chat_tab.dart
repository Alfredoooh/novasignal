// lib/tabs/chat_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_input.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/message_formatter.dart';
import 'dart:math' as math;
import 'dart:async';

// Conditional imports corrigidos
import 'chat_tab_js_stub.dart'
    if (dart.library.html) 'dart:js_util' as js_util;

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
  final ChatService _chatService = ChatService();

  bool _isLoading = false;
  late AnimationController _loadingController;
  ChatMessage? _editingMessage;
  int? _editingIndex;

  // Animação de texto
  String _currentStreamingText = '';
  Timer? _textAnimationTimer;
  bool _isStreaming = false;

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
    _textAnimationTimer?.cancel();
    _loadingController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    try {
      _scrollController.dispose();
    } catch (_) {}
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
        color: themeProvider.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        child: Stack(
          children: [
            Column(
              children: [
                _buildCustomAppBar(themeProvider),
                Expanded(
                  child: chatProvider.currentMessages.isEmpty
                      ? _buildEmptyState(themeProvider)
                      : _buildMessageList(themeProvider, chatProvider),
                ),
              ],
            ),
            _buildInputArea(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: themeProvider.isDarkMode
              ? [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF1A1A1A),
                ]
              : [
                  Colors.white,
                  Colors.white.withOpacity(0.9),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildCircularButton(
                'assets/icons/menu.svg',
                () => _openConversationsScreen(context),
                themeProvider,
              ),
              const Spacer(),
              _buildCircularButton(
                'assets/icons/plus.svg',
                () => _createNewConversationWithAnimation(context),
                themeProvider,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton(String svgPath, VoidCallback onTap, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            svgPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              themeProvider.isDarkMode ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  void _createNewConversationWithAnimation(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/plus.svg',
                      width: 80,
                      height: 80,
                      colorFilter: ColorFilter.mode(
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      chatProvider.createNewConversation();
    });
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Text(
        'Crie algo novo!',
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          fontSize: 24,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMessageList(ThemeProvider themeProvider, ChatProvider chatProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: chatProvider.currentMessages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == chatProvider.currentMessages.length) {
          return _buildLoadingIndicator(themeProvider);
        }

        final message = chatProvider.currentMessages[index];
        final isLastMessage = index == chatProvider.currentMessages.length - 1;

        return _buildMessageBubble(
          message,
          themeProvider,
          index,
          isStreaming: isLastMessage && _isStreaming,
        );
      },
    );
  }

  Widget _buildLoadingIndicator(ThemeProvider themeProvider) {
    final dotColor = themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
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

  Widget _buildMessageBubble(
    ChatMessage message,
    ThemeProvider themeProvider,
    int index, {
    bool isStreaming = false,
  }) {
    if (message.isUser) {
      return GestureDetector(
        onTap: () => _startEditingMessage(message, index),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 15,
                fontFamily: 'Times New Roman',
              ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAiResponseContent(
                isStreaming ? _currentStreamingText : message.text,
                themeProvider,
              ),
              if (!isStreaming) ...[
                const SizedBox(height: 12),
                _buildActionButtons(message.text, themeProvider, index),
              ],
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActionButtons(String messageText, ThemeProvider themeProvider, int messageIndex) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSvgActionButton('assets/icons/document.svg', () {
          Clipboard.setData(ClipboardData(text: messageText));
        }, themeProvider),
        const SizedBox(width: 12),
        _buildSvgActionButton('assets/icons/share.svg', () {
          Share.share(messageText);
        }, themeProvider),
        const SizedBox(width: 12),
        _buildSvgActionButton('assets/icons/refresh.svg', () {
          _regenerateMessage(messageIndex);
        }, themeProvider),
        const SizedBox(width: 12),
        _buildSvgActionButton('assets/icons/heart.svg', () {
          // Feedback positivo
        }, themeProvider),
        const SizedBox(width: 12),
        _buildSvgActionButton('assets/icons/close.svg', () {
          // Feedback negativo
        }, themeProvider),
      ],
    );
  }

  Widget _buildSvgActionButton(String svgPath, VoidCallback onTap, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        svgPath,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  void _startEditingMessage(ChatMessage message, int index) {
    setState(() {
      _editingMessage = message;
      _editingIndex = index;
      _messageController.text = message.text;
    });
    _focusNode.requestFocus();
  }

  void _cancelEditing() {
    setState(() {
      _editingMessage = null;
      _editingIndex = null;
      _messageController.clear();
    });
  }

  Future<void> _regenerateMessage(int aiMessageIndex) async {
    if (_isLoading) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (aiMessageIndex > 0) {
      final userMessage = chatProvider.currentMessages[aiMessageIndex - 1];
      if (userMessage.isUser) {
        chatProvider.currentMessages.removeAt(aiMessageIndex);
        await _sendMessage(userMessage.text, isRegeneration: true);
      }
    }
  }

  Widget _buildAiResponseContent(String text, ThemeProvider themeProvider) {
    if (text.contains('<!DOCTYPE html>') || text.contains('<html')) {
      return _buildDocumentInline(text, themeProvider);
    }

    // Detecta se é uma resposta importante para criar card especial
    if (_shouldCreateSpecialCard(text)) {
      return _buildSpecialCard(text, themeProvider);
    }

    return MessageFormatter.buildFormattedText(text, themeProvider);
  }

  bool _shouldCreateSpecialCard(String text) {
    // Critérios para card especial
    final hasTitle = text.startsWith('# ') || text.contains('\n# ');
    final hasMultipleSections = text.split('\n##').length > 2;
    final isLong = text.length > 500;

    return (hasTitle && hasMultipleSections) || isLong;
  }

  Widget _buildSpecialCard(String text, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeProvider.isDarkMode
              ? [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF1F1F1F),
                ]
              : [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFFFFFFF),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: const Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resposta Detalhada',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MessageFormatter.buildFormattedText(text, themeProvider),
        ],
      ),
    );
  }

  Widget _buildDocumentInline(String text, ThemeProvider themeProvider) {
    final htmlContent = _chatService.extractHtmlFromResponse(text);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '✅ Documento criado',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (htmlContent.isNotEmpty) {
                _downloadHtmlAsPdf(htmlContent);
                if (widget.onDocumentGenerated != null) {
                  widget.onDocumentGenerated!(htmlContent);
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SvgPicture.asset(
                'assets/icons/download.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  themeProvider.isDarkMode ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadHtmlAsPdf(String htmlContent) {
    if (!kIsWeb) {
      debugPrint('PDF download só está disponível na versão web');
      return;
    }

    final filename = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final safeHtml = Uri.encodeComponent(htmlContent);
    final script = '''
(function(){
  try {
    const html = decodeURIComponent('$safeHtml');
    const filename = '$filename';
    
    function ensureAndRender(cb) {
      let toLoad = 0;
      const onLoaded = () => { if(--toLoad === 0) cb(); };
      
      if(!window.jspdf) { 
        toLoad++; 
        const s = document.createElement('script'); 
        s.src='https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js'; 
        s.onload=onLoaded; 
        s.onerror=onLoaded; 
        document.head.appendChild(s); 
      }
      
      if(!window.html2canvas) { 
        toLoad++; 
        const s2 = document.createElement('script'); 
        s2.src='https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js'; 
        s2.onload=onLoaded; 
        s2.onerror=onLoaded; 
        document.head.appendChild(s2); 
      }
      
      if(toLoad===0) cb();
    }
    
    ensureAndRender(async function(){
      const { jsPDF } = window.jspdf || {};
      const html2canvas = window.html2canvas;
      
      if(!jsPDF || !html2canvas) { 
        console.error('libs missing'); 
        return; 
      }
      
      const container = document.createElement('div');
      container.style.cssText = 'position:absolute;left:-9999px;top:0;width:794px;background:#fff;padding:40px;box-sizing:border-box;';
      container.innerHTML = html;
      document.body.appendChild(container);
      
      await new Promise(r => setTimeout(r, 700));
      
      const canvas = await html2canvas(container, { 
        scale: 2, 
        useCORS: true, 
        backgroundColor: '#ffffff', 
        width: 794 
      });
      
      document.body.removeChild(container);
      
      const imgData = canvas.toDataURL('image/png', 1.0);
      const pdf = new jsPDF({ 
        orientation: 'portrait', 
        unit: 'px', 
        format: [794, 1123], 
        compress: true 
      });
      
      const pdfWidth = 794;
      const imgHeight = (canvas.height * pdfWidth) / canvas.width;
      let position = 0;
      let heightLeft = imgHeight;
      
      pdf.addImage(imgData, 'PNG', 0, position, pdfWidth, imgHeight, '', 'FAST');
      heightLeft -= 1123;
      
      while(heightLeft > 0) {
        position = heightLeft - imgHeight;
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', 0, position, pdfWidth, imgHeight, '', 'FAST');
        heightLeft -= 1123;
      }
      
      pdf.save(filename);
    });
  } catch (e) { 
    console.error(e); 
  }
})();
''';

    try {
      js_util.callMethod(js_util.globalThis, 'eval', [script]);
    } catch (e) {
      debugPrint('Erro ao executar script de download: $e');
    }
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
        isEditing: _editingMessage != null,
        onSend: (text) async {
          if (_editingMessage != null && _editingIndex != null) {
            await _handleEditMessage(text);
          } else {
            await _sendMessage(text);
          }
        },
        onCancelEdit: _cancelEditing,
      ),
    );
  }

  Future<void> _handleEditMessage(String newText) async {
    if (newText.trim().isEmpty) {
      _cancelEditing();
      return;
    }

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final messagesToKeep = chatProvider.currentMessages.sublist(0, _editingIndex!);

    chatProvider.currentMessages.clear();
    for (var msg in messagesToKeep) {
      chatProvider.addMessage(msg);
    }

    _cancelEditing();
    await _sendMessage(newText);
  }

  Future<void> _sendMessage(String text, {bool isRegeneration = false}) async {
    if (text.trim().isEmpty || _isLoading) return;
    if (!mounted) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (mounted && !isRegeneration) {
      setState(() {
        chatProvider.addMessage(ChatMessage(text: text.trim(), isUser: true));
        _isLoading = true;
      });
    } else if (isRegeneration) {
      setState(() {
        _isLoading = true;
      });
    }

    _scrollToBottom();

    try {
      final conversationHistory = chatProvider.buildMessageHistory();
      final limitedHistory = conversationHistory.length > 20 
          ? conversationHistory.sublist(conversationHistory.length - 20)
          : conversationHistory;

      final aiResponse = await _chatService.sendMessage(text, limitedHistory);

      if (mounted) {
        // Adiciona mensagem vazia primeiro
        chatProvider.addMessage(ChatMessage(text: '', isUser: false));

        setState(() {
          _isLoading = false;
          _isStreaming = true;
          _currentStreamingText = '';
        });

        // Anima o texto frase por frase
        await _animateText(aiResponse, chatProvider);

        if (aiResponse.contains('<!DOCTYPE html>') || aiResponse.contains('<html')) {
          final htmlContent = _chatService.extractHtmlFromResponse(aiResponse);
          if (htmlContent.isNotEmpty && widget.onDocumentGenerated != null) {
            widget.onDocumentGenerated!(htmlContent);
          }
        }
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
          _isStreaming = false;
        });
      }
    }

    _scrollToBottom();
  }

  Future<void> _animateText(String fullText, ChatProvider chatProvider) async {
    final words = fullText.split(' ');
    _currentStreamingText = '';

    for (int i = 0; i < words.length; i++) {
      if (!mounted || !_isStreaming) break;

      setState(() {
        _currentStreamingText += (i == 0 ? '' : ' ') + words[i];
      });

      // Atualiza a mensagem final
      if (chatProvider.currentMessages.isNotEmpty && 
          !chatProvider.currentMessages.last.isUser) {
        chatProvider.currentMessages.last = ChatMessage(
          text: _currentStreamingText,
          isUser: false,
        );
      }

      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 30));
    }

    if (mounted) {
      setState(() {
        _isStreaming = false;
      });
    }
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

// Tela de conversas (continua igual...)
class _ConversationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/menu.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      themeProvider.isDarkMode ? Colors.white : Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Conversas',
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/close.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.1),
            ),
            Expanded(
              child: chatProvider.conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/inbox.svg',
                            width: 48,
                            height: 48,
                            colorFilter: ColorFilter.mode(
                              themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma conversa',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
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
                                ? (themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5))
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
                                color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : const Color(0xFFE9ECEF),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/document.svg',
                                  width: 18,
                                  height: 18,
                                  colorFilter: ColorFilter.mode(
                                    themeProvider.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              conversation.title,
                              style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
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
                                Icons.more_horiz,
                                color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                size: 20,
                              ),
                              color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/close.svg',
                                        width: 18,
                                        height: 18,
                                        colorFilter: ColorFilter.mode(
                                          Colors.red.shade400,
                                          BlendMode.srcIn,
                                        ),
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
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir conversa',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
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