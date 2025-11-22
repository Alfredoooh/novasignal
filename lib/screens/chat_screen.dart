import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../services/api_service.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/loading_indicator.dart';
import 'settings_screen.dart';
import 'document_selector_modal.dart';
import 'options_modal.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasStarted = false;
  bool _isUserActive = true;
  String? _selectedDocument;

  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _apiService.loadPreferences();
  }

  void _showOptionsModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => OptionsModal(
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _startConversation() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => DocumentSelectorModal(
        onDocumentSelected: (doc) {
          setState(() {
            _selectedDocument = doc;
            _hasStarted = true;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isLoading) return;

    final messageText = _controller.text.trim();
    final userMessage = Message(role: 'user', content: messageText);

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _apiService.sendMessage(_messages);
      setState(() {
        _messages.add(response);
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          role: 'error',
          content: 'Erro: ${e.toString()}',
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  void _clearChat() {
    if (_messages.isEmpty) return;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(themeProvider.translate('clear_chat')),
        content: Text(themeProvider.translate('clear_message')),
        actions: [
          CupertinoDialogAction(
            child: Text(themeProvider.translate('cancel')),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(themeProvider.translate('clear')),
            onPressed: () {
              setState(() {
                _messages.clear();
                _hasStarted = false;
                _selectedDocument = null;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: themeProvider.navigationBarColor,
        border: Border(
          bottom: BorderSide(
            color: themeProvider.borderColor,
            width: 0.5,
          ),
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de menu popup
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.ellipsis_circle,
                color: themeProvider.primaryColor,
                size: 28,
              ),
              onPressed: _showOptionsModal,
            ),
          ],
        ),
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NovaSignal',
              style: TextStyle(color: themeProvider.textColor),
            ),
            const SizedBox(width: 8),
            // Indicador de status online
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isUserActive ? const Color(0xFF34C759) : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.settings,
            color: themeProvider.primaryColor,
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => SettingsScreen(apiService: _apiService),
              ),
            );
            setState(() {});
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: !_hasStarted
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: themeProvider.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.chat_bubble_2_fill,
                              color: CupertinoColors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            themeProvider.translate('welcome'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            themeProvider.translate('start_conversation'),
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          CupertinoButton.filled(
                            onPressed: _startConversation,
                            child: Text(themeProvider.translate('start')),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isLoading) {
                          return LoadingIndicator(
                            backgroundColor: themeProvider.secondaryBackground,
                          );
                        }
                        return MessageBubble(
                          message: _messages[index],
                          primaryColor: themeProvider.primaryColor,
                          secondaryBackground: themeProvider.secondaryBackground,
                        );
                      },
                    ),
            ),
            if (_hasStarted)
              Container(
                decoration: BoxDecoration(
                  color: themeProvider.navigationBarColor,
                  border: Border(
                    top: BorderSide(
                      color: themeProvider.borderColor,
                      width: 0.5,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: themeProvider.secondaryBackground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _controller,
                          placeholder: themeProvider.translate('message'),
                          placeholderStyle: const TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontSize: 16,
                          ),
                          decoration: const BoxDecoration(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onSubmitted: (_) => _sendMessage(),
                          enabled: !_isLoading,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          CupertinoIcons.paperplane_fill,
                          color: _isLoading
                              ? CupertinoColors.systemGrey
                              : themeProvider.primaryColor,
                        ),
                        onPressed: _isLoading ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}