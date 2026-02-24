import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/document_service.dart';
import '../widgets/theme.dart';

// ── SVGs ─────────────────────────────────────────────────────────────────────
const _backSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M.88,14.09,4.75,18a1,1,0,0,0,1.42,0h0a1,1,0,0,0,0-1.42L2.61,13H23a1,1,0,0,0,1-1h0a1,1,0,0,0-1-1H2.55L6.17,7.38A1,1,0,0,0,6.17,6h0A1,1,0,0,0,4.75,6L.88,9.85A3,3,0,0,0,.88,14.09Z"/></svg>';
const _prevSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M15.707,4.293a1,1,0,0,0-1.414,0l-7,7a1,1,0,0,0,0,1.414l7,7a1,1,0,0,0,1.414-1.414L9.414,12l6.293-6.293A1,1,0,0,0,15.707,4.293Z"/></svg>';
const _nextSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M8.293,19.707a1,1,0,0,0,1.414,0l7-7a1,1,0,0,0,0-1.414l-7-7A1,1,0,0,0,8.293,5.707L14.586,12l-6.293,6.293A1,1,0,0,0,8.293,19.707Z"/></svg>';

Widget _svgW(String d, Color c, {double s = 18}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ── Design Tokens ─────────────────────────────────────────────────────────────
const kPill   = 999.0;  // pill radius
const kCard   = 18.0;   // card radius
const kModal  = 20.0;   // modal top radius
const kChip   = 999.0;  // chip/tag radius

// ── Categorias ────────────────────────────────────────────────────────────────
enum _Cat { trabalho, reuniao, pessoal, saude, estudo, outro }
const _catLabel = { _Cat.trabalho:'Trabalho', _Cat.reuniao:'Reunião', _Cat.pessoal:'Pessoal', _Cat.saude:'Saúde', _Cat.estudo:'Estudo', _Cat.outro:'Outro' };
const _catColor = { _Cat.trabalho:Color(0xFF2563EB), _Cat.reuniao:Color(0xFF9333EA), _Cat.pessoal:Color(0xFF16A34A), _Cat.saude:Color(0xFFDC2626), _Cat.estudo:Color(0xFFEA580C), _Cat.outro:Color(0xFF6B7280) };
const _catIcon  = { _Cat.trabalho:Icons.work_outline_rounded, _Cat.reuniao:Icons.people_outline_rounded, _Cat.pessoal:Icons.person_outline_rounded, _Cat.saude:Icons.favorite_outline_rounded, _Cat.estudo:Icons.school_outlined, _Cat.outro:Icons.label_outline_rounded };

// ── Modelos ───────────────────────────────────────────────────────────────────
class _Event {
  final String id, title, startTime;
  final String? note, endTime, location;
  final _Cat category;
  final bool allDay;
  final int priority;
  _Event({required this.id, required this.title, required this.startTime, this.note, this.endTime, this.location, this.category=_Cat.trabalho, this.allDay=false, this.priority=2});
  Map<String,dynamic> toJson() => {'id':id,'title':title,'note':note,'startTime':startTime,'endTime':endTime,'location':location,'cat':category.index,'allDay':allDay,'priority':priority};
  factory _Event.fromJson(Map<String,dynamic> j) => _Event(id:j['id']??'',title:j['title']??'',note:j['note'],startTime:j['startTime']??'09:00',endTime:j['endTime'],location:j['location'],category:_Cat.values[j['cat']??0],allDay:j['allDay']??false,priority:j['priority']??2);
}

class _Schedule {
  String name, startTime, endTime;
  List<int> days;
  int goalH;
  _Schedule({required this.name, required this.startTime, required this.endTime, required this.days, this.goalH=160});
  Map<String,dynamic> toJson() => {'name':name,'start':startTime,'end':endTime,'days':days,'goalH':goalH};
  factory _Schedule.fromJson(Map<String,dynamic> j) => _Schedule(name:j['name']??'Trabalho',startTime:j['start']??'09:00',endTime:j['end']??'18:00',days:List<int>.from(j['days']??[1,2,3,4,5]),goalH:j['goalH']??160);
  double get hPerDay { final s=_pt(startTime),e=_pt(endTime); final m=(e.hour*60+e.minute)-(s.hour*60+s.minute); return m>0?m/60.0:0; }
  TimeOfDay _pt(String t) { final p=t.split(':'); return TimeOfDay(hour:int.tryParse(p[0])??9,minute:int.tryParse(p.length>1?p[1]:'0')??0); }
}

// ── Custom Switch ─────────────────────────────────────────────────────────────
class _AriaSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color acc;
  const _AriaSwitch({required this.value, required this.onChanged, required this.acc});

  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: 50, height: 28,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? acc : const Color(0xFF8E8E93).withOpacity(.3),
        borderRadius: BorderRadius.circular(kPill),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22, height: 22,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,1))]),
        ),
      ),
    ),
  );
}

