import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

// ─────────────────────────────────────────────
// NOTIFIER DE TEMA
// ─────────────────────────────────────────────
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();

// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;

    return MaterialApp(
      title: 'App Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F6EF7),
          brightness: Brightness.light,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF4F6EF7).withOpacity(0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF4F6EF7));
            }
            return const IconThemeData(color: Color(0xFF9AA0B2));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  color: Color(0xFF4F6EF7),
                  fontWeight: FontWeight.w600,
                  fontSize: 12);
            }
            return const TextStyle(
                color: Color(0xFF9AA0B2),
                fontWeight: FontWeight.w500,
                fontSize: 12);
          }),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FE),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1F36),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
              color: Color(0xFF1A1F36),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F6EF7),
          brightness: Brightness.dark,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1A1F36),
          indicatorColor: const Color(0xFF4F6EF7).withOpacity(0.25),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF4F6EF7));
            }
            return const IconThemeData(color: Color(0xFF6B7280));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  color: Color(0xFF4F6EF7),
                  fontWeight: FontWeight.w600,
                  fontSize: 12);
            }
            return const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                fontSize: 12);
          }),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1324),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F36),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1F36),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const MainShell(),
    );
  }
}

// ─────────────────────────────────────────────
// ÍCONES SVG VIA CUSTOMPAINTER
// ─────────────────────────────────────────────
class _NavIcon extends StatelessWidget {
  final CustomPainter painter;
  const _NavIcon({required this.painter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 24, height: 24, child: CustomPaint(painter: painter));
  }
}

/// HOME FILLED (viewBox 512×512)
class HomeFilledPainter extends CustomPainter {
  final Color color;
  HomeFilledPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 512;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Roof + walls
    final roof = Path()
      ..moveTo(362.667 * s, 383.841 * s)
      ..lineTo(362.667 * s, 511.841 * s)
      ..lineTo(448 * s, 511.841 * s)
      ..cubicTo(483.346 * s, 511.841 * s, 512 * s, 483.187 * s, 512 * s,
          447.841 * s)
      ..lineTo(512 * s, 253.26 * s)
      ..cubicTo(512.005 * s, 242.177 * s, 507.698 * s, 231.527 * s,
          499.989 * s, 223.564 * s)
      ..lineTo(318.699 * s, 27.574 * s)
      ..cubicTo(286.711 * s, -7.036 * s, 232.723 * s, -9.161 * s, 198.113 * s,
          22.827 * s)
      ..cubicTo(196.469 * s, 24.347 * s, 194.885 * s, 25.93 * s, 193.366 * s,
          27.574 * s)
      ..lineTo(12.395 * s, 223.5 * s)
      ..cubicTo(4.453 * s, 231.496 * s, -0.003 * s, 242.31 * s, 0 * s,
          253.58 * s)
      ..lineTo(0, 447.841 * s)
      ..cubicTo(0, 483.187 * s, 28.654 * s, 511.841 * s, 64 * s, 511.841 * s)
      ..lineTo(149.333 * s, 511.841 * s)
      ..lineTo(149.333 * s, 383.841 * s)
      ..cubicTo(149.732 * s, 325.669 * s, 196.699 * s, 278.165 * s,
          253.406 * s, 276.797 * s)
      ..cubicTo(312.01 * s, 275.383 * s, 362.22 * s, 323.696 * s, 362.667 * s,
          383.841 * s)
      ..close();

    // Door
    final door = Path()
      ..moveTo(256 * s, 319.841 * s)
      ..cubicTo(220.654 * s, 319.841 * s, 192 * s, 348.495 * s, 192 * s,
          383.841 * s)
      ..lineTo(192 * s, 511.841 * s)
      ..lineTo(320 * s, 511.841 * s)
      ..lineTo(320 * s, 383.841 * s)
      ..cubicTo(320 * s, 348.495 * s, 291.346 * s, 319.841 * s, 256 * s,
          319.841 * s)
      ..close();

    canvas.drawPath(roof, p);
    canvas.drawPath(door, p);
  }

  @override
  bool shouldRepaint(HomeFilledPainter old) => old.color != color;
}

