// lib/widgets/chat_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
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
            const SizedBox(height: 16),
            Expanded(
              child: chatProvider.conversations.isEmpty
                  ? _buildEmptyState(themeProvider)
                  : _buildConversationList(themeProvider, chatProvider, context),
            ),
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
          Icon(
            Ionicons.chatbubbles_outline,
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Conversas',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Ionicons.close_outline,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            ),
            onPressed: () => Navigator.pop(context),
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
            Ionicons.file_tray_outline,
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: chatProvider.conversations.length,
      itemBuilder: (context, index) {
        final conversation = chatProvider.conversations[index];
        final isSelected = chatProvider.currentConversation?.id == conversation.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (themeProvider.isDarkMode ? const Color(0xFF343A40) : const Color(0xFFF8F9FA))
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
                color: themeProvider.isDarkMode ? const Color(0xFF495057) : const Color(0xFFE9ECEF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.chatbubble_outline,
                size: 18,
                color: themeProvider.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
            ),
            title: Text(
              conversation.title,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
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