// ── Custom Dialog ─────────────────────────────────────────────────────────────
Future<bool?> _ariaDialog(BuildContext ctx, {
  required String title,
  required String body,
  required String confirmLabel,
  required Color confirmColor,
}) => showDialog<bool>(
  context: ctx,
  barrierColor: Colors.black54,
  builder: (_) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final tp = isDark ? Colors.white : Colors.black;
    final ts = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(kCard)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.roboto(color: tp, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(body, style: GoogleFonts.roboto(color: ts, fontSize: 14)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx, false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: ts.withOpacity(.3)),
                  borderRadius: BorderRadius.circular(kPill),
                ),
                child: Text('Cancelar', style: GoogleFonts.roboto(color: ts, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Navigator.pop(ctx, true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: confirmColor, borderRadius: BorderRadius.circular(kPill)),
                child: Text(confirmLabel, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ]),
        ]),
      ),
    );
  },
);

// ── Open Modal helper ─────────────────────────────────────────────────────────
Future<T?> _openSheet<T>(BuildContext ctx, Widget Function(BuildContext) builder) =>
    showModalBottomSheet<T>(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: builder,
    );

// ════════════════════════════════════════════════════════════════════════════════
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});
  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  DateTime _selectedDay = DateTime.now();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Map<String,List<_Event>> _events = {};
  Set<String> _appUsageDays = {};
  _Schedule? _schedule;

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
    _tabs = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() { themeNotifier.removeListener(_onTheme); _tabs.dispose(); super.dispose(); }
  void _onTheme() => setState(() {});

  String _key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  List<_Event> _dayEvents(DateTime d) => _events[_key(d)] ?? [];

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final rawEv = prefs.getString('aria_events_v3') ?? '{}';
    final mapEv = jsonDecode(rawEv) as Map<String,dynamic>;
    final events = <String,List<_Event>>{};
    mapEv.forEach((k,v) => events[k]=(v as List).map((e)=>_Event.fromJson(e)).toList());
    final rawSch = prefs.getString('aria_schedule_v2');
    _Schedule? schedule;
    if (rawSch!=null) schedule = _Schedule.fromJson(jsonDecode(rawSch));
    await DocumentService.instance.load();
    final usageDays = <String>{};
    for (final d in DocumentService.instance.documents) {
      usageDays.add(_key(d.updatedAt)); usageDays.add(_key(d.createdAt));
    }
    if (mounted) setState(() { _events=events; _appUsageDays=usageDays; _schedule=schedule; });
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String,dynamic>{};
    _events.forEach((k,v) => map[k]=v.map((e)=>e.toJson()).toList());
    await prefs.setString('aria_events_v3', jsonEncode(map));
  }

  Future<void> _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    if (_schedule!=null) await prefs.setString('aria_schedule_v2', jsonEncode(_schedule!.toJson()));
    else await prefs.remove('aria_schedule_v2');
  }

  void _addEvent([DateTime? day]) {
    final d = day ?? _selectedDay;
    _openSheet<_Event>(context, (_) => _AddEventSheet(selectedDay: d)).then((ev) {
      if (ev==null) return;
      final k = _key(d);
      setState(() => _events[k]=[...(_events[k]??[]), ev]);
      _saveEvents();
    });
  }

  void _deleteEvent(DateTime day, _Event ev) {
    final k = _key(day);
    setState(() {
      _events[k]=(_events[k]??[]).where((e)=>e.id!=ev.id).toList();
      if (_events[k]!.isEmpty) _events.remove(k);
    });
    _saveEvents();
  }

  void _openScheduleSheet() {
    _openSheet(context, (_) => _ScheduleSheet(schedule: _schedule)).then((s) {
      if (s==null) return;
      setState(() => _schedule = s as _Schedule?);
      _saveSchedule();
    });
  }

  int get _monthUsed {
    int c=0; final dm=DateTime(_visibleMonth.year,_visibleMonth.month+1,0).day;
    for(int i=1;i<=dm;i++) if(_appUsageDays.contains(_key(DateTime(_visibleMonth.year,_visibleMonth.month,i)))) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg   = isDark ? AppColors.darkBackground  : AppColors.background;
    final tp   = isDark ? AppColors.darkTextPrimary  : AppColors.textPrimary;
    final ts   = isDark ? AppColors.darkTextSecondary: AppColors.textSecondary;
    final div  = isDark ? AppColors.darkDivider      : AppColors.divider;
    final acc  = accColor(isDark);
    final pill = isDark ? const Color(0xFF363636)    : const Color(0xFFF2F2F7);
    final card = isDark ? const Color(0xFF2A2A2A)    : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, scrolledUnderElevation: 0,
        shadowColor: Colors.transparent, surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: _svgW(_backSvg, tp, s: 20),
        ),
        title: Text('Agenda', style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [
          // Botão horário
          GestureDetector(
            onTap: _openScheduleSheet,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF363636) : const Color(0xFFF2F2F7),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.work_outline_rounded, color: ts, size: 18),
            ),
          ),
          // Botão adicionar
          GestureDetector(
            onTap: () => _addEvent(),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36, height: 36,
              decoration: BoxDecoration(color: acc, shape: BoxShape.circle),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // ── Tab bar pill ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: pill, borderRadius: BorderRadius.circular(kPill)),
                child: TabBar(
                  controller: _tabs,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(color: card, borderRadius: BorderRadius.circular(kPill),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.1), blurRadius: 6)]),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: tp, unselectedLabelColor: ts,
                  labelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500),
                  tabs: const [Tab(text:'Mês',height:32), Tab(text:'Dia',height:32), Tab(text:'Horário',height:32)],
                ),
              ),
            ),
            Container(height: 0.5, color: div),
          ]),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _MonthView(s: this, isDark: isDark, tp: tp, ts: ts, div: div, acc: acc, card: card),
          _DayView(s: this, isDark: isDark, tp: tp, ts: ts, div: div, acc: acc, card: card),
          _TimelineView(s: this, isDark: isDark, tp: tp, ts: ts, div: div, acc: acc, card: card),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── MONTH VIEW ───────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _MonthView extends StatelessWidget {
  final _AgendaScreenState s;
  final bool isDark;
  final Color tp, ts, div, acc, card;
  const _MonthView({required this.s, required this.isDark, required this.tp, required this.ts, required this.div, required this.acc, required this.card});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final vm  = s._visibleMonth;
    final first = DateTime(vm.year, vm.month, 1);
    final last  = DateTime(vm.year, vm.month+1, 0);
    final startCol = (first.weekday - 1) % 7; // 0=Seg
    final rowCount = ((startCol + last.day) / 7).ceil();
    final sch = s._schedule;
    final usedThisMonth = s._monthUsed;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // ── Navegação mês ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(children: [
            _iconBtn(_prevSvg, ts, () => s.setState(() => s._visibleMonth = DateTime(vm.year,vm.month-1))),
            Expanded(child: Text(
              DateFormat('MMMM yyyy','pt').format(vm),
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(color: tp, fontSize: 16, fontWeight: FontWeight.w800),
            )),
            _iconBtn(_nextSvg, ts, () => s.setState(() => s._visibleMonth = DateTime(vm.year,vm.month+1))),
          ]),
        ),

        // ── Stats cards ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(children: [
            // Card dias de uso
            Expanded(child: _statCard(
              value: '$usedThisMonth',
              label: 'Dias de uso',
              sublabel: DateFormat('MMMM','pt').format(vm),
              color: acc,
              isDark: isDark,
              card: card,
            )),
            const SizedBox(width: 10),
            // Card horário / CTA
            Expanded(child: sch != null
              ? _statCard(
                  value: sch.name,
                  label: '${sch.startTime} → ${sch.endTime}',
                  sublabel: '${sch.hPerDay.toStringAsFixed(1)}h/dia',
                  color: const Color(0xFF2563EB),
                  isDark: isDark, card: card,
                  onTap: s._openScheduleSheet,
                )
              : GestureDetector(
                  onTap: s._openScheduleSheet,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kCard),
                      border: Border.all(color: acc.withOpacity(.4), width: 1.5),
                      color: acc.withOpacity(.06),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_rounded, color: acc, size: 20),
                      const SizedBox(height: 2),
                      Text('Horário de\ntrabalho', textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(color: acc, fontSize: 11, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                )),
          ]),
        ),

        // ── Grid habit-tracker ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Labels linha (dias semana)
            Column(children: ['S','T','Q','Q','S','S','D'].map((l) =>
              SizedBox(height: 36, child: Center(
                child: Text(l, style: GoogleFonts.roboto(color: ts, fontSize: 10, fontWeight: FontWeight.w700)),
              ))).toList()),
            const SizedBox(width: 4),
            // Colunas = semanas
            Expanded(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(rowCount, (col) => Expanded(
                  child: Column(children: List.generate(7, (row) {
                    final idx = col*7 + row;
                    final dayNum = idx - startCol + 1;
                    if (dayNum<1||dayNum>last.day) return const SizedBox(height: 36);
                    final date = DateTime(vm.year, vm.month, dayNum);
                    final k = s._key(date);
                    final wasUsed = s._appUsageDays.contains(k);
                    final isWorkDay = sch?.days.contains(date.weekday) ?? false;
                    final hasEv  = (s._events[k]??[]).isNotEmpty;
                    final isToday = k == s._key(now);
                    final isSel   = k == s._key(s._selectedDay);

                    // Color logic — like habit tracker in reference image
                    final boxColor = isSel
                        ? acc
                        : wasUsed && isWorkDay
                            ? acc.withOpacity(.9)
                            : wasUsed
                                ? acc.withOpacity(.4)
                                : isWorkDay
                                    ? (isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE))
                                    : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5));

                    return GestureDetector(
                      onTap: () { s.setState(() => s._selectedDay = date); s._tabs.animateTo(1); },
                      child: SizedBox(height: 36, child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: boxColor,
                            borderRadius: BorderRadius.circular(8),
                            border: isToday&&!isSel ? Border.all(color: acc, width: 1.5) : null,
                          ),
                          child: Stack(alignment: Alignment.center, children: [
                            Text('$dayNum', style: GoogleFonts.roboto(
                              color: isSel ? Colors.white
                                  : wasUsed ? (isDark?Colors.black87:Colors.white)
                                  : isToday ? acc : tp,
                              fontSize: 11, fontWeight: (isToday||wasUsed||isSel) ? FontWeight.w800 : FontWeight.w400,
                            )),
                            if (hasEv&&!isSel) Positioned(bottom: 2,
                              child: Container(width: 4, height: 4,
                                decoration: BoxDecoration(
                                  color: wasUsed ? Colors.white.withOpacity(.8) : acc,
                                  shape: BoxShape.circle))),
                          ]),
                        ),
                      )),
                    );
                  })),
                )),
              ),
            ),
          ]),
        ),

        // ── Legenda ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Wrap(spacing: 14, runSpacing: 6, children: [
            _leg(acc.withOpacity(.9), 'Dia trabalhado', ts),
            _leg(acc.withOpacity(.4), 'Dia de uso', ts),
            if (sch!=null) _leg(isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE), 'Dia laboral', ts),
          ]),
        ),

        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text('PRÓXIMOS EVENTOS', style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
        ),

        ..._upcoming().map((p) => _EventTile(ev: p.$2, day: p.$1, isDark: isDark, tp: tp, ts: ts, card: card,
            onDelete: () { s._deleteEvent(p.$1, p.$2); s.setState((){}); })),
        if (_upcoming().isEmpty)
          Padding(padding: const EdgeInsets.all(24), child: Center(
            child: Text('Sem eventos nos próximos 7 dias', style: GoogleFonts.roboto(color: ts, fontSize: 13)))),
      ],
    );
  }

  List<(DateTime, _Event)> _upcoming() {
    final now = DateTime.now();
    final result = <(DateTime,_Event)>[];
    for (int i=0; i<=7; i++) {
      final d = now.add(Duration(days:i));
      for (final ev in s._dayEvents(d)) result.add((d,ev));
    }
    return result.take(10).toList();
  }

  Widget _statCard({required String value, required String label, required String sublabel, required Color color, required bool isDark, required Color card, VoidCallback? onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: card, borderRadius: BorderRadius.circular(kCard),
          border: Border.all(color: color.withOpacity(.2)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.roboto(color: color, fontSize: 18, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: GoogleFonts.roboto(color: color.withOpacity(.8), fontSize: 10, fontWeight: FontWeight.w700)),
          Text(sublabel, style: GoogleFonts.roboto(color: ts, fontSize: 9)),
        ]),
      ),
    );

  Widget _leg(Color c, String label, Color ts) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 5),
    Text(label, style: GoogleFonts.roboto(color: ts, fontSize: 10)),
  ]);

  Widget _iconBtn(String svg, Color c, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Padding(padding: const EdgeInsets.all(8), child: _svgW(svg, c, s: 18)),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// ── DAY VIEW ─────────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _DayView extends StatelessWidget {
  final _AgendaScreenState s;
  final bool isDark;
  final Color tp, ts, div, acc, card;
  const _DayView({required this.s, required this.isDark, required this.tp, required this.ts, required this.div, required this.acc, required this.card});

  @override
  Widget build(BuildContext context) {
    final events = s._dayEvents(s._selectedDay);
    final isToday = s._key(s._selectedDay) == s._key(DateTime.now());

    return Column(children: [
      // ── Seletor ──
      Container(
        color: card,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _nav(_prevSvg, ts, () => s.setState(() => s._selectedDay = s._selectedDay.subtract(const Duration(days:1)))),
          const SizedBox(width: 16),
          Column(children: [
            Text(isToday ? 'Hoje' : DateFormat('EEEE','pt').format(s._selectedDay),
                style: GoogleFonts.roboto(color: acc, fontSize: 11, fontWeight: FontWeight.w700)),
            Text(DateFormat('d MMMM yyyy','pt').format(s._selectedDay),
                style: GoogleFonts.roboto(color: tp, fontSize: 17, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(width: 16),
          _nav(_nextSvg, ts, () => s.setState(() => s._selectedDay = s._selectedDay.add(const Duration(days:1)))),
        ]),
      ),
      Container(height: 0.5, color: div),
      Expanded(
        child: events.isEmpty
          ? _empty(tp, ts, acc)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16,16,16,100),
              itemCount: events.length,
              itemBuilder: (_,i) => _EventTile(ev: events[i], day: s._selectedDay, isDark: isDark, tp: tp, ts: ts, card: card, showDate: false,
                  onDelete: () { s._deleteEvent(s._selectedDay, events[i]); s.setState((){}); }),
            ),
      ),
    ]);
  }

  Widget _nav(String svg, Color c, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(padding: const EdgeInsets.all(8), child: _svgW(svg, c, s: 18)),
  );

  Widget _empty(Color tp, Color ts, Color acc) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 72, height: 72, decoration: BoxDecoration(color: acc.withOpacity(.08), shape: BoxShape.circle),
        child: Icon(Icons.event_note_rounded, color: acc.withOpacity(.5), size: 32)),
    const SizedBox(height: 16),
    Text('Sem eventos', style: GoogleFonts.roboto(color: tp, fontSize: 16, fontWeight: FontWeight.w700)),
    const SizedBox(height: 6),
    GestureDetector(
      onTap: () => s._addEvent(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(kPill)),
        child: Text('+ Novo evento', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    ),
  ]));
}

