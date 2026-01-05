/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show HttpOverrides, HttpClient, SecurityContext, X509Certificate;
import 'core/app_state.dart';
import 'screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuração global para corrigir imagens PNG - APENAS para plataformas não-web
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

// Classe para resolver problemas de certificado SSL - NÃO funciona na web
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: MaterialApp(
            title: 'Football Live',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(appState.corDinamica),
            darkTheme: appState.temaAmoled 
                ? _buildAmoledTheme(appState.corDinamica) 
                : _buildDarkTheme(appState.corDinamica, appState.temaEscuroProfundo),
            themeMode: appState.temaEscuro ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(),
            // Configuração adicional para melhorar renderização de imagens na web
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // Garante que imagens sejam renderizadas corretamente
                  textScaleFactor: 1.0,
                ),
                child: child!,
              );
            },
          ),
        );
      },
    );
  }

  ThemeData _buildLightTheme(bool usarCorDinamica) {
    const pureWhite = Color(0xFFFFFFFF);
    const appleBlue = Color(0xFF007AFF);
    const lightGray = Color(0xFFFAFAFA);
    const mediumGray = Color(0xFFF5F5F5);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
          surface: pureWhite,
          background: pureWhite,
        ),
        scaffoldBackgroundColor: pureWhite,
        cardColor: pureWhite,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: pureWhite,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        cardTheme: CardThemeData(
          color: pureWhite,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: pureWhite,
      cardColor: pureWhite,
      dividerColor: const Color(0xFFE0E0E0),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.light(
        primary: appleBlue,
        onPrimary: pureWhite,
        secondary: appleBlue,
        onSecondary: pureWhite,
        surface: pureWhite,
        onSurface: Color(0xFF1A1A1A),
        background: pureWhite,
        onBackground: Color(0xFF1A1A1A),
        error: Color(0xFFD32F2F),
        onError: pureWhite,
        surfaceContainerLowest: pureWhite,
        surfaceContainerLow: lightGray,
        surfaceContainer: mediumGray,
        surfaceContainerHigh: Color(0xFFF0F0F0),
        surfaceContainerHighest: Color(0xFFEBEBEB),
        onSurfaceVariant: Color(0xFF666666),
        outline: Color(0xFFE0E0E0),
        outlineVariant: Color(0xFFF0F0F0),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: pureWhite,
        foregroundColor: Color(0xFF1A1A1A),
        iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: pureWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: pureWhite,
        modalBackgroundColor: pureWhite,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue;
          return const Color(0xFFBDBDBD);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue.withOpacity(0.5);
          return const Color(0xFFE0E0E0);
        }),
      ),
    );
  }

  ThemeData _buildDarkTheme(bool usarCorDinamica, bool profundo) {
    const appleBlue = Color(0xFF007AFF);

    final surfaceColor = profundo ? const Color(0xFF0D0D0D) : const Color(0xFF1D2024);
    final backgroundColor = profundo ? const Color(0xFF000000) : const Color(0xFF111318);
    final surfaceContainerColor = profundo ? const Color(0xFF1A1A1A) : const Color(0xFF282A2F);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
          surface: surfaceColor,
          background: backgroundColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardColor: surfaceColor,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: surfaceColor.withOpacity(0.7),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: profundo ? const Color(0xFF1A1A1A) : const Color(0xFF444746),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.dark(
        primary: appleBlue,
        onPrimary: Colors.white,
        secondary: appleBlue,
        onSecondary: Colors.white,
        surface: surfaceColor,
        onSurface: const Color(0xFFE2E2E6),
        background: backgroundColor,
        onBackground: const Color(0xFFE2E2E6),
        error: const Color(0xFFFFB4AB),
        onError: const Color(0xFF690005),
        surfaceContainerLowest: profundo ? const Color(0xFF050505) : const Color(0xFF0D0D0D),
        surfaceContainerLow: profundo ? const Color(0xFF0A0A0A) : const Color(0xFF111318),
        surfaceContainer: surfaceContainerColor,
        surfaceContainerHigh: profundo ? const Color(0xFF242424) : const Color(0xFF323439),
        surfaceContainerHighest: profundo ? const Color(0xFF2E2E2E) : const Color(0xFF3D3F44),
        onSurfaceVariant: const Color(0xFFC4C7C5),
        outline: const Color(0xFF8E918F),
        outlineVariant: const Color(0xFF444746),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: surfaceColor.withOpacity(0.7),
        foregroundColor: const Color(0xFFE2E2E6),
        iconTheme: const IconThemeData(color: Color(0xFFE2E2E6)),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor.withOpacity(0.7),
        indicatorColor: appleBlue.withOpacity(0.2),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainerColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceContainerColor,
        modalBackgroundColor: surfaceContainerColor,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue;
          return const Color(0xFF616161);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue.withOpacity(0.5);
          return const Color(0xFF424242);
        }),
      ),
    );
  }

  ThemeData _buildAmoledTheme(bool usarCorDinamica) {
    const pureBlack = Color(0xFF000000);
    const almostBlack = Color(0xFF0A0A0A);
    const appleBlue = Color(0xFF007AFF);

    if (usarCorDinamica) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
          surface: almostBlack,
          background: pureBlack,
        ),
        scaffoldBackgroundColor: pureBlack,
        cardColor: almostBlack,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: pureBlack,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: appleBlue,
      scaffoldBackgroundColor: pureBlack,
      cardColor: almostBlack,
      dividerColor: const Color(0xFF1A1A1A),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.dark(
        primary: appleBlue,
        onPrimary: Colors.white,
        secondary: appleBlue,
        onSecondary: Colors.white,
        surface: almostBlack,
        onSurface: Color(0xFFFFFFFF),
        background: pureBlack,
        onBackground: Color(0xFFFFFFFF),
        error: Color(0xFFEF5350),
        onError: Colors.white,
        surfaceContainerLowest: pureBlack,
        surfaceContainerLow: almostBlack,
        surfaceContainer: Color(0xFF151515),
        surfaceContainerHigh: Color(0xFF1A1A1A),
        surfaceContainerHighest: Color(0xFF202020),
        onSurfaceVariant: Color(0xFFB0B0B0),
        outline: Color(0xFF2A2A2A),
        outlineVariant: Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: pureBlack,
        foregroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: almostBlack,
        indicatorColor: appleBlue.withOpacity(0.3),
      ),
      cardTheme: CardThemeData(
        color: almostBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF1A1A1A),
            width: 0.5,
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF252525),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF252525),
        modalBackgroundColor: Color(0xFF252525),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue;
          return const Color(0xFF424242);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return appleBlue.withOpacity(0.5);
          return const Color(0xFF2A2A2A);
        }),
      ),
    );
  }
}*/

