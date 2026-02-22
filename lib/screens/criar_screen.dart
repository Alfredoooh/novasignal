import 'package:flutter/material.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

class CriarScreen extends StatelessWidget {
  final VoidCallback? onDocCreated;
  const CriarScreen({super.key, this.onDocCreated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Criar',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0F0F0)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 10),
            child: Text(
              'ESCOLHE UM TIPO',
              style: TextStyle(
                fontFamily: 'Syne', fontWeight: FontWeight.w800,
                fontSize: 11, letterSpacing: 1.4,
                color: Color(0xFFBBBBBB),
              ),
            ),
          ),
          // Documento
          _CreateItem(
            icon: Icons.description_outlined,
            iconColor: AriaTheme.acc,
            iconBg: AriaTheme.acc.withOpacity(.1),
            title: 'Documento',
            subtitle: 'Texto com formatação rica',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditorScreen()),
              );
              onDocCreated?.call();
            },
          ),
          // Apresentação (em breve)
          _CreateItem(
            icon: Icons.slideshow_outlined,
            iconColor: const Color(0xFFCCCCCC),
            iconBg: const Color(0xFFF5F5F5),
            title: 'Apresentação',
            subtitle: 'Em breve',
            disabled: true,
          ),
          // Folha de cálculo (em breve)
          _CreateItem(
            icon: Icons.table_chart_outlined,
            iconColor: const Color(0xFFCCCCCC),
            iconBg: const Color(0xFFF5F5F5),
            title: 'Folha de cálculo',
            subtitle: 'Em breve',
            disabled: true,
          ),
        ],
      ),
    );
  }
}

class _CreateItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool disabled;
  final VoidCallback? onTap;

  const _CreateItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.35 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
          ),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                      style: TextStyle(
                        fontFamily: 'Syne', fontWeight: FontWeight.w700,
                        fontSize: 15, color: disabled ? const Color(0xFFAAAAAA) : const Color(0xFF111111),
                      )),
                    const SizedBox(height: 3),
                    Text(subtitle,
                      style: const TextStyle(fontFamily: 'Syne', fontSize: 12.5, color: Color(0xFFBBBBBB))),
                  ],
                ),
              ),
              if (!disabled)
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