/// HOME OUTLINE (viewBox 24×24)
class HomeOutlinePainter extends CustomPainter {
  final Color color;
  HomeOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      // outer shell
      ..moveTo(23.121 * s, 9.069 * s)
      ..lineTo(15.536 * s, 1.483 * s)
      ..cubicTo(13.017 * s, -1.036 * s, 8.983 * s, -1.036 * s, 7.464 * s,
          1.483 * s)
      ..lineTo(0.879 * s, 9.069 * s)
      ..cubicTo(0.316 * s, 9.647 * s, 0, 10.4 * s, 0, 11.19 * s)
      ..lineTo(0, 21.007 * s)
      ..cubicTo(0, 22.659 * s, 1.341 * s, 24 * s, 3 * s, 24 * s)
      ..lineTo(21 * s, 24 * s)
      ..cubicTo(22.659 * s, 24 * s, 24 * s, 22.659 * s, 24 * s, 21.007 * s)
      ..lineTo(24 * s, 11.19 * s)
      ..cubicTo(24 * s, 10.4 * s, 23.684 * s, 9.647 * s, 23.121 * s, 9.069 * s)
      ..close();

    // Punch door hole
    final door = Path()
      ..moveTo(9 * s, 22.007 * s)
      ..lineTo(9 * s, 18.073 * s)
      ..cubicTo(9 * s, 16.416 * s, 10.343 * s, 15.073 * s, 12 * s, 15.073 * s)
      ..cubicTo(13.657 * s, 15.073 * s, 15 * s, 16.416 * s, 15 * s, 18.073 * s)
      ..lineTo(15 * s, 22.007 * s)
      ..close();

    // Punch inner triangle / body
    final inner = Path()
      ..moveTo(2 * s, 21.007 * s)
      ..lineTo(2 * s, 11.19 * s)
      ..cubicTo(2 * s, 10.927 * s, 2.105 * s, 10.676 * s, 2.293 * s,
          10.483 * s)
      ..lineTo(9.878 * s, 2.9 * s)
      ..cubicTo(11.046 * s, 1.71 * s, 12.954 * s, 1.71 * s, 14.122 * s,
          2.9 * s)
      ..lineTo(21.707 * s, 10.486 * s)
      ..cubicTo(21.895 * s, 10.679 * s, 22 * s, 10.93 * s, 22 * s, 11.19 * s)
      ..lineTo(22 * s, 21.007 * s)
      ..cubicTo(22 * s, 21.559 * s, 21.552 * s, 22.007 * s, 21 * s, 22.007 * s)
      ..lineTo(17 * s, 22.007 * s)
      ..lineTo(17 * s, 18.073 * s)
      ..cubicTo(17 * s, 15.312 * s, 14.757 * s, 13.073 * s, 12 * s, 13.073 * s)
      ..cubicTo(9.243 * s, 13.073 * s, 7 * s, 15.312 * s, 7 * s, 18.073 * s)
      ..lineTo(7 * s, 22.007 * s)
      ..lineTo(3 * s, 22.007 * s)
      ..cubicTo(2.448 * s, 22.007 * s, 2 * s, 21.559 * s, 2 * s, 21.007 * s)
      ..close();

    canvas.drawPath(inner, p);
    canvas.drawPath(door, p);
  }

  @override
  bool shouldRepaint(HomeOutlinePainter old) => old.color != color;
}

