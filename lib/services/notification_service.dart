import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

// ─────────────────────────────────────────────────────────
// NOTIFICATION SERVICE
// Notificações locais + download de documentos para o device
// ─────────────────────────────────────────────────────────

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  // ── Canal Android ───────────────────────────────────────
  static const _channel = AndroidNotificationChannel(
    'aria_channel',
    'Aria – Documentos',
    description: 'Notificações de exportação e downloads',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ── Inicializar ─────────────────────────────────────────
  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );
    // Criar canal no Android 8+
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
    _ready = true;
  }

  void _onTap(NotificationResponse r) {
    // Payload = caminho do ficheiro guardado → abre-o
    final path = r.payload;
    if (path != null && path.isNotEmpty) {
      OpenFile.open(path);
    }
  }

  // ── Pedir permissão (Android 13+) ──────────────────────
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  // ── Notificação simples ─────────────────────────────────
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool vibrate = true,
  }) async {
    if (!_ready) await init();
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: vibrate,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // ── Notificação com progresso ───────────────────────────
  Future<void> showProgress({
    required int id,
    required String title,
    required int progress,   // 0-100
    String body = '',
  }) async {
    if (!_ready) await init();
    await _plugin.show(
      id,
      title,
      body.isEmpty ? '$progress%' : body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.low,
          priority: Priority.low,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> cancel(int id) async => _plugin.cancel(id);

  // ── Guardar ficheiro no armazenamento público ───────────
  // Salva em Downloads/ e notifica com opção de abrir
  Future<String?> saveAndNotify({
    required Uint8List bytes,
    required String fileName,     // ex: 'relatorio.pdf'
    required String mimeType,     // ex: 'application/pdf'
    String notifTitle  = 'Documento guardado',
    String notifBody   = '',
    int notifId        = 9000,
  }) async {
    try {
      // Notificar que está a guardar
      await showProgress(id: notifId, title: 'A guardar…', progress: 30);

      // Obter pasta de Downloads
      String? dirPath;
      if (Platform.isAndroid) {
        // Android: /storage/emulated/0/Download/
        dirPath = '/storage/emulated/0/Download';
        final dir = Directory(dirPath);
        if (!await dir.exists()) {
          // Fallback para diretório externo acessível
          final ext = await getExternalStorageDirectory();
          dirPath = ext?.path ?? (await getApplicationDocumentsDirectory()).path;
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        dirPath = dir.path;
      }

      // Evitar conflitos de nome
      String finalPath = '$dirPath/$fileName';
      int counter = 1;
      while (await File(finalPath).exists()) {
        final dot = fileName.lastIndexOf('.');
        if (dot != -1) {
          finalPath = '$dirPath/${fileName.substring(0, dot)}_$counter${fileName.substring(dot)}';
        } else {
          finalPath = '$dirPath/${fileName}_$counter';
        }
        counter++;
      }

      await showProgress(id: notifId, title: 'A guardar…', progress: 70);
      await File(finalPath).writeAsBytes(bytes);

      // Notificar sucesso com opção de abrir
      final body = notifBody.isNotEmpty
          ? notifBody
          : 'Guardado em Downloads/$fileName — toca para abrir';
      await cancel(notifId);
      await show(
        id: notifId + 1,
        title: notifTitle,
        body: body,
        payload: finalPath,
      );

      debugPrint('Ficheiro guardado: $finalPath');
      return finalPath;

    } catch (e) {
      await cancel(notifId);
      debugPrint('saveAndNotify error: $e');
      await show(
        id: notifId + 1,
        title: 'Erro ao guardar',
        body: 'Não foi possível guardar o ficheiro: $e',
      );
      return null;
    }
  }

  // ── Guardar PDF a partir de base64 ─────────────────────
  Future<String?> savePdfBase64({
    required String base64Data,
    required String title,
  }) async {
    final bytes    = base64Decode(base64Data);
    final safeName = title.replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();
    final fileName = '$safeName.pdf';
    return saveAndNotify(
      bytes: bytes,
      fileName: fileName,
      mimeType: 'application/pdf',
      notifTitle: '📄 PDF guardado',
      notifBody: '"$title" foi guardado em Downloads',
    );
  }

  // ── Guardar TXT ─────────────────────────────────────────
  Future<String?> saveTxt({
    required String content,
    required String title,
  }) async {
    final bytes    = utf8.encode(content) as Uint8List;
    final safeName = title.replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();
    return saveAndNotify(
      bytes: Uint8List.fromList(bytes),
      fileName: '$safeName.txt',
      mimeType: 'text/plain',
      notifTitle: '📝 Texto guardado',
      notifBody: '"$title" foi guardado em Downloads',
    );
  }
}