// main.dart - PARTE 1
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const ElephantBetApp());
}

class ElephantBetApp extends StatelessWidget {
  const ElephantBetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElephantBet Angola',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Config
class AppConfig {
  static const String configName = "ELEPHANTBET_AO";
  static const String language = "pt";
  static const String defaultCurrency = "kz";
  static const String operatorName = "Elephantbet AO";
  static const String phonePrefix = "+244";
  static const int staggeredStake = 50;
  static const int oddsAutoRefreshDelay = 600;
  
  static const String apiPrivateKey = "saltEbetAoPosPlayer!";
  static const String endpoint = "https://apim-elephantbet-ao.kplay.bet";
  static const String webplayerPath = "/gateway/engine/webplayer/prod/v2/webplayer";
  static const String sportsbookPath = "/gateway/prod/sportsbook/api/v1";
  
  static const String authService = "https://auth-elephantbet-ao.kplay.bet/";
  static const String authId = "pos-p";
  static const String authKey = "4525135a-7b51-4d1e-9799-c3a1154494b4";
  static const String authUsername = "pos-player-ebet-ao@koralplay.com";
  static const String authPassword = "gqhP5UNùXerTf#E";
  
  static const List<String> operatorInfo = [
    "Mota, Tavares & Barros SA",
    "Contactos: 922 00 24 32",
    "contacto@angofoot.com"
  ];
}

// Models
class Sport {
  final int id;
  final String name;
  final int eventCount;