/// AGENDA FILLED (viewBox 24×24)
class AgendaFilledPainter extends CustomPainter {
  final Color color;
  AgendaFilledPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      // top bar
      ..moveTo(0, 8 * s)
      ..lineTo(0, 7 * s)
      ..cubicTo(0, 4.243 * s, 2.243 * s, 2 * s, 5 * s, 2 * s)
      ..lineTo(6 * s, 2 * s)
      ..lineTo(6 * s, 1 * s)
      ..cubicTo(6 * s, 0.448 * s, 6.447 * s, 0, 7 * s, 0)
      ..cubicTo(7.553 * s, 0, 8 * s, 0.448 * s, 8 * s, 1 * s)
      ..lineTo(8 * s, 2 * s)
      ..lineTo(16 * s, 2 * s)
      ..lineTo(16 * s, 1 * s)
      ..cubicTo(16 * s, 0.448 * s, 16.447 * s, 0, 17 * s, 0)
      ..cubicTo(17.553 * s, 0, 18 * s, 0.448 * s, 18 * s, 1 * s)
      ..lineTo(18 * s, 2 * s)
      ..lineTo(19 * s, 2 * s)
      ..cubicTo(21.757 * s, 2 * s, 24 * s, 4.243 * s, 24 * s, 7 * s)
      ..lineTo(24 * s, 8 * s)
      ..close()
      // body
      ..moveTo(24 * s, 10 * s)
      ..lineTo(24 * s, 19 * s)
      ..cubicTo(24 * s, 21.757 * s, 21.757 * s, 24 * s, 19 * s, 24 * s)
      ..lineTo(5 * s, 24 * s)
      ..cubicTo(2.243 * s, 24 * s, 0, 21.757 * s, 0, 19 * s)
      ..lineTo(0, 10 * s)
      ..close()
      // line bottom-short
      ..moveTo(12 * s, 19 * s)
      ..cubicTo(12 * s, 18.448 * s, 11.553 * s, 18 * s, 11 * s, 18 * s)
      ..lineTo(6 * s, 18 * s)
      ..cubicTo(5.447 * s, 18 * s, 5 * s, 18.448 * s, 5 * s, 19 * s)
      ..cubicTo(5 * s, 19.552 * s, 5.447 * s, 20 * s, 6 * s, 20 * s)
      ..lineTo(11 * s, 20 * s)
      ..cubicTo(11.553 * s, 20 * s, 12 * s, 19.552 * s, 12 * s, 19 * s)
      ..close()
      // line top-long
      ..moveTo(19 * s, 15 * s)
      ..cubicTo(19 * s, 14.448 * s, 18.553 * s, 14 * s, 18 * s, 14 * s)
      ..lineTo(6 * s, 14 * s)
      ..cubicTo(5.447 * s, 14 * s, 5 * s, 14.448 * s, 5 * s, 15 * s)
      ..cubicTo(5 * s, 15.552 * s, 5.447 * s, 16 * s, 6 * s, 16 * s)
      ..lineTo(18 * s, 16 * s)
      ..cubicTo(18.553 * s, 16 * s, 19 * s, 15.552 * s, 19 * s, 15 * s)
      ..close();

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(AgendaFilledPainter old) => old.color != color;
}

/// AGENDA OUTLINE (viewBox 24×24)
class AgendaOutlinePainter extends CustomPainter {
  final Color color;
  AgendaOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      // line top
      ..moveTo(18 * s, 12.5 * s)
      ..cubicTo(18 * s, 13.329 * s, 17.328 * s, 14 * s, 16.5 * s, 14 * s)
      ..lineTo(7.5 * s, 14 * s)
      ..cubicTo(6.672 * s, 14 * s, 6 * s, 13.329 * s, 6 * s, 12.5 * s)
      ..cubicTo(6 * s, 11.671 * s, 6.672 * s, 11 * s, 7.5 * s, 11 * s)
      ..lineTo(16.5 * s, 11 * s)
      ..cubicTo(17.328 * s, 11 * s, 18 * s, 11.671 * s, 18 * s, 12.5 * s)
      ..close()
      // line bottom
      ..moveTo(11.5 * s, 16 * s)
      ..lineTo(7.5 * s, 16 * s)
      ..cubicTo(6.672 * s, 16 * s, 6 * s, 16.671 * s, 6 * s, 17.5 * s)
      ..cubicTo(6 * s, 18.329 * s, 6.672 * s, 19 * s, 7.5 * s, 19 * s)
      ..lineTo(11.5 * s, 19 * s)
      ..cubicTo(12.328 * s, 19 * s, 13 * s, 18.329 * s, 13 * s, 17.5 * s)
      ..cubicTo(13 * s, 16.671 * s, 12.328 * s, 16 * s, 11.5 * s, 16 * s)
      ..close()
      // outer shape with hole
      ..moveTo(24 * s, 7.5 * s)
      ..lineTo(24 * s, 18.5 * s)
      ..cubicTo(24 * s, 21.533 * s, 21.532 * s, 24 * s, 18.5 * s, 24 * s)
      ..lineTo(5.5 * s, 24 * s)
      ..cubicTo(2.468 * s, 24 * s, 0, 21.533 * s, 0, 18.5 * s)
      ..lineTo(0, 7.5 * s)
      ..cubicTo(0, 4.467 * s, 2.468 * s, 2 * s, 5.5 * s, 2 * s)
      ..lineTo(6 * s, 2 * s)
      ..lineTo(6 * s, 1.5 * s)
      ..cubicTo(6 * s, 0.671 * s, 6.672 * s, 0, 7.5 * s, 0)
      ..cubicTo(8.328 * s, 0, 9 * s, 0.671 * s, 9 * s, 1.5 * s)
      ..lineTo(9 * s, 2 * s)
      ..lineTo(15 * s, 2 * s)
      ..lineTo(15 * s, 1.5 * s)
      ..cubicTo(15 * s, 0.671 * s, 15.672 * s, 0, 16.5 * s, 0)
      ..cubicTo(17.328 * s, 0, 18 * s, 0.671 * s, 18 * s, 1.5 * s)
      ..lineTo(18 * s, 2 * s)
      ..lineTo(18.5 * s, 2 * s)
      ..cubicTo(21.532 * s, 2 * s, 24 * s, 4.467 * s, 24 * s, 7.5 * s)
      ..close()
      // inner body (even-odd fill will punch hole)
      ..moveTo(21 * s, 18.5 * s)
      ..lineTo(21 * s, 9 * s)
      ..lineTo(3 * s, 9 * s)
      ..lineTo(3 * s, 18.5 * s)
      ..cubicTo(3 * s, 19.878 * s, 4.121 * s, 21 * s, 5.5 * s, 21 * s)
      ..lineTo(18.5 * s, 21 * s)
      ..cubicTo(19.879 * s, 21 * s, 21 * s, 19.878 * s, 21 * s, 18.5 * s)
      ..close();

    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(AgendaOutlinePainter old) => old.color != color;
}

