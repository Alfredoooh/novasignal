// lib/widgets/chat_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../screens/user_screen.dart';
import '../screens/storage_screen.dart';
import 'package:ionicons/ionicons.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Drawer(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF212529) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(themeProvider, context),
            const SizedBox(height: 8),
            Expanded(
              child: chatProvider.conversations.isEmpty
                  ? _buildEmptyState(themeProvider)
                  : _buildConversationList(themeProvider, chatProvider, context),
            ),
            _buildBottomNavigation(themeProvider, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'DocuGen',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Ionicons.add_circle_outline,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
              size: 24,
            ),
            onPressed: () {
              chatProvider.createNewConversation();
              Navigator.pop(context);
            },
            tooltip: 'Nova conversa',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.chatbubbles_outline,
            size: 48,
            color: themeProvider.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma conversa',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(ThemeProvider themeProvider, ChatProvider chatProvider, BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: chatProvider.conversations.length,
      itemBuilder: (context, index) {
        final conversation = chatProvider.conversations[index];
        final isSelected = chatProvider.currentConversation?.id == conversation.id;

        return Material(
          color: isSelected
              ? (themeProvider.isDarkMode ? const Color(0xFF343A40) : const Color(0xFFF0F0F0))
              : Colors.transparent,
          child: InkWell(
            onTap: () {
              chatProvider.switchConversation(conversation.id);
              Navigator.pop(context);
            },
            hoverColor: themeProvider.isDarkMode ? const Color(0xFF2C3237) : const Color(0xFFF8F9FA),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                conversation.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTimestamp(conversation.lastUpdated),
                              style: TextStyle(
                                fontSize: 12,
                                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          conversation.messages.isNotEmpty 
                              ? conversation.messages.last.text 
                              : 'Nova conversa',
                          style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Ionicons.ellipsis_horizontal,
                      color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      size: 20,
                    ),
                    color: themeProvider.isDarkMode ? const Color(0xFF343A40) : Colors.white,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(ThemeProvider themeProvider, BuildContext context) {
    final bottomBgColor = themeProvider.isDarkMode ? const Color(0xFF1A1D20) : const Color(0xFFF8F9FA);
    final dividerColor = themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    final iconColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529);

    return Container(
      decoration: BoxDecoration(
        color: bottomBgColor,
        border: Border(
          top: BorderSide(
            color: dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Botão de Usuário
          IconButton(
            icon: Icon(
              Ionicons.person_outline,
              color: iconColor,
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserScreen(isDarkMode: themeProvider.isDarkMode),
                ),
              );
            },
            tooltip: 'Perfil',
            splashRadius: 24,
          ),
          // Botão de Armazenamento
          IconButton(
            icon: Icon(
              Ionicons.folder_outline,
              color: iconColor,
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StorageScreen(isDarkMode: themeProvider.isDarkMode),
                ),
              );
            },
            tooltip: 'Armazenamento',
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showDeleteDialog(BuildContext context, ThemeProvider themeProvider, ChatProvider chatProvider, String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF343A40) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir conversa',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
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