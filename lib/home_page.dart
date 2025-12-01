import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'tas/chat_tab.dart';
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
      backgroundColor: const Color(0xFFF5F5F5),
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
            color: const Color(0xFF007AFF),
            iconSize: 28,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Ionicons.settings_outline),
            color: const Color(0xFF007AFF),
            iconSize: 28,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 0),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: _selectedIndex == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            'Chat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: _selectedIndex == 0
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 1),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: _selectedIndex == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: _selectedIndex == 1
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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