/// ROCKET FILLED (viewBox 512×512)
class RocketFilledPainter extends CustomPainter {
  final Color color;
  RocketFilledPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 512;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(11.815 * s, 289.919 * s)
      ..cubicTo(0.219 * s, 272.859 * s, -2.099 * s, 251.138 * s, 5.636 * s,
          232.015 * s)
      ..cubicTo(22.923 * s, 196.75 * s, 51.882 * s, 168.556 * s, 87.597 * s,
          152.22 * s)
      ..cubicTo(113.455 * s, 139.361 * s, 141.464 * s, 131.386 * s,
          170.216 * s, 128.693 * s)
      ..cubicTo(157.688 * s, 144.109 * s, 145.146 * s, 160.557 * s,
          132.59 * s, 178.04 * s)
      ..cubicTo(107.036 * s, 216.736 * s, 85.162 * s, 257.74 * s, 67.255 * s,
          300.515 * s)
      ..lineTo(59.547 * s, 317.799 * s)
      ..cubicTo(40.239 * s, 316.201 * s, 22.691 * s, 305.952 * s, 11.815 * s,
          289.919 * s)
      ..close()
      ..moveTo(41.181 * s, 379.609 * s)
      ..cubicTo(22.733 * s, 405.082 * s, 9.492 * s, 433.944 * s, 2.218 * s,
          464.543 * s)
      ..cubicTo(-2.317 * s, 484.425 * s, 10.124 * s, 504.22 * s, 30.007 * s,
          508.755 * s)
      ..cubicTo(35.418 * s, 509.989 * s, 41.037 * s, 509.988 * s, 46.448 * s,
          508.751 * s)
      ..cubicTo(77 * s, 501.465 * s, 105.817 * s, 488.233 * s, 131.255 * s,
          469.809 * s)
      ..lineTo(131.255 * s, 469.809 * s)
      ..cubicTo(156.163 * s, 444.913 * s, 156.173 * s, 404.538 * s,
          131.276 * s, 379.63 * s)
      ..cubicTo(106.38 * s, 354.722 * s, 66.005 * s, 354.712 * s, 41.097 * s,
          379.609 * s)
      ..lineTo(41.181 * s, 379.609 * s)
      ..close()
      ..moveTo(209.711 * s, 442.885 * s)
      ..lineTo(192.3 * s, 450.614 * s)
      ..lineTo(192.3 * s, 456.857 * s)
      ..cubicTo(192.342 * s, 471.812 * s, 198.331 * s, 486.136 * s,
          208.947 * s, 496.67 * s)
      ..cubicTo(219.045 * s, 506.491 * s, 232.572 * s, 511.99 * s, 246.658 * s,
          512.001 * s)
      ..cubicTo(296.705 * s, 511.279 * s, 337.283 * s, 465.712 * s,
          358.58 * s, 423.288 * s)
      ..cubicTo(371.627 * s, 397.032 * s, 379.629 * s, 368.561 * s,
          382.17 * s, 339.352 * s)
      ..cubicTo(366.599 * s, 352.092 * s, 349.902 * s, 364.832 * s,
          332.08 * s, 377.572 * s)
      ..cubicTo(293.399 * s, 403.133 * s, 252.401 * s, 425 * s, 209.626 * s,
          442.886 * s)
      ..lineTo(209.711 * s, 442.885 * s)
      ..close()
      ..moveTo(510.802 * s, 62.827 * s)
      ..cubicTo(507.978 * s, 155.256 * s, 441.432 * s, 246.921 * s,
          307.343 * s, 343.109 * s)
      ..cubicTo(270.853 * s, 366.763 * s, 232.358 * s, 387.169 * s,
          192.3 * s, 404.092 * s)
      ..lineTo(192.3 * s, 392.138 * s)
      ..cubicTo(192.102 * s, 351.176 * s, 158.945 * s, 318.018 * s,
          117.983 * s, 317.821 * s)
      ..lineTo(106.029 * s, 317.821 * s)
      ..cubicTo(122.991 * s, 277.762 * s, 143.432 * s, 239.267 * s,
          167.118 * s, 202.778 * s)
      ..cubicTo(263.071 * s, 69.006 * s, 354.587 * s, 2.375 * s, 446.868 * s,
          -0.64 * s)
      ..cubicTo(492.859 * s, -0.64 * s, 510.802 * s, 18.088 * s, 510.802 * s,
          62.827 * s)
      ..close();

