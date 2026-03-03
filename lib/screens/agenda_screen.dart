import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../widgets/theme.dart';

const String _agendaVaziaSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m15.561,13.561l-1.439,1.439,1.439,1.439c.586.586.586,1.535,0,2.121-.293.293-.677.439-1.061.439s-.768-.146-1.061-.439l-1.439-1.439-1.439,1.439c-.293.293-.677.439-1.061.439s-.768-.146-1.061-.439c-.586-.586-.586-1.535,0-2.121l1.439-1.439-1.439-1.439c-.586-.586-.586-1.535,0-2.121s1.535-.586,2.121,0l1.439,1.439,1.439-1.439c.586-.586,1.535-.586,2.121,0s.586,1.535,0,2.121Zm8.439-6.061v11c0,3.032-2.467,5.5-5.5,5.5H5.5c-3.033,0-5.5-2.468-5.5-5.5V7.5C0,4.468,2.467,2,5.5,2h.5v-.5c0-.828.671-1.5,1.5-1.5s1.5.672,1.5,1.5v.5h6v-.5c0-.828.671-1.5,1.5-1.5s1.5.672,1.5,1.5v.5h.5c3.033,0,5.5,2.468,5.5,5.5Zm-3,11v-9.5H3v9.5c0,1.379,1.122,2.5,2.5,2.5h13c1.378,0,2.5-1.121,2.5-2.5Z"/>
</svg>
''';
const String _hojeOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18.5,2h-.5v-.5c0-.829-.672-1.5-1.5-1.5s-1.5,.671-1.5,1.5v.5h-6v-.5c0-.829-.672-1.5-1.5-1.5s-1.5,.671-1.5,1.5v.5h-.5C2.468,2,0,4.467,0,7.5v11c0,3.033,2.468,5.5,5.5,5.5h13c3.032,0,5.5-2.467,5.5-5.5V7.5c0-3.033-2.468-5.5-5.5-5.5Zm0,19H5.5c-1.379,0-2.5-1.122-2.5-2.5V9H21v9.5c0,1.378-1.121,2.5-2.5,2.5Zm-.655-9.026c.566,.604,.535,1.554-.069,2.12l-4.176,3.914c-.626,.627-1.505,.992-2.439,.992s-1.814-.364-2.476-1.026l-2.478-2.396c-.596-.576-.611-1.525-.035-2.121,.576-.594,1.526-.61,2.121-.035l2.496,2.414c.146,.145,.294,.164,.371,.164s.226-.019,.354-.146l4.211-3.948c.604-.567,1.552-.536,2.12,.068Z"/>
</svg>
''';
const String _arrowLeftSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M21,11H4.414l3.293-3.293c.391-.391.391-1.023,0-1.414-.391-.391-1.023-.391-1.414,0l-5,5c-.391.391-.391,1.023,0,1.414l5,5c.195.195.451.293.707.293s.512-.098.707-.293c.391-.391.391-1.023,0-1.414l-3.293-3.293H21c.552,0,1-.448,1-1s-.448-1-1-1Z"/>
</svg>
''';
const String _maisOpcoesSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m12,0C5.383,0,0,5.383,0,12s5.383,12,12,12,12-5.383,12-12S18.617,0,12,0Zm0,22c-5.514,0-10-4.486-10-10S6.486,2,12,2s10,4.486,10,10-4.486,10-10,10Zm-4-10c0,.828-.672,1.5-1.5,1.5s-1.5-.672-1.5-1.5.672-1.5,1.5-1.5,1.5.672,1.5,1.5Zm11,0c0,.828-.672,1.5-1.5,1.5s-1.5-.672-1.5-1.5.672-1.5,1.5-1.5,1.5.672,1.5,1.5Zm-5.5,0c0,.828-.672,1.5-1.5,1.5s-1.5-.672-1.5-1.5.672-1.5,1.5-1.5,1.5.672,1.5,1.5Z"/>
</svg>
''';

Widget _svg(String data, Color color, {double size = 22}) =>
  SvgPicture.string(data, width: size, height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn));

class _AgendaAppBarActions extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  const _AgendaAppBarActions({required this.isDark, required this.textPrimary});

  void _showPopup(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    // 5% mais escuro que darkSurface/background
    final surfaceBg = isDark ? const Color(0xFF222222) : const Color(0xFFF2F2F2);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    await showMenu<String>(
      context: context,
      position: position,
      color: surfaceBg,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      popUpAnimationStyle: AnimationStyle(
        curve: Curves.easeOutQuart,
        duration: const Duration(milliseconds: 300),
        reverseCurve: Curves.easeInQuart,
        reverseDuration: const Duration(milliseconds: 200),
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'novo',
          child: Row(children: [
            Icon(Icons.add_rounded, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text('Novo evento', style: TextStyle(color: textColor, fontSize: 15)),
          ]),
        ),
        PopupMenuItem<String>(
          value: 'filtrar',
          child: Row(children: [
            Icon(Icons.filter_list_rounded, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text('Filtrar', style: TextStyle(color: textColor, fontSize: 15)),
          ]),
        ),
        PopupMenuItem<String>(
          value: 'semana',
          child: Row(children: [
            Icon(Icons.view_week_outlined, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text('Ver semana', style: TextStyle(color: textColor, fontSize: 15)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'definicoes',
          child: Row(children: [
            Icon(Icons.settings_outlined, color: textSecondary, size: 20),
            const SizedBox(width: 12),
            Text('Definições', style: TextStyle(color: textSecondary, fontSize: 15)),
          ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botão ir para hoje
        IconButton(
          icon: _svg(_hojeOutlineSvg, textPrimary, size: 22),
          onPressed: () {
            // navegar para hoje — a AgendaPage trata via GlobalKey se necessário
          },
        ),
        // Botão popup menu
        Builder(
          builder: (ctx) => IconButton(
            icon: _svg(_maisOpcoesSvg, textPrimary, size: 22),
            onPressed: () => _showPopup(ctx),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DRAWER
// ─────────────────────────────────────────────

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});
  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  late AnimationController _springCtrl;
  late Animation<double> _springScaleX;

  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;
  bool _expanded = false;

  static const List<String> _dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  List<List<DateTime?>> get _allWeeks {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final offset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
    final cells = ((offset + daysInMonth) / 7).ceil() * 7;
    final allDays = List.generate(cells, (i) {
      final d = i - offset + 1;
      if (d < 1 || d > daysInMonth) return null;
      return DateTime(_selectedDate.year, _selectedDate.month, d);
    });
    return List.generate(allDays.length ~/ 7, (r) => allDays.sublist(r * 7, r * 7 + 7));
  }

  int get _selectedWeekIndex {
    final weeks = _allWeeks;
    for (int r = 0; r < weeks.length; r++) {
      if (weeks[r].any((d) => d != null && _isSameDay(d!, _selectedDate))) return r;
    }
    return 0;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _springScaleX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.88).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 35),
    ]).animate(_springCtrl);

    _expandCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    _expandCtrl.dispose();
    super.dispose();
  }

  void _selectDate(DateTime date) {
    if (_isSameDay(date, _selectedDate)) return;
    setState(() => _selectedDate = date);
    _springCtrl.forward(from: 0);
    if (_expanded) {
      _expandCtrl.reverse().then((_) => setState(() => _expanded = false));
    }
  }

  void _toggleExpand() {
    if (_expanded) {
      _expandCtrl.reverse().then((_) => setState(() => _expanded = false));
    } else {
      setState(() => _expanded = true);
      _expandCtrl.forward();
    }
  }

  Widget _buildDayCell(DateTime? date, {bool showLabel = false, int labelIndex = 0,
      required Color textPrimary, required Color textSecondary, required bool isDark}) {
    final isSelected = date != null && _isSameDay(date, _selectedDate);

    return GestureDetector(
      onTap: date != null ? () => _selectDate(date) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              showLabel ? _dayLabels[labelIndex] : '',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.darkBackground : AppColors.background)
                    : textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedBuilder(
              animation: _springScaleX,
              builder: (ctx, child) => Transform.scale(
                scaleX: isSelected ? _springScaleX.value : 1.0,
                child: child,
              ),
              child: Text(
                date != null ? '${date.day}' : '',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (isDark ? AppColors.darkBackground : AppColors.background)
                      : textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    final allWeeks = _allWeeks;
    final selectedWeek = allWeeks[_selectedWeekIndex];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: _svg(_arrowLeftSvg, textPrimary, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Agenda',
          style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [_AgendaAppBarActions(isDark: isDark, textPrimary: textPrimary)],
      ),
      body: Column(
        children: [
          GestureDetector(
            onVerticalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v > 80 && !_expanded) _toggleExpand();
              if (v < -80 && _expanded) _toggleExpand();
            },
            child: Container(
              color: bg,
              child: Column(
                children: [
                  // Strip semanal
                  if (!_expanded || _expandCtrl.value < 1.0)
                    SizeTransition(
                      sizeFactor: Tween(begin: 1.0, end: 0.0).animate(_expandAnim),
                      axisAlignment: -1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (i) => _buildDayCell(
                            selectedWeek[i],
                            showLabel: true,
                            labelIndex: i,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            isDark: isDark,
                          )),
                        ),
                      ),
                    ),

                  // Calendário completo expandido
                  SizeTransition(
                    sizeFactor: _expandAnim,
                    axisAlignment: -1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Column(
                        children: List.generate(allWeeks.length, (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (i) => _buildDayCell(
                              allWeeks[r][i],
                              showLabel: r == 0,
                              labelIndex: i,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              isDark: isDark,
                            )),
                          ),
                        )),
                      ),
                    ),
                  ),

                  Divider(height: 1, color: divider),
                ],
              ),
            ),
          ),

          // Estado vazio
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: _svg(_agendaVaziaSvg, const Color(0xFFFF3B30), size: 38)),
                  ),
                  const SizedBox(height: 18),
                  Text('Sem nada agendado',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 6),
                  Text('Não há eventos para este dia.',
                      style: TextStyle(fontSize: 14, color: textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