// ══════════════════════════════════════════════════════════════════════════════
// ── TIMELINE VIEW ─────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _TimelineView extends StatelessWidget {
  final _AgendaScreenState s;
  final bool isDark;
  final Color tp, ts, div, acc, card;
  const _TimelineView({required this.s, required this.isDark, required this.tp, required this.ts, required this.div, required this.acc, required this.card});

  @override
  Widget build(BuildContext context) {
    final now  = DateTime.now();
    final sel  = s._selectedDay;
    final wStart = sel.subtract(Duration(days: sel.weekday-1));
    final wDays  = List.generate(7, (i) => wStart.add(Duration(days:i)));

    return Column(children: [
      // ── Header semana ──
      Container(
        color: card,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(children: [
          _nav(_prevSvg, ts, () => s.setState(() => s._selectedDay = sel.subtract(const Duration(days:7)))),
          ...wDays.map((d) {
            final k = s._key(d);
            final isSel = k==s._key(sel), isToday = k==s._key(now);
            final wasUsed = s._appUsageDays.contains(k);
            final hasEv  = (s._events[k]??[]).isNotEmpty;
            return Expanded(child: GestureDetector(
              onTap: () => s.setState(() => s._selectedDay=d),
              child: Column(children: [
                Text(DateFormat('E','pt').format(d).substring(0,1),
                    style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: isSel ? acc : wasUsed ? acc.withOpacity(.3) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday&&!isSel ? Border.all(color: acc, width: 1.5) : null,
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    Text('${d.day}', style: GoogleFonts.roboto(
                        color: isSel ? Colors.white : isToday ? acc : tp,
                        fontSize: 13, fontWeight: FontWeight.w700)),
                    if (hasEv&&!isSel) Positioned(bottom: 2,
                        child: Container(width: 4, height: 4,
                            decoration: BoxDecoration(color: acc, shape: BoxShape.circle))),
                  ]),
                ),
              ]),
            ));
          }),
          _nav(_nextSvg, ts, () => s.setState(() => s._selectedDay = sel.add(const Duration(days:7)))),
        ]),
      ),
      Container(height: 0.5, color: div),

      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Stack(children: [
          // Linhas de hora
          ...List.generate(24, (h) => Positioned(
            top: h*56.0, left: 0, right: 0,
            child: Row(children: [
              SizedBox(width: 44, child: Text('${h.toString().padLeft(2,'0')}:00',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.roboto(color: ts.withOpacity(.5), fontSize: 9))),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 0.5, color: div.withOpacity(.5))),
            ]),
          )),
          Container(height: 24*56.0),
          // Bloco de trabalho
          if (s._schedule!=null && s._schedule!.days.contains(sel.weekday))
            Positioned(top: _top(s._schedule!.startTime), left: 54, right: 12,
              child: Container(
                height: _range(s._schedule!.startTime, s._schedule!.endTime),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(.06),
                  borderRadius: BorderRadius.circular(kCard),
                  border: Border(left: BorderSide(color: const Color(0xFF2563EB), width: 2.5)),
                ),
                padding: const EdgeInsets.all(8),
                child: Text('${s._schedule!.name}  ${s._schedule!.startTime}–${s._schedule!.endTime}',
                    style: GoogleFonts.roboto(color: const Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.w700)),
              )),
          // Eventos
          ...s._dayEvents(sel).map((ev) {
            final col = _catColor[ev.category] ?? acc;
            return Positioned(top: _top(ev.startTime), left: 54, right: 12,
              child: GestureDetector(
                onLongPress: () async {
                  final ok = await _ariaDialog(context, title: 'Eliminar evento',
                      body: 'Eliminar "${ev.title}"?', confirmLabel: 'Eliminar', confirmColor: const Color(0xFFDC2626));
                  if (ok==true) { s._deleteEvent(sel,ev); s.setState((){}); }
                },
                child: Container(
                  height: (ev.endTime!=null ? _range(ev.startTime,ev.endTime!) : 44.0).clamp(32.0,double.infinity),
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: col.withOpacity(.13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: col, width: 3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ev.title, style: GoogleFonts.roboto(color: col, fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (ev.endTime!=null) Text('${ev.startTime} – ${ev.endTime}',
                        style: GoogleFonts.roboto(color: col.withOpacity(.7), fontSize: 9)),
                  ]),
                ),
              ));
          }),
          // Linha hora actual
          if (s._key(sel)==s._key(now))
            Positioned(top: now.hour*56.0 + now.minute*56/60, left: 0, right: 0,
              child: Row(children: [
                SizedBox(width: 44, child: Text(DateFormat('HH:mm').format(now),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.roboto(color: acc, fontSize: 8, fontWeight: FontWeight.w800))),
                const SizedBox(width: 4),
                Expanded(child: Container(height: 1.5, color: acc)),
                Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: acc, shape: BoxShape.circle)),
              ])),
        ]),
      )),
    ]);
  }

  Widget _nav(String svg, Color c, VoidCallback fn) =>
    GestureDetector(onTap: fn, child: Padding(padding: const EdgeInsets.all(8), child: _svgW(svg, c, s: 16)));

  double _top(String t) { final p=t.split(':'); return (int.tryParse(p[0])??0)*56.0+(int.tryParse(p.length>1?p[1]:'0')??0)*56/60; }
  double _range(String a, String b) {
    double mins(String t) { final p=t.split(':'); return (int.tryParse(p[0])??0)*60.0+(int.tryParse(p.length>1?p[1]:'0')??0); }
    final d = mins(b)-mins(a);
    return (d>0?d:30)*56/60;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── EVENT TILE ───────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _EventTile extends StatelessWidget {
  final _Event ev;
  final DateTime day;
  final bool isDark, showDate;
  final Color tp, ts, card;
  final VoidCallback onDelete;
  const _EventTile({required this.ev, required this.day, required this.isDark, required this.tp, required this.ts, required this.card, required this.onDelete, this.showDate=true});

  @override
  Widget build(BuildContext context) {
    final col = _catColor[ev.category] ?? const Color(0xFF2563EB);
    final prioC = [Colors.transparent, const Color(0xFF8E8E93), const Color(0xFFEA580C), const Color(0xFFDC2626)];
    return Dismissible(
      key: Key(ev.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _ariaDialog(context, title:'Eliminar evento', body:'Eliminar "${ev.title}"?', confirmLabel:'Eliminar', confirmColor: const Color(0xFFDC2626)),
      background: Container(
        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(kCard)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card, borderRadius: BorderRadius.circular(kCard),
          border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
        ),
        child: Row(children: [
          Container(width: 4, height: 52, decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(kPill))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(ev.title, style: GoogleFonts.roboto(color: tp, fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (ev.priority>1) Container(width: 7, height: 7, margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(color: prioC[ev.priority], shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 5),
            Wrap(spacing: 8, children: [
              _chip(col, _catLabel[ev.category]??'', icon: _catIcon[ev.category]),
              _chip(null, ev.allDay ? 'Dia inteiro' : '${ev.startTime}${ev.endTime!=null?" – ${ev.endTime}":''}', icon: Icons.access_time_rounded, tc: ts),
              if (showDate) _chip(null, DateFormat('d MMM','pt').format(day), icon: Icons.calendar_today_outlined, tc: ts),
            ]),
            if (ev.location!=null) Padding(padding: const EdgeInsets.only(top: 5),
              child: Row(children: [
                Icon(Icons.location_on_outlined, size: 11, color: ts),
                const SizedBox(width: 3),
                Text(ev.location!, style: GoogleFonts.roboto(color: ts, fontSize: 11)),
              ])),
            if (ev.note!=null&&ev.note!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4),
              child: Text(ev.note!, style: GoogleFonts.roboto(color: ts, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis)),
          ])),
        ]),
      ),
    );
  }

  Widget _chip(Color? bg, String label, {IconData? icon, Color? tc}) {
    final c = bg ?? const Color(0xFF8E8E93);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon!=null) Icon(icon, size: 11, color: tc ?? c),
      const SizedBox(width: 3),
      Text(label, style: GoogleFonts.roboto(color: tc ?? c, fontSize: 10, fontWeight: FontWeight.w700)),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── ADD EVENT SHEET (DraggableScrollableSheet) ────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _AddEventSheet extends StatefulWidget {
  final DateTime selectedDay;
  const _AddEventSheet({required this.selectedDay});
  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _tc = TextEditingController();
  final _nc = TextEditingController();
  final _lc = TextEditingController();
  String _start='09:00', _end='10:00';
  _Cat _cat = _Cat.trabalho;
  int  _prio = 2;
  bool _allDay = false;

  @override
  void dispose() { _tc.dispose(); _nc.dispose(); _lc.dispose(); super.dispose(); }

  Future<void> _pickTime(bool isStart) async {
    final t = (isStart ? _start : _end).split(':');
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour:int.tryParse(t[0])??9,minute:int.tryParse(t.length>1?t[1]:'0')??0));
    if (picked!=null) { final s='${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}'; setState(()=>isStart?_start=s:_end=s); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = isDark ? AppColors.darkDivider    : AppColors.divider;
    final acc = accColor(isDark);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.97,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(kModal)),
        ),
        child: Column(children: [
          // Handle
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
              child: Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(kPill)))),
            ),
          ),
          // Title bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Novo evento', style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800)),
                Text(DateFormat('d MMMM yyyy','pt').format(widget.selectedDay),
                    style: GoogleFonts.roboto(color: ts, fontSize: 12)),
              ])),
              GestureDetector(
                onTap: () {
                  if (_tc.text.trim().isEmpty) return;
                  Navigator.pop(context, _Event(
                    id: '${DateTime.now().millisecondsSinceEpoch}',
                    title: _tc.text.trim(),
                    note: _nc.text.trim().isEmpty ? null : _nc.text.trim(),
                    startTime: _start, endTime: _allDay ? null : _end,
                    location: _lc.text.trim().isEmpty ? null : _lc.text.trim(),
                    category: _cat, allDay: _allDay, priority: _prio,
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(kPill)),
                  child: Text('Guardar', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 6),
          Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20,10,20,40), children: [
            _tf(_tc, 'Título *', tp, ts, div, acc),
            const SizedBox(height: 14),

            // Categoria
            _section('CATEGORIA', ts),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _Cat.values.map((c) {
              final sel = c==_cat;
              final col = _catColor[c]!;
              return GestureDetector(
                onTap: () => setState(()=>_cat=c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? col.withOpacity(.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(kPill),
                    border: Border.all(color: sel ? col : div.withOpacity(.6), width: sel?1.5:1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_catIcon[c], size: 12, color: sel?col:ts),
                    const SizedBox(width: 5),
                    Text(_catLabel[c]!, style: GoogleFonts.roboto(color: sel?col:ts, fontSize: 12, fontWeight: sel?FontWeight.w700:FontWeight.w400)),
                  ]),
                ),
              );
            }).toList()),
            const SizedBox(height: 16),

            // Dia inteiro
            _row('Dia inteiro', ts, tp, _AriaSwitch(value: _allDay, onChanged: (v)=>setState(()=>_allDay=v), acc: acc)),
            const SizedBox(height: 14),

            // Horas
            if (!_allDay) ...[
              Row(children: [
                Expanded(child: _timeBtn('Início', _start, tp, ts, div, isDark, ()=>_pickTime(true))),
                const SizedBox(width: 10),
                Expanded(child: _timeBtn('Fim', _end, tp, ts, div, isDark, ()=>_pickTime(false))),
              ]),
              const SizedBox(height: 14),
            ],

            _tf(_lc, 'Local (opcional)', tp, ts, div, acc, prefix: const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF8E8E93))),
            const SizedBox(height: 14),
            _tf(_nc, 'Notas (opcional)', tp, ts, div, acc, maxLines: 3),
            const SizedBox(height: 16),

            // Prioridade
            _section('PRIORIDADE', ts),
            const SizedBox(height: 8),
            Row(children: [
              _pchip(1, 'Baixa',  const Color(0xFF8E8E93), ts, div),
              const SizedBox(width: 8),
              _pchip(2, 'Normal', const Color(0xFFEA580C), ts, div),
              const SizedBox(width: 8),
              _pchip(3, 'Alta',   const Color(0xFFDC2626), ts, div),
            ]),
          ])),
        ]),
      ),
    );
  }

  Widget _section(String t, Color ts) => Text(t, style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.3));

  Widget _row(String label, Color ts, Color tp, Widget trailing) => Row(children: [
    Text(label, style: GoogleFonts.roboto(color: tp, fontSize: 14, fontWeight: FontWeight.w600)),
    const Spacer(), trailing,
  ]);

  Widget _pchip(int p, String label, Color color, Color ts, Color div) {
    final sel = _prio==p;
    return Expanded(child: GestureDetector(
      onTap: ()=>setState(()=>_prio=p),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(kPill),
          border: Border.all(color: sel?color:div, width: sel?1.5:1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.roboto(color: sel?color:ts, fontSize: 12, fontWeight: sel?FontWeight.w700:FontWeight.w400)),
        ]),
      ),
    ));
  }

  Widget _timeBtn(String label, String time, Color tp, Color ts, Color div, bool isDark, VoidCallback onTap) =>
    GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: div), borderRadius: BorderRadius.circular(kCard),
          color: isDark ? AppColors.darkBackground : const Color(0xFFF9FAFB),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(time, style: GoogleFonts.roboto(color: tp, fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
      ));

  Widget _tf(TextEditingController ctrl, String hint, Color tp, Color ts, Color div, Color acc, {int maxLines=1, Widget? prefix}) =>
    TextField(controller: ctrl, maxLines: maxLines,
      style: GoogleFonts.roboto(color: tp, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: GoogleFonts.roboto(color: ts, fontSize: 14),
        prefixIcon: prefix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kCard), borderSide: BorderSide(color: div)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kCard), borderSide: BorderSide(color: acc, width: 1.5)),
        filled: true, fillColor: themeNotifier.isDark ? AppColors.darkBackground : const Color(0xFFF9FAFB),
      ));
}