    // circle (porthole)
    final circle = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(330.317 * s, 179.802 * s),
          width: 106.168 * s,
          height: 106.168 * s));

    canvas.drawPath(path, p);
    canvas.drawPath(circle, p);
  }

  @override
  bool shouldRepaint(RocketFilledPainter old) => old.color != color;
}

/// ROCKET OUTLINE (viewBox 24×24)
class RocketOutlinePainter extends CustomPainter {
  final Color color;
  RocketOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // blast bottom-left
    final blast = Path()
      ..moveTo(5.3 * s, 18.7 * s)
      ..cubicTo(5.3 * s, 19.598 * s, 4.956 * s, 20.459 * s, 4.3 * s,
          21.094 * s)
      ..cubicTo(3.408 * s, 21.977 * s, 1.888 * s, 22.596 * s, 1.088 * s,
          22.974 * s)
      ..cubicTo(0.788 * s, 23.096 * s, 0.384 * s, 23.05 * s, 0.023 * s,
          22.915 * s)
      ..cubicTo(-0.097 * s, 22.578 * s, -0.024 * s, 22.171 * s, 0.1 * s,
          21.877 * s)
      ..cubicTo(0.457 * s, 21.07 * s, 1.05 * s, 19.545 * s, 1.9 * s, 18.7 * s)
      ..cubicTo(2.556 * s, 18.044 * s, 3.421 * s, 17.7 * s, 4.3 * s, 17.7 * s)
      ..cubicTo(4.956 * s, 17.7 * s, 5.3 * s, 18.044 * s, 5.3 * s, 18.7 * s)
      ..close();