  Sport({required this.id, required this.name, this.eventCount = 0});

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'] ?? json['sportId'] ?? 0,
      name: json['name'] ?? json['sportName'] ?? '',
      eventCount: json['eventCount'] ?? json['events'] ?? 0,
    );
  }
}

class BettingEvent {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String? league;
  final DateTime? startTime;
  final List<Market> markets;

  BettingEvent({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.league,
    this.startTime,
    required this.markets,
  });

  factory BettingEvent.fromJson(Map<String, dynamic> json) {
    return BettingEvent(
      id: json['id'] ?? json['eventId'] ?? 0,
      homeTeam: json['homeTeam'] ?? json['home'] ?? 'Time A',
      awayTeam: json['awayTeam'] ?? json['away'] ?? 'Time B',
      league: json['league'] ?? json['competition'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      markets: (json['markets'] as List?)?.map((m) => Market.fromJson(m)).toList() ?? [],
    );
  }
}

class Market {
  final String id;
  final String name;
  final List<Outcome> outcomes;

  Market({required this.id, required this.name, required this.outcomes});

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      outcomes: (json['outcomes'] as List?)?.map((o) => Outcome.fromJson(o)).toList() ?? [],
    );
  }
}

class Outcome {
  final String id;
  final String name;
  final double odds;

  Outcome({required this.id, required this.name, required this.odds});

  factory Outcome.fromJson(Map<String, dynamic> json) {
    return Outcome(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      odds: (json['odds'] ?? json['price'] ?? 1.0).toDouble(),
    );
  }
}

class Bet {
  final int eventId;
  final String outcomeId;
  final double odd;
  final String outcomeName;
  final String homeTeam;
  final String awayTeam;
  final String marketName;

  Bet({
    required this.eventId,
    required this.outcomeId,
    required this.odd,
    required this.outcomeName,
    required this.homeTeam,
    required this.awayTeam,
    required this.marketName,
  });
}

// API Service
class ApiService {
  String? _authToken;
  
