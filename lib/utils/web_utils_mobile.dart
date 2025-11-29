import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Stub para plataformas móveis - não usado mas necessário para compilação
void registerWebViewFactory(String viewType, dynamic Function(int) callback) {
  throw UnsupportedError('Cannot register web view on mobile platform');
}

// Implementação de download para Android/iOS usando compartilhamento
Future<void> downloadHtmlFile(String htmlContent, String filename) async {
  try {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$filename.html';
    
    final file = File(filePath);
    await file.writeAsString(htmlContent);
    
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: filename,
      text: 'Documento HTML: $filename',
    );
    
    print('Arquivo HTML compartilhado com sucesso: $filePath');
  } catch (e) {
    print('Erro ao compartilhar arquivo HTML: $e');
    throw Exception('Não foi possível compartilhar o arquivo: $e');
  }
}

// Funções adicionais necessárias para o document_viewer_screen
dynamic createIFrameElement(String htmlContent) {
  throw UnsupportedError('IFrame not supported on mobile platform');
}

void addIFrameLoadListener(dynamic iframe, void Function() callback) {
  throw UnsupportedError('IFrame not supported on mobile platform');
}

void addIFrameErrorListener(dynamic iframe, void Function() callback) {
  throw UnsupportedError('IFrame not supported on mobile platform');
}