    // porthole
    final porthole = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(15.5 * s, 8.5 * s),
          width: 5 * s,
          height: 5 * s));

    // body
    final body = Path()
      ..moveTo(21 * s, 3.458 * s)
      ..cubicTo(21 * s, 3.207 * s, 20.79 * s, 3 * s, 20.5 * s, 3 * s)
      ..cubicTo(15.464 * s, 3.144 * s, 12.2 * s, 5 * s, 8.888 * s, 9.614 * s)
      ..cubicTo(7.811 * s, 11.047 * s, 7.033 * s, 12.457 * s, 6.735 * s,
          13.254 * s)
      ..cubicTo(7.7 * s, 13.618 * s, 9.077 * s, 14.563 * s, 10.719 * s,
          17.176 * s)
      ..lineTo(12.882 * s, 16.1 * s)
      ..cubicTo(13.388 * s, 15.8 * s, 13.9 * s, 15.466 * s, 14.387 * s,
          15.117 * s)
      ..cubicTo(19 * s, 11.8 * s, 20.856 * s, 8.536 * s, 21 * s, 3.458 * s)
      ..close();

    // wings+frame
    final frame = Path()
      ..moveTo(16.024 * s, 17.629 * s)
      ..lineTo(16.032 * s, 17.623 * s)
      ..cubicTo(21.375 * s, 13.793 * s, 23.829 * s, 9.531 * s, 24 * s, 3.5 * s)
      ..cubicTo(24 * s, 1.168 * s, 22.637 * s, 0, 20.458 * s, 0)
      ..cubicTo(14.469 * s, 0.171 * s, 10.088 * s, 2.8 * s, 6.257 * s,
          8.139 * s)
      ..cubicTo(5.005 * s, 8.458 * s, 3.835 * s, 9.035 * s, 2.832 * s,
          9.823 * s)
      ..cubicTo(1.424 * s, 10.928 * s, 0.192 * s, 12.713 * s, 0.192 * s,
          12.713 * s)
      ..cubicTo(0.222 * s, 15.139 * s, 1.205 * s, 16 * s, 2.392 * s, 16 * s)
      ..lineTo(5 * s, 16 * s)
      ..cubicTo(6.657 * s, 16 * s, 8 * s, 17.343 * s, 8 * s, 19 * s)
      ..lineTo(8 * s, 21.554 * s)
      ..cubicTo(9.078 * s, 22.688 * s, 10.318 * s, 23.067 * s, 11.361 * s,
          23.804 * s)
      ..cubicTo(11.714 * s, 24.117 * s, 13.976 * s, 22.404 * s, 15.209 * s,
          19.734 * s)
      ..cubicTo(15.609 * s, 18.867 * s, 15.862 * s, 18.228 * s, 16.024 * s,
          17.629 * s)
      ..close();

    canvas.drawPath(frame, p);
    canvas.drawPath(body, p);
    canvas.drawPath(blast, p);
    canvas.drawPath(porthole, p);
  }

  @override
  bool shouldRepaint(RocketOutlinePainter old) => old.color != color;
}

// ─────────────────────────────────────────────
// SHELL PRINCIPAL
// ─────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    InicioPAge(),
    AgendaPage(),
    LancamentosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final colorScheme = Theme.of(context).colorScheme;
    final navBg = isDark ? const Color(0xFF1A1F36) : Colors.white;

    return Scaffold(
      drawer: const _AppDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4))
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 400),
          destinations: [
            NavigationDestination(
              icon: _NavIcon(
                  painter: HomeOutlinePainter(
                      color: const Color(0xFF9AA0B2))),
              selectedIcon: _NavIcon(
                  painter:
                      HomeFilledPainter(color: colorScheme.primary)),
              label: 'Início',
            ),
            NavigationDestination(
              icon: _NavIcon(
                  painter: AgendaOutlinePainter(
                      color: const Color(0xFF9AA0B2))),
              selectedIcon: _NavIcon(
                  painter:
                      AgendaFilledPainter(color: colorScheme.primary)),
              label: 'Agenda',
            ),
            NavigationDestination(
              icon: _NavIcon(
                  painter: RocketOutlinePainter(
                      color: const Color(0xFF9AA0B2))),
              selectedIcon: _NavIcon(
                  painter:
                      RocketFilledPainter(color: colorScheme.primary)),
              label: 'Lançamentos',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DRAWER
// ─────────────────────────────────────────────
class _AppDrawer extends StatefulWidget {
  const _AppDrawer();

  @override
  State<_AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<_AppDrawer> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_rebuild);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final colorScheme = Theme.of(context).colorScheme;
    final drawerBg = isDark ? const Color(0xFF1A1F36) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F36);
    final textSecondary =
        isDark ? const Color(0xFF9AA0B2) : const Color(0xFF6B7280);
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: colorScheme.primary.withOpacity(0.15),
                    child: Icon(Icons.person_outline_rounded,
                        size: 28, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Utilizador',
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        Text('utilizador@email.com',
                            style: TextStyle(
                                color: textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 12),

            _DrawerItem(
                icon: Icons.home_outlined,
                label: 'Início',
                onTap: () => Navigator.pop(context)),
            _DrawerItem(
                icon: Icons.settings_outlined,
                label: 'Definições',
                onTap: () => Navigator.pop(context)),
            _DrawerItem(
                icon: Icons.help_outline_rounded,
                label: 'Ajuda',
                onTap: () => Navigator.pop(context)),
            _DrawerItem(
                icon: Icons.info_outline_rounded,
                label: 'Sobre',
                onTap: () => Navigator.pop(context)),

            const Spacer(),
            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 8),

            // Theme toggle com Container Transform
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 450),
                openColor: drawerBg,
                closedColor: colorScheme.primary.withOpacity(0.08),
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                closedElevation: 0,
                openElevation: 0,
                closedBuilder: (context, openContainer) {
                  return InkWell(
                    onTap: themeNotifier.toggle,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            isDark
                                ? Icons.wb_sunny_outlined
                                : Icons.dark_mode_outlined,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            isDark ? 'Tema Claro' : 'Tema Escuro',
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 44,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isDark
                                  ? colorScheme.primary
                                  : colorScheme.primary.withOpacity(0.2),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: isDark
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 2),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? Colors.white
                                      : colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                openBuilder: (context, closeContainer) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  });
                  return Container(color: drawerBg);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F36);
    final iconColor =
        isDark ? const Color(0xFF9AA0B2) : const Color(0xFF6B7280);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(label,
          style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
      shape:
          const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }
}

