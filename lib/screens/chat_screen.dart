import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/loading_indicator.dart';
import 'settings_screen.dart';
import '../widgets/document_selector_modal.dart';
import 'options_modal.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasStarted = false;
  bool _isUserActive = true;
  String? _selectedDocument;
  bool _isModalOpen = false;

  late AnimationController _modalAnimationController;

  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _apiService.loadPreferences();
    
    _modalAnimationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  void _showOptionsModal() {
    setState(() {
      _isModalOpen = true;
    });
    _modalAnimationController.forward();
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _buildModalWithBackground(
        OptionsModal(
          onClose: () {
            _modalAnimationController.reverse();
            setState(() {
              _isModalOpen = false;
            });
            Navigator.pop(context);
          },
        ),
        height: 0.5,
      ),
    ).then((_) {
      setState(() {
        _isModalOpen = false;
      });
      _modalAnimationController.reverse();
    });
  }

  void _startConversation() {
    setState(() {
      _isModalOpen = true;
    });
    _modalAnimationController.forward();
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _buildModalWithBackground(
        DocumentSelectorModal(
          onDocumentSelected: (doc) {
            setState(() {
              _selectedDocument = doc;
              _hasStarted = true;
              _isModalOpen = false;
            });
            _modalAnimationController.reverse();
            Navigator.pop(context);
          },
        ),
        height: 0.6,
      ),
    ).then((_) {
      setState(() {
        _isModalOpen = false;
      });
      _modalAnimationController.reverse();
    });
  }

  Widget _buildModalWithBackground(Widget modal, {required double height}) {
    return Stack(
      children: [
        // Background escuro
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        // Modal
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * height,
            child: modal,
          ),
        ),
      ],
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

    return AnimatedBuilder(
      animation: _modalAnimationController,
      builder: (context, child) {
        final scale = 1.0 - (_modalAnimationController.value * 0.08);
        final borderRadius = _modalAnimationController.value * 12.0;
        
        return Transform.scale(
          scale: scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CupertinoPageScaffold(
              backgroundColor: themeProvider.backgroundColor,
              navigationBar: CupertinoNavigationBar(
                backgroundColor: themeProvider.navigationBarColor,
                border: Border(
                  bottom: BorderSide(
                    color: themeProvider.borderColor,
                    width: 0.5,
                  ),
                ),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.ellipsis_circle,
                    color: themeProvider.primaryColor,
                    size: 28,
                  ),
                  onPressed: _showOptionsModal,
                ),
                middle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NovaSignal',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isUserActive ? const Color(0xFF34C759) : CupertinoColors.systemGrey,
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
                        fullscreenDialog: true,
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
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
                                  maxLines: null,
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _isLoading
                                        ? CupertinoColors.systemGrey
                                        : themeProvider.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.paperplane_fill,
                                    color: CupertinoColors.white,
                                    size: 16,
                                  ),
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
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _modalAnimationController.dispose();
    super.dispose();
  }
}