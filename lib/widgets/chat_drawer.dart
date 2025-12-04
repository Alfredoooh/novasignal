// lib/widgets/chat_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import 'package:ionicons/ionicons.dart';

class ChatDrawer extends StatefulWidget {
  const ChatDrawer({Key? key}) : super(key: key);

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> with SingleTickerProviderStateMixin {
  String _query = '';
  bool _isRefreshing = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List _filteredConversations(ChatProvider chatProvider) {
    if (_query.trim().isEmpty) return chatProvider.conversations;
    final q = _query.toLowerCase();
    return chatProvider.conversations.where((c) {
      return c.title.toLowerCase().contains(q) ||
          (c.lastMessage ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _onRefresh(ChatProvider chatProvider) async {
    setState(() => _isRefreshing = true);
    // se tiveres um método para recarregar do backend, chama aqui; caso contrário simula demora
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    // Drawer como full-screen row: painel esquerdo + scrim/transparente à direita
    return Drawer(
      backgroundColor: Colors.transparent, // permitimos ver a área por trás
      child: SafeArea(
        child: Row(
          children: [
            // Painel esquerdo (o "drawer" real)
            Container(
              width: MediaQuery.of(context).size.width * 0.82, // ocupa grande parte da largura (ainda é full-screen feel)
              height: double.infinity,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.6 : 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          Ionicons.chatbubbles_outline,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          size: 22,
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
                        // Novo / limpar / fechar
                        IconButton(
                          onPressed: () => chatProvider.createNewConversation(),
                          icon: Icon(Ionicons.add_outline, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Ionicons.close_outline, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                        ),
                      ],
                    ),
                  ),

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF161B22) : const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Ionicons.search, size: 18, color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _query = v),
                              style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Pesquisar conversas...',
                                hintStyle: TextStyle(
                                  color: themeProvider.isDarkMode ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(() => _query = ''),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(Ionicons.close_circle, size: 18, color: themeProvider.isDarkMode ? Colors.white54 : Colors.black45),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Lista dinâmica com pull-to-refresh e reorder/dismiss
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _onRefresh(chatProvider),
                      edgeOffset: 0,
                      child: _buildConversationListArea(themeProvider, chatProvider),
                    ),
                  ),
                ],
              ),
            ),

            // Scrim/transparente à direita — ao tocar fecha o drawer
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: themeProvider.isDarkMode
                      ? Colors.black.withOpacity(0.35) // scrim leve para dar profundidade (podes ajustar para mais transparente)
                      : Colors.black.withOpacity(0.18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationListArea(ThemeProvider themeProvider, ChatProvider chatProvider) {
    final items = _filteredConversations(chatProvider);
    if (items.isEmpty) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Ionicons.file_tray_outline, size: 48, color: themeProvider.isDarkMode ? Colors.white54 : Colors.black38),
              const SizedBox(height: 12),
              Text(
                'Nenhuma conversa encontrada',
                style: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    // Usamos ReorderableListView para permitir reordenar; cada item também é Dismissible (swipe para apagar)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {
          // Ajuste de índices conforme documentação do ReorderableListView
          if (newIndex > oldIndex) newIndex -= 1;
          chat_provider_reorder(chatProvider: chatProvider, oldIndex: oldIndex, newIndex: newIndex);
        },
        buildDefaultDragHandles: false,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final conv = items[index];
          final isSelected = chatProvider.currentConversation?.id == conv.id;

          return Dismissible(
            key: ValueKey(conv.id),
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              color: Colors.red.shade700,
              child: const Icon(Ionicons.trash, color: Colors.white),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red.shade700,
              child: const Icon(Ionicons.trash, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await _confirmDelete(context, themeProvider);
            },
            onDismissed: (_) {
              chatProvider.deleteConversation(conv.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (themeProvider.isDarkMode ? const Color(0xFF161B22) : const Color(0xFFF8F9FA))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF21262B) : const Color(0xFFE9ECEF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Ionicons.chatbubble_outline, size: 18, color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                ),
                title: Text(
                  conv.title,
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  conv.lastMessage ?? _formatDate(conv.lastUpdated),
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatShortDate(conv.lastUpdated),
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white54 : Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ReorderableDragStartListener(
                      index: index,
                      child: Icon(Ionicons.grip_vertical, size: 18, color: themeProvider.isDarkMode ? Colors.white54 : Colors.black38),
                    ),
                  ],
                ),
                onTap: () {
                  chatProvider.switchConversation(conv.id);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Rearranja também no provider: tenta trocar posições entre a lista original
  void chat_provider_reorder({required ChatProvider chatProvider, required int oldIndex, required int newIndex}) {
    try {
      final list = chatProvider.conversations;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      chatProvider.updateConversationsOrder(list); // assume que o provider tem este método; se não existir, apenas atualiza localmente
    } catch (e) {
      // Fallback: sem crash
      debugPrint('Erro ao reordenar conversas: $e');
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, ThemeProvider themeProvider) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF161B22) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Excluir conversa', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
        content: Text('Tem certeza que deseja excluir esta conversa?', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Excluir', style: TextStyle(color: Colors.red.shade400))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return '${diff.inDays} dias atrás';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} semanas atrás';
    return '${(diff.inDays / 30).floor()} meses atrás';
  }

  String _formatShortDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    return '${(diff.inDays / 30).floor()}m';
  }
}