import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';

class DocumentService {
  static const String apiBaseUrl = 
      'https://alfredoooh.github.io/database/API/';

  Future<List<DocumentModel>> fetchDocuments() async {
    List<DocumentModel> allDocuments = [];

    try {
      final jsonFiles = [
        'documents.json',
      ];

      for (String fileName in jsonFiles) {
        try {
          final url = '$apiBaseUrl$fileName';
          print('🔍 Buscando: $url');
          
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
            },
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Timeout na conexão');
            },
          );

          if (response.statusCode == 200) {
            print('✅ Arquivo carregado: $fileName');
            
            try {
              final Map<String, dynamic> jsonData = json.decode(response.body);

              if (jsonData.containsKey('documents')) {
                final List<dynamic> documentsJson = jsonData['documents'];
                final documents = documentsJson
                    .map((json) {
                      try {
                        return DocumentModel.fromJson(json);
                      } catch (e) {
                        print('❌ Erro ao processar documento: $e');
                        return null;
                      }
                    })
                    .whereType<DocumentModel>()
                    .toList();

                allDocuments.addAll(documents);
                print('📄 ${documents.length} documentos carregados de $fileName');
              }
            } catch (parseError) {
              print('❌ Erro ao fazer parse do JSON: $parseError');
              continue;
            }
          } else if (response.statusCode == 404) {
            print('⚠️ Arquivo não encontrado: $fileName');
            continue;
          } else {
            print('⚠️ Status ${response.statusCode} para $fileName');
            continue;
          }
        } catch (fileError) {
          print('❌ Erro ao buscar $fileName: $fileError');
          continue;
        }
      }

      if (allDocuments.isEmpty) {
        throw Exception('Nenhum documento encontrado nos arquivos JSON');
      }

      print('✅ Total de documentos carregados: ${allDocuments.length}');
      return allDocuments;

    } on http.ClientException {
      throw Exception('Erro de rede. Verifique sua conexão com a internet.');
    } catch (e) {
      throw Exception('Erro ao carregar documentos: ${e.toString()}');
    }
  }
}