// ─────────────────────────────────────────────
// PÁGINA: INÍCIO
// ─────────────────────────────────────────────
class InicioPAge extends StatelessWidget {
  const InicioPAge({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeNotifier.isDark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F36);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: colorScheme.primary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('Início'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary.withOpacity(0.12),
              child: Icon(Icons.person_outline_rounded,
                  size: 20, color: colorScheme.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.75)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bem-vindo! 👋',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('O que vamos fazer\nhoje?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.2)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: colorScheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Explorar',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Acesso Rápido',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 14),
            Row(
              children: [
                _QuickCard(
                    icon: Icons.bar_chart_rounded,
                    label: 'Relatórios',
                    color: const Color(0xFFFF6B6B)),
                const SizedBox(width: 12),
                _QuickCard(
                    icon: Icons.task_alt_rounded,
                    label: 'Tarefas',
                    color: const Color(0xFF4F6EF7)),
                const SizedBox(width: 12),
                _QuickCard(
                    icon: Icons.notifications_outlined,
                    label: 'Alertas',
                    color: const Color(0xFFFFB547)),
              ],
            ),
            const SizedBox(height: 28),
            Text('Atividade Recente',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 14),
            ...List.generate(4, (i) => _ActivityTile(index: i)),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickCard(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final cardColor = isDark ? const Color(0xFF1A1F36) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F36);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final int index;
  const _ActivityTile({required this.index});

