// lib/tabs/chat_tab.dart
import 'dart:convert';
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_input.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/message_formatter.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:math' as math;

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

    // Fundo principal — apenas preto ou branco
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
                      color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Ionicons.menu_outline,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
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
                      color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Ionicons.add_outline,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
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
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 16),
          Text(
            'Comece uma conversa',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envie uma mensagem para iniciar',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
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
        return _buildMessageBubble(
          chatProvider.currentMessages[index],
          themeProvider,
          index,
        );
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

  Widget _buildMessageBubble(ChatMessage message, ThemeProvider themeProvider, int index) {
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
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: themeProvider.isDarkMode
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
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
              _buildAiResponseContent(message.text, themeProvider),
              const SizedBox(height: 12),
              _buildActionButtons(message.text, themeProvider, index),
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
        _buildActionButton(
          icon: Ionicons.copy_outline,
          onTap: () {
            Clipboard.setData(ClipboardData(text: messageText));
          },
          themeProvider: themeProvider,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Ionicons.share_outline,
          onTap: () {
            Share.share(messageText);
          },
          themeProvider: themeProvider,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Ionicons.reload_outline,
          onTap: () => _regenerateMessage(messageIndex),
          themeProvider: themeProvider,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Ionicons.thumbs_up_outline,
          onTap: () {
            // Implementar feedback positivo
          },
          themeProvider: themeProvider,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Ionicons.thumbs_down_outline,
          onTap: () {
            // Implementar feedback negativo
          },
          themeProvider: themeProvider,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 20,
        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
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

    // Encontra a mensagem do usuário anterior à resposta da IA
    if (aiMessageIndex > 0) {
      final userMessage = chatProvider.currentMessages[aiMessageIndex - 1];
      if (userMessage.isUser) {
        // Remove a resposta antiga da IA
        chatProvider.currentMessages.removeAt(aiMessageIndex);

        // Reenvia a mensagem do usuário
        await _sendMessage(userMessage.text, isRegeneration: true);
      }
    }
  }

  Widget _buildAiResponseContent(String text, ThemeProvider themeProvider) {
    // Se for HTML, mostramos uma resposta simples com emoji e ícone de download
    if (text.contains('<!DOCTYPE html>') || text.contains('<html')) {
      return _buildDocumentInline(text, themeProvider);
    }

    // Para texto normal, usamos o formatter habitual
    return MessageFormatter.buildFormattedText(text, themeProvider);
  }

  Widget _buildDocumentInline(String text, ThemeProvider themeProvider) {
    // Extrai o HTML limpo (caso o serviço tenha prefixos)
    final htmlContent = _chatService.extractHtmlFromResponse(text);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Texto simples: emoji de check + mensagem
          Expanded(
            child: Text(
              '✅ Documento criado',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Download: sempre visível — chama conversão HTML→PDF e força download no browser
          GestureDetector(
            onTap: () {
              if (htmlContent.isNotEmpty) {
                _downloadHtmlAsPdf(htmlContent);
                // Notifica também o callback externo caso necessário
                if (widget.onDocumentGenerated != null) {
                  widget.onDocumentGenerated!(htmlContent);
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Ionicons.download_outline,
                size: 22,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Converte HTML para PDF no browser (usando jsPDF + html2canvas) e força
  /// o download. O script injeta as libs se necessário.
  void _downloadHtmlAsPdf(String htmlContent) {
    final filename = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final safeHtml = jsonEncode(htmlContent); // garante escaping correto
    final safeFilename = jsonEncode(filename);

    final script = '''
(function(){
  const htmlContent = $safeHtml;
  const filename = $safeFilename;

  function ensureLibsAndRun(cb){
    let toLoad = 0;
    const onLoaded = () => { if(--toLoad === 0) cb(); };

    if(!window.jspdf){
      toLoad++;
      const s = document.createElement('script');
      s.src = 'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js';
      s.async = true;
      s.onload = onLoaded;
      s.onerror = onLoaded;
      document.head.appendChild(s);
    }
    if(!window.html2canvas){
      toLoad++;
      const s2 = document.createElement('script');
      s2.src = 'https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js';
      s2.async = true;
      s2.onload = onLoaded;
      s2.onerror = onLoaded;
      document.head.appendChild(s2);
    }
    if(toLoad === 0) cb();
  }

  ensureLibsAndRun(async function(){
    try {
      const { jsPDF } = window.jspdf || {};
      const html2canvas = window.html2canvas;
      if(!jsPDF || !html2canvas){
        console.error('Bibliotecas jspdf/html2canvas não estão disponíveis.');
        return;
      }

      const container = document.createElement('div');
      container.style.cssText = 'position:absolute;left:-9999px;top:0;width:794px;background:#ffffff;padding:40px;box-sizing:border-box;';
      container.innerHTML = htmlContent;
      document.body.appendChild(container);

      // Espera um pouco para o layout estabilizar
      await new Promise(r => setTimeout(r, 800));

      const canvas = await html2canvas(container, {
        scale: 2,
        useCORS: true,
        backgroundColor: '#ffffff',
        width: 794,
        logging: false
      });

      document.body.removeChild(container);

      const imgData = canvas.toDataURL('image/png', 1.0);
      const pdfWidth = 794;
      const imgHeight = (canvas.height * pdfWidth) / canvas.width;
      const pdfPageHeight = 1123;

      const pdf = new jsPDF({
        orientation: 'portrait',
        unit: 'px',
        format: [pdfWidth, pdfPageHeight],
        compress: true
      });

      let position = 0;
      let heightLeft = imgHeight;

      pdf.addImage(imgData, 'PNG', 0, position, pdfWidth, imgHeight, '', 'FAST');
      heightLeft -= pdfPageHeight;

      while (heightLeft > 0) {
        position = heightLeft - imgHeight;
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', 0, position, pdfWidth, imgHeight, '', 'FAST');
        heightLeft -= pdfPageHeight;
      }

      // Aciona download
      pdf.save(filename);

    } catch (err) {
      console.error('Erro ao converter/baixar PDF:', err);
    }
  });
})();
''';

    try {
      js.context.callMethod('eval', [script]);
    } catch (e) {
      debugPrint('Erro ao executar script de download: $e');
    }
  }

  Future<void> _handleEditMessage(String newText) async {
    if (newText.trim().isEmpty) {
      _cancelEditing();
      return;
    }

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Remove mensagens após a editada
    final messagesToKeep = chatProvider.currentMessages.sublist(0, _editingIndex!);

    chatProvider.currentMessages.clear();
    for (var msg in messagesToKeep) {
      chatProvider.addMessage(msg);
    }

    _cancelEditing();

    // Reenvia a mensagem editada
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
      final aiResponse = await _chatService.sendMessage(
        text,
        chatProvider.buildMessageHistory(),
      );

      if (mounted) {
        setState(() {
          chatProvider.addMessage(ChatMessage(text: aiResponse, isUser: false));
          _isLoading = false;
        });

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
        });
      }
    }

    _scrollToBottom();
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

// Tela de conversas (mantida igual, mas com fundo preto/branco)
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
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    size: 24,
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
                    icon: Icon(
                      Ionicons.close_outline,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
            ),
            Expanded(
              child: chat_provider_list_builder(themeProvider, chatProvider),
            ),
          ],
        ),
      ),
    );
  }

  // Small helper to keep ListView builder code readable (same behavior as antes)
  Widget chat_provider_list_builder(ThemeProvider themeProvider, ChatProvider chatProvider) {
    if (chatProvider.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.file_tray_outline,
              size: 48,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma conversa',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.conversations.length,
      itemBuilder: (context, index) {
        final conversation = chatProvider.conversations[index];
        final isSelected = chatProvider.currentConversation?.id == conversation.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA))
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
                color: themeProvider.isDarkMode ? Colors.black : const Color(0xFFE9ECEF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.chatbubble_outline,
                size: 18,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
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
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 13,
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Ionicons.ellipsis_horizontal,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
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
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
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
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
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