  Future<void> authenticate() async {
    try {
      final authString = base64Encode(
        utf8.encode('${AppConfig.authId}:${AppConfig.authKey}')
      );
      
      final response = await http.post(
        Uri.parse('${AppConfig.authService}oauth/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic $authString',
        },
        body: {
          'grant_type': 'password',
          'username': AppConfig.authUsername,
          'password': AppConfig.authPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authToken = data['access_token'];
      } else {
        throw Exception('Falha na autenticação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao autenticar: $e');
    }
  }

  Future<List<Sport>> getSports() async {
    try {
      final url = '${AppConfig.endpoint}${AppConfig.sportsbookPath}/sports';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((s) => Sport.fromJson(s)).toList();
      } else {
        throw Exception('Erro ao carregar esportes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar esportes: $e');
    }
  }

  Future<List<BettingEvent>> getEvents(int sportId) async {
    try {
      final url = '${AppConfig.endpoint}${AppConfig.sportsbookPath}/events?sportId=$sportId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => BettingEvent.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar eventos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar eventos: $e');
    }
  }

  Future<Map<String, dynamic>> placeBet(List<Bet> bets, double stake) async {
    try {
      final totalOdds = bets.fold<double>(1.0, (acc, bet) => acc * bet.odd);
      final potentialWin = stake * totalOdds;

      final betData = {
        'stake': stake,
        'currency': AppConfig.defaultCurrency,
        'betType': bets.length > 1 ? 'multiple' : 'single',
        'selections': bets.map((bet) => {
          'eventId': bet.eventId,
          'outcomeId': bet.outcomeId,
          'odds': bet.odd,
          'marketName': bet.marketName,
          'outcomeName': bet.outcomeName,
        }).toList(),
        'totalOdds': totalOdds,
        'potentialWin': potentialWin,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final url = '${AppConfig.endpoint}${AppConfig.webplayerPath}/bet/place';
      
      final response = await http.post(
        Uri.parse(url),
        headers: _buildHeaders(),
        body: json.encode(betData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao fazer aposta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao processar aposta: $e');
    }
  }

  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'X-API-Key': AppConfig.apiPrivateKey,
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _apiService.authenticate();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(apiService: _apiService),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao conectar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        await Future.delayed(const Duration(seconds: 3));
        _initialize();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🐘', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              const Text(
                'ELEPHANTBET',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Zone Angola',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Conectando ao servidor...',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// main.dart - PARTE 2 (Continuação - adicione após a Parte 1)

// Home Page
class HomePage extends StatefulWidget {
  final ApiService apiService;

  const HomePage({Key? key, required this.apiService}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Sport> _sports = [];
  bool _isLoading = true;
  String? _error;
  DateTime _lastUpdate = DateTime.now();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadSports();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      Duration(seconds: AppConfig.oddsAutoRefreshDelay),
      (_) => _loadSports(),
    );
  }

  Future<void> _loadSports() async {
    try {
      final sports = await widget.apiService.getSports();
      if (mounted) {
        setState(() {
          _sports = sports;
          _isLoading = false;
          _error = null;
          _lastUpdate = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getSportIcon(String sportName) {
    final icons = {
      'Futebol': '⚽',
      'Basquetebol': '🏀',
      'Ténis': '🎾',
      'Ango 12': '🎰',
    };
    return icons[sportName] ?? '🏆';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '🐘 ELEPHANTBET',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Zone Angola',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    ...AppConfig.operatorInfo.map((info) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        info,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    )),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatusItem(
                      label: 'ESTADO',
                      value: 'Conectado',
                      color: Colors.green,
                    ),
                    _StatusItem(
                      label: 'ATUALIZAÇÃO',
                      value: '${_lastUpdate.hour.toString().padLeft(2, '0')}:${_lastUpdate.minute.toString().padLeft(2, '0')}',
                      color: const Color(0xFF667eea),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, size: 60, color: Colors.white),
                                  const SizedBox(height: 20),
                                  Text(_error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _loadSports,
                                    child: const Text('Tentar Novamente'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  '⚽ Esportes Disponíveis',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: _sports.length,
                                  itemBuilder: (context, index) {
                                    final sport = _sports[index];
                                    return _SportCard(
                                      sport: sport,
                                      icon: _getSportIcon(sport.name),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EventsPage(
                                              apiService: widget.apiService,
                                              sport: sport,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadSports,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SportCard extends StatelessWidget {
  final Sport sport;
  final String icon;
  final VoidCallback onTap;

  const _SportCard({
    required this.sport,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sport.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${sport.eventCount} eventos disponíveis',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}

// Events Page
class EventsPage extends StatefulWidget {
  final ApiService apiService;
  final Sport sport;

  const EventsPage({
    Key? key,
    required this.apiService,
    required this.sport,
  }) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<BettingEvent> _events = [];
  List<Bet> _selectedBets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await widget.apiService.getEvents(widget.sport.id);
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _toggleBet(Bet bet) {
    setState(() {
      final existingIndex = _selectedBets.indexWhere(
        (b) => b.eventId == bet.eventId,
      );

      if (existingIndex >= 0) {
        if (_selectedBets[existingIndex].outcomeId == bet.outcomeId) {
          _selectedBets.removeAt(existingIndex);
        } else {
          _selectedBets[existingIndex] = bet;
        }
      } else {
        _selectedBets.add(bet);
      }
    });
  }

  bool _isSelected(int eventId, String outcomeId) {
    return _selectedBets.any(
      (b) => b.eventId == eventId && b.outcomeId == outcomeId,
    );
  }

  void _showBetSlip() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BetSlipSheet(
        bets: _selectedBets,
        apiService: widget.apiService,
        onBetRemoved: (index) {
          setState(() {
            _selectedBets.removeAt(index);
          });
        },
        onBetPlaced: () {
          setState(() {
            _selectedBets.clear();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sport.name),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.white),
                          const SizedBox(height: 20),
                          Text(_error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadEvents,
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _events.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum evento disponível',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          final mainMarket = event.markets.firstWhere(
                            (m) => m.name == '1X2' || m.name == 'Match Winner',
                            orElse: () => event.markets.isNotEmpty
                                ? event.markets.first
                                : Market(id: '', name: '', outcomes: []),
                          );

                          if (mainMarket.outcomes.isEmpty) return const SizedBox();

                          return _EventCard(
                            event: event,
                            market: mainMarket,
                            onOutcomeSelected: (outcome) {
                              final bet = Bet(
                                eventId: event.id,
                                outcomeId: outcome.id,
                                odd: outcome.odds,
                                outcomeName: outcome.name,
                                homeTeam: event.homeTeam,
                                awayTeam: event.awayTeam,
                                marketName: mainMarket.name,
                              );
                              _toggleBet(bet);
                            },
                            isSelected: (outcomeId) => _isSelected(event.id, outcomeId),
                          );
                        },
                      ),
      ),
      floatingActionButton: _selectedBets.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showBetSlip,
              backgroundColor: const Color(0xFF667eea),
              icon: const Icon(Icons.shopping_cart),
              label: Text('Boletim (${_selectedBets.length})'),
            )
          : null,
    );
  }
}

class _EventCard extends StatelessWidget {
  final BettingEvent event;
  final Market market;
  final Function(Outcome) onOutcomeSelected;
  final bool Function(String) isSelected;

  const _EventCard({
    required this.event,
    required this.market,
    required this.onOutcomeSelected,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.homeTeam} vs ${event.awayTeam}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (event.league != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          event.league!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (event.startTime != null)
                  Text(
                    '${event.startTime!.hour.toString().padLeft(2, '0')}:${event.startTime!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF667eea),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: market.outcomes.map((outcome) {
                final selected = isSelected(outcome.id);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onOutcomeSelected(outcome),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF667eea) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? const Color(0xFF667eea) : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            outcome.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            outcome.odds.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.white : const Color(0xFF667eea),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Bet Slip Sheet
class BetSlipSheet extends StatefulWidget {
  final List<Bet> bets;
  final ApiService apiService;
  final Function(int) onBetRemoved;
  final VoidCallback onBetPlaced;

  const BetSlipSheet({
    Key? key,
    required this.bets,
    required this.apiService,
    required this.onBetRemoved,
    required this.onBetPlaced,
  }) : super(key: key);

  @override
  State<BetSlipSheet> createState() => _BetSlipSheetState();
}

class _BetSlipSheetState extends State<BetSlipSheet> {
  final TextEditingController _stakeController = TextEditingController();
  bool _isPlacingBet = false;

  @override
  void dispose() {
    _stakeController.dispose();
    super.dispose();
  }

  double get _totalOdds {
    return widget.bets.fold<double>(1.0, (acc, bet) => acc * bet.odd);
  }

  double get _stake {
    return double.tryParse(_stakeController.text) ?? 0;
  }

  double get _potentialWin {
    return _stake * _totalOdds;
  }

  Future<void> _placeBet() async {
    if (_stake <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um valor válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingBet = true;
    });

    try {
      await widget.apiService.placeBet(widget.bets, _stake);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aposta realizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onBetPlaced();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer aposta: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingBet = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Boletim de Aposta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.bets.length,
                itemBuilder: (context, index) {
                  final bet = widget.bets[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${bet.homeTeam} vs ${bet.awayTeam}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${bet.marketName}: ${bet.outcomeName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Odd: ${bet.odd.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF667eea),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              widget.onBetRemoved(index);
                              if (widget.bets.isEmpty) {
                                Navigator.pop(context);
                              } else {
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total de Odds:', style: TextStyle(fontSize: 16)),
                        Text(
                          _totalOdds.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _stakeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Valor da Aposta (${AppConfig.defaultCurrency.toUpperCase()})',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Possível Ganho:', style: TextStyle(fontSize: 16)),
                        Text(
                          '${_potentialWin.toStringAsFixed(2)} ${AppConfig.defaultCurrency.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isPlacingBet ? null : _placeBet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isPlacingBet
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Fazer Aposta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}