import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'tabs/chat_tab.dart';
import 'tabs/preview_tab.dart';

class DocuGenHomePage extends StatefulWidget {
  const DocuGenHomePage({Key? key}) : super(key: key);

  @override
  State<DocuGenHomePage> createState() => _DocuGenHomePageState();
}

class _DocuGenHomePageState extends State<DocuGenHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'DocuGen AI',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.cube_outline),
            color: const Color(0xFF2196F3),
            iconSize: 28,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Ionicons.settings_outline),
            color: const Color(0xFF2196F3),
            iconSize: 28,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 0
                            ? Colors.white
                            : const Color(0xFFF5F5F5),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Chat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _selectedIndex == 0
                              ? const Color(0xFF2196F3)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 1
                            ? Colors.white
                            : const Color(0xFFF5F5F5),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Preview',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _selectedIndex == 1
                              ? const Color(0xFF2196F3)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0 ? const ChatTab() : const PreviewTab(),
          ),
        ],
      ),
    );
  }
}