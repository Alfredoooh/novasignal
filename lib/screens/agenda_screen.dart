import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/theme.dart';

const _backSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M.88,14.09,4.75,18a1,1,0,0,0,1.42,0h0a1,1,0,0,0,0-1.42L2.61,13H23a1,1,0,0,0,1-1h0a1,1,0,0,0-1-1H2.55L6.17,7.38A1,1,0,0,0,6.17,6h0A1,1,0,0,0,4.75,6L.88,9.85A3,3,0,0,0,.88,14.09Z"/></svg>';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});
  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaEvent {
  final String title;
  final String time;
  final String? location;
  final Color color;
  _AgendaEvent({required this.title, required this.time, this.location, required this.color});
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _selectedDay = DateTime.now();
  final Map<String, List<_AgendaEvent>> _events = {};
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _timeCtrl  = TextEditingController();
  final TextEditingController _locCtrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    _titleCtrl.dispose();
    _timeCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  void _onTheme() => setState(() {});

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  List<_AgendaEvent> get _todayEvents => _events[_dayKey(_selectedDay)] ?? [];

  void _addEvent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddEventSheet(
        onAdd: (title, time, loc) {
          final key = _dayKey(_selectedDay);
          final colors = [
            const Color(0xFF2563EB), const Color(0xFF16A34A),
            const Color(0xFFEA580C), const Color(0xFF9333EA),
          ];
          final ev = _AgendaEvent(
            title: title, time: time, location: loc.isEmpty ? null : loc,
            color: colors[(_events[key]?.length ?? 0) % colors.length],
          );
          setState(() {
            _events[key] = [...(_events[key] ?? []), ev];
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg  = isDark ? AppColors.darkBackground    : AppColors.background;
    final tp  = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final ts  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final div = isDark ? AppColors.darkDivider       : AppColors.divider;
    final acc = accColor(isDark);

    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay  = DateTime(now.year, now.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.string(_backSvg,
              width: 20, height: 20,
              colorFilter: ColorFilter.mode(tp, BlendMode.srcIn)),
        ),
        title: Text('Agenda',
            style: GoogleFonts.roboto(
                color: tp, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: _addEvent,
            icon: Icon(Icons.add_rounded, color: acc),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: div),
        ),
      ),
      body: Column(children: [
        // ── Mini calendar ──
        Container(
          color: isDark ? AppColors.darkSurface : const Color(0xFFF9FAFB),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                DateFormat('MMMM yyyy', 'pt').format(DateTime(now.year, now.month)),
                style: GoogleFonts.roboto(
                    color: tp, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ]),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['D','S','T','Q','Q','S','S'].map((d) =>
                SizedBox(width: 36, child: Text(d,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(color: ts, fontSize: 11, fontWeight: FontWeight.w600))
                ),
              ).toList(),
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 0,
                childAspectRatio: 1,
              ),
              itemCount: startWeekday + lastDay.day,
              itemBuilder: (ctx, idx) {
                if (idx < startWeekday) return const SizedBox();
                final day = idx - startWeekday + 1;
                final date = DateTime(now.year, now.month, day);
                final isSelected = _dayKey(date) == _dayKey(_selectedDay);
                final isToday = _dayKey(date) == _dayKey(now);
                final hasEvent = (_events[_dayKey(date)] ?? []).isNotEmpty;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = date),
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isSelected ? acc : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(alignment: Alignment.center, children: [
                      Text('$day',
                          style: GoogleFonts.roboto(
                              color: isSelected ? Colors.white
                                   : isToday ? acc : tp,
                              fontSize: 13,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
                      if (hasEvent && !isSelected)
                        Positioned(
                          bottom: 3,
                          child: Container(
                            width: 4, height: 4,
                            decoration: BoxDecoration(color: acc, shape: BoxShape.circle),
                          ),
                        ),
                    ]),
                  ),
                );
              },
            ),
          ]),
        ),
        Container(height: 0.5, color: div),
        // ── Event list ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(children: [
            Text(
              DateFormat('d MMMM', 'pt').format(_selectedDay),
              style: GoogleFonts.roboto(
                  color: tp, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
        Expanded(
          child: _todayEvents.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.event_note_rounded, size: 42, color: ts),
                  const SizedBox(height: 10),
                  Text('Sem eventos', style: GoogleFonts.roboto(color: ts, fontSize: 14)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _addEvent,
                    child: Text('+ Adicionar evento',
                        style: GoogleFonts.roboto(
                            color: acc, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _todayEvents.length,
                  itemBuilder: (ctx, i) {
                    final ev = _todayEvents[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ev.color.withOpacity(.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ev.color.withOpacity(.2)),
                      ),
                      child: Row(children: [
                        Container(width: 3, height: 40, color: ev.color,
                            margin: const EdgeInsets.only(right: 12)),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ev.title,
                                style: GoogleFonts.roboto(
                                    color: tp, fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text(ev.time, style: GoogleFonts.roboto(color: ts, fontSize: 12)),
                            if (ev.location != null) ...[
                              const SizedBox(height: 2),
                              Text(ev.location!, style: GoogleFonts.roboto(color: ts, fontSize: 12)),
                            ],
                          ],
                        )),
                      ]),
                    );
                  },
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        backgroundColor: acc,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _AddEventSheet extends StatefulWidget {
  final void Function(String title, String time, String loc) onAdd;
  const _AddEventSheet({required this.onAdd});
  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _titleCtrl = TextEditingController();
  final _timeCtrl  = TextEditingController(text: '09:00');
  final _locCtrl   = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose(); _timeCtrl.dispose(); _locCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg  = isDark ? AppColors.darkSurface    : Colors.white;
    final tp  = isDark ? AppColors.darkTextPrimary  : AppColors.textPrimary;
    final ts  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = accColor(isDark);

    return Container(
      decoration: BoxDecoration(
        color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20,
          MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(
            color: div, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text('Novo evento', style: GoogleFonts.roboto(
            color: tp, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _field(_titleCtrl, 'Título do evento', tp, ts, div),
        const SizedBox(height: 10),
        _field(_timeCtrl, 'Hora (ex: 14:30)', tp, ts, div),
        const SizedBox(height: 10),
        _field(_locCtrl, 'Local (opcional)', tp, ts, div),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: acc,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            onPressed: () {
              if (_titleCtrl.text.trim().isEmpty) return;
              widget.onAdd(_titleCtrl.text.trim(), _timeCtrl.text.trim(), _locCtrl.text.trim());
              Navigator.pop(context);
            },
            child: Text('Adicionar', style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, Color tp, Color ts, Color div) =>
    TextField(
      controller: ctrl,
      style: GoogleFonts.roboto(color: tp, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.roboto(color: ts, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: div),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accColor(themeNotifier.isDark), width: 1.5),
        ),
        filled: true,
        fillColor: themeNotifier.isDark ? AppColors.darkBackground : const Color(0xFFF9FAFB),
      ),
    );
}