// ══════════════════════════════════════════════════════════════════════════════
// ── SCHEDULE SHEET ────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _ScheduleSheet extends StatefulWidget {
  final _Schedule? schedule;
  const _ScheduleSheet({this.schedule});
  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  final _nc = TextEditingController();
  String _start='09:00', _end='18:00';
  List<int> _days = [1,2,3,4,5];
  int _goalH = 160;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    if (s!=null) { _nc.text=s.name; _start=s.startTime; _end=s.endTime; _days=List.from(s.days); _goalH=s.goalH; }
    else _nc.text='Trabalho';
  }

  @override
  void dispose() { _nc.dispose(); super.dispose(); }

  Future<void> _pt(bool isStart) async {
    final t = (isStart?_start:_end).split(':');
    final picked = await showTimePicker(context: context,
        initialTime: TimeOfDay(hour:int.tryParse(t[0])??9,minute:int.tryParse(t.length>1?t[1]:'0')??0));
    if (picked!=null) { final s='${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}'; setState(()=>isStart?_start=s:_end=s); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = accColor(isDark);
    const dl  = ['Seg','Ter','Qua','Qui','Sex','Sáb','Dom'];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(kModal))),
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(0,12,0,4),
            child: Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(kPill))))),
          Padding(padding: const EdgeInsets.fromLTRB(20,8,20,0),
            child: Row(children: [
              Expanded(child: Text('Horário de trabalho', style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800))),
              if (widget.schedule!=null)
                GestureDetector(
                  onTap: () => Navigator.pop(context, null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDC2626).withOpacity(.4)),
                      borderRadius: BorderRadius.circular(kPill),
                    ),
                    child: Text('Remover', style: GoogleFonts.roboto(color: const Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.pop(context, _Schedule(
                  name: _nc.text.trim().isEmpty?'Trabalho':_nc.text.trim(),
                  startTime: _start, endTime: _end,
                  days: _days.toList()..sort(), goalH: _goalH,
                )),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(kPill)),
                  child: Text('Guardar', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ])),
          const SizedBox(height: 6),
          Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20,10,20,40), children: [
            // Nome
            TextField(controller: _nc,
              style: GoogleFonts.roboto(color: tp, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Nome do horário', labelStyle: GoogleFonts.roboto(color: ts),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kCard), borderSide: BorderSide(color: div)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kCard), borderSide: BorderSide(color: acc, width: 1.5)),
                filled: true, fillColor: isDark ? AppColors.darkBackground : const Color(0xFFF9FAFB),
              )),
            const SizedBox(height: 16),

            _label('HORÁRIO', ts),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _tBtn('Entrada', _start, tp, ts, div, isDark, ()=>_pt(true))),
              const SizedBox(width: 10),
              Expanded(child: _tBtn('Saída', _end, tp, ts, div, isDark, ()=>_pt(false))),
            ]),
            const SizedBox(height: 16),

            _label('DIAS DE TRABALHO', ts),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final d=i+1, sel=_days.contains(d);
                return GestureDetector(
                  onTap: () => setState(()=>sel?_days.remove(d):_days.add(d)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: sel ? acc : Colors.transparent,
                      borderRadius: BorderRadius.circular(kPill),
                      border: Border.all(color: sel?acc:div),
                    ),
                    child: Center(child: Text(dl[i].substring(0,2),
                        style: GoogleFonts.roboto(color: sel?Colors.white:ts, fontSize: 11, fontWeight: sel?FontWeight.w800:FontWeight.w400))),
                  ),
                );
              })),
            const SizedBox(height: 20),

            _label('META MENSAL (horas)', ts),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: SliderTheme(
                data: SliderThemeData(trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10)),
                child: Slider(value: _goalH.toDouble(), min: 40, max: 220, divisions: 18,
                    activeColor: acc, inactiveColor: acc.withOpacity(.2),
                    onChanged: (v)=>setState(()=>_goalH=v.round())),
              )),
              SizedBox(width: 60, child: Text('$_goalH h',
                  style: GoogleFonts.roboto(color: tp, fontSize: 15, fontWeight: FontWeight.w800))),
            ]),
          ])),
        ]),
      ),
    );
  }

  Widget _label(String t, Color ts) => Text(t, style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.3));

  Widget _tBtn(String label, String time, Color tp, Color ts, Color div, bool isDark, VoidCallback onTap) =>
    GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: div), borderRadius: BorderRadius.circular(kCard),
            color: isDark ? AppColors.darkBackground : const Color(0xFFF9FAFB)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(time, style: GoogleFonts.roboto(color: tp, fontSize: 16, fontWeight: FontWeight.w800)),
        ])));
}