  static const _titles = [
    'Reunião com a equipa',
    'Atualização de projeto',
    'Novo utilizador registado',
    'Relatório semanal enviado'
  ];
  static const _subtitles = [
    'Hoje, 14:30',
    'Hoje, 11:00',
    'Ontem, 09:15',
    'Segunda, 08:00'
  ];
  static const _icons = [
    Icons.groups_rounded,
    Icons.update_rounded,
    Icons.person_add_alt_1_rounded,
    Icons.description_rounded
  ];
  static const _colors = [
    Color(0xFF4F6EF7),
    Color(0xFFFF6B6B),
    Color(0xFF34D399),
    Color(0xFFFFB547)
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final cardColor = isDark ? const Color(0xFF1A1F36) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F36);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: _colors[index].withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(_icons[index], color: _colors[index], size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_titles[index],
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary)),
                const SizedBox(height: 2),
                Text(_subtitles[index],
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9AA0B2))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF9AA0B2), size: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PÁGINA: AGENDA
// ─────────────────────────────────────────────
class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  int _selectedDay = 2;
  final List<String> _days = [
    'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'
  ];
  final List<String> _dates = [
    '10', '11', '12', '13', '14', '15', '16'
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeNotifier.isDark;
    final headerBg = isDark ? const Color(0xFF1A1F36) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: colorScheme.primary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('Agenda'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () {},
              color: colorScheme.primary),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final isSelected = i == _selectedDay;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(_days[i],
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : const Color(0xFF9AA0B2))),
                        const SizedBox(height: 4),
                        Text(_dates[i],
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1F36)))),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                _EventCard(
                    time: '09:00',
                    title: 'Standup diário',
                    description: 'Alinhamento da equipa',
                    duration: '30 min',
                    color: Color(0xFF4F6EF7)),
                _EventCard(
                    time: '11:00',
                    title: 'Revisão de código',
                    description: 'Sprint 14 – módulo de pagamentos',
                    duration: '1h 30min',
                    color: Color(0xFF34D399)),
                _EventCard(
                    time: '14:00',
                    title: 'Reunião com cliente',
                    description: 'Demo do novo dashboard',
                    duration: '1h',
                    color: Color(0xFFFF6B6B)),
                _EventCard(
                    time: '16:30',
                    title: 'Planeamento semanal',
                    description: 'Definição de prioridades',
                    duration: '45 min',
                    color: Color(0xFFFFB547)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String time;
  final String title;
  final String description;
  final String duration;
  final Color color;

  const _EventCard({
    required this.time,
    required this.title,
    required this.description,
    required this.duration,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final cardColor = isDark ? const Color(0xFF1A1F36) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F36);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(time,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9AA0B2))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: color, width: 3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textPrimary)),
                        const SizedBox(height: 4),
                        Text(description,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9AA0B2))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30)),
                    child: Text(duration,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PÁGINA: LANÇAMENTOS
// ─────────────────────────────────────────────
class LancamentosPage extends StatelessWidget {
  const LancamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: colorScheme.primary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('Lançamentos'),
        actions: [
          IconButton(
              icon: const Icon(Icons.filter_list_rounded),
              onPressed: () {},
              color: colorScheme.primary),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(30)),
                child: const Text('✦ Novidades',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _LaunchCard(
              tag: 'Em breve',
              tagColor: Color(0xFF4F6EF7),
              title: 'Dashboard 2.0',
              description:
                  'Nova interface redesenhada com gráficos interativos e modo escuro completo.',
              date: 'Previsto: Mar 2025',
              icon: Icons.dashboard_customize_rounded),
          const _LaunchCard(
              tag: 'Novo',
              tagColor: Color(0xFF34D399),
              title: 'Relatórios automáticos',
              description:
                  'Gere relatórios PDF semanais automaticamente com base nos seus dados.',
              date: 'Lançado: Jan 2025',
              icon: Icons.auto_awesome_rounded),
          const _LaunchCard(
              tag: 'Atualização',
              tagColor: Color(0xFFFFB547),
              title: 'Notificações inteligentes',
              description:
                  'Sistema de alertas com IA que aprende as suas preferências ao longo do tempo.',
              date: 'Lançado: Dez 2024',
              icon: Icons.notifications_active_rounded),
          const _LaunchCard(
              tag: 'Beta',
              tagColor: Color(0xFFFF6B6B),
              title: 'Integração com calendário',
              description:
                  'Sincronize eventos com Google Calendar e Outlook de forma nativa.',
              date: 'Beta: Nov 2024',
              icon: Icons.sync_rounded),
          const _LaunchCard(
              tag: 'Lançado',
              tagColor: Color(0xFF9AA0B2),
              title: 'App móvel v1.0',
              description:
                  'Versão inicial da aplicação móvel com suporte a iOS e Android.',
              date: 'Lançado: Out 2024',
              icon: Icons.phone_android_rounded),
        ],
      ),
    );
  }
}

class _LaunchCard extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final String title;
  final String description;
  final String date;
  final IconData icon;

  const _LaunchCard({
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final cardColor = isDark ? const Color(0xFF1A1F36) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F36);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: tagColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: tagColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30)),
                  child: Text(tag,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: tagColor,
                          letterSpacing: 0.3)),
                ),
                const SizedBox(height: 8),
                Text(title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary)),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        size: 12, color: Color(0xFF9AA0B2)),
                    const SizedBox(width: 4),
                    Text(date,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9AA0B2),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
