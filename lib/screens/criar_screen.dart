import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

// SVGs inline
const _docOutline = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18,2H9.828A3.977,3.977,0,0,0,7,3.172L2.172,8A3.977,3.977,0,0,0,1,10.828V20a3,3,0,0,0,3,3H18a3,3,0,0,0,3-3V5A3,3,0,0,0,18,2ZM7,5.414V8H4.414ZM19,20a1,1,0,0,1-1,1H4a1,1,0,0,1-1-1V10H8A1,1,0,0,0,9,9V3h9a1,1,0,0,1,1,1ZM13,17H8a1,1,0,0,1,0-2h5a1,1,0,0,1,0,2Zm3-4H8a1,1,0,0,1,0-2h8a1,1,0,0,1,0,2Z"/>
</svg>
''';

const _slidesSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M19,3H5C3.9,3,3,3.9,3,5v14c0,1.1.9,2,2,2h14c1.1,0,2-.9,2-2V5C21,3.9,20.1,3,19,3Zm0,16H5V5h14Zm-7-8L8,17h8Z"/>
</svg>
''';

const _tableSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M19,3H5C3.9,3,3,3.9,3,5v14c0,1.1.9,2,2,2h14c1.1,0,2-.9,2-2V5C21,3.9,20.1,3,19,3Zm0,16H5V5h14ZM7,10h2v7H7Zm4-3h2v10H11Zm4,6h2v4H15Z"/>
</svg>
''';

const _chevronSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M9,19a1,1,0,0,1-.707-1.707L13.586,12,8.293,6.707A1,1,0,0,1,9.707,5.293l6,6a1,1,0,0,1,0,1.414l-6,6A1,1,0,0,1,9,19Z"/>
</svg>
''';

Widget _svg(String d, Color c, {double s = 22}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

class CriarScreen extends StatefulWidget {
  final VoidCallback? onDocCreated;
  const CriarScreen({super.key, this.onDocCreated});
  @override
  State<CriarScreen> createState() => _CriarScreenState();
}

class _CriarScreenState extends State<CriarScreen> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark      = themeNotifier.isDark;
    final bg          = isDark ? AppColors.darkBackground    : AppColors.background;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor    = isDark ? AppColors.darkDivider       : AppColors.divider;
    final acc         = accColor(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Text('ESCOLHE UM TIPO',
              style: GoogleFonts.syne(
                color: textSec, fontSize: 11,
                fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          ),
          _Item(
            svg: _docOutline, acc: acc, isDark: isDark,
            title: 'Documento', subtitle: 'Texto com formatação rica',
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditorScreen()));
              widget.onDocCreated?.call();
            },
          ),
          _Item(
            svg: _slidesSvg, acc: acc, isDark: isDark,
            title: 'Apresentação', subtitle: 'Em breve', disabled: true,
          ),
          _Item(
            svg: _tableSvg, acc: acc, isDark: isDark,
            title: 'Folha de cálculo', subtitle: 'Em breve', disabled: true,
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String svg;
  final Color acc;
  final bool isDark;
  final String title;
  final String subtitle;
  final bool disabled;
  final VoidCallback? onTap;

  const _Item({
    required this.svg, required this.acc, required this.isDark,
    required this.title, required this.subtitle,
    this.disabled = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg          = isDark ? AppColors.darkBackground    : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor    = isDark ? AppColors.darkDivider       : AppColors.divider;

    final iconColor = disabled ? textSec : acc;
    final iconBg    = disabled
        ? (isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5))
        : acc.withOpacity(.1);

    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: bg,
            border: Border(bottom: BorderSide(color: divColor, width: 0.5)),
          ),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(13)),
              child: Center(child: _svg(svg, iconColor, s: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                style: GoogleFonts.syne(
                  color: textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 3),
              Text(subtitle,
                style: GoogleFonts.syne(color: textSec, fontSize: 13)),
            ])),
            if (!disabled) _svg(_chevronSvg, textSec, s: 18),
          ]),
        ),
      ),
    );
  }
}
