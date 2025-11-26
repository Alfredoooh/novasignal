import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';

class DocumentService {
  static const String apiBaseUrl = 
      'https://alfredoooh.github.io/novasignal/API/';

  Future<List<DocumentModel>> fetchDocuments() async {
    print('🚀 INICIANDO FETCH');
    
    try {
      final url = '${apiBaseUrl}documents.json';
      print('📡 Fazendo request para: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
      );

      print('✅ Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('📦 Recebido ${response.body.length} bytes');
        
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('✅ JSON decodificado com sucesso');

        if (jsonData.containsKey('documents')) {
          final List<dynamic> documentsJson = jsonData['documents'];
          print('📚 Encontrados ${documentsJson.length} documentos no JSON');

          final List<DocumentModel> documents = [];
          
          for (int i = 0; i < documentsJson.length; i++) {
            try {
              final doc = DocumentModel.fromJson(documentsJson[i]);
              documents.add(doc);
              print('✅ Documento $i processado: ${doc.name}');
            } catch (e) {
              print('❌ Erro no documento $i: $e');
              // Continua processando os outros
            }
          }

          if (documents.isEmpty) {
            throw Exception('Nenhum documento foi processado');
          }

          print('🎉 SUCESSO! ${documents.length} documentos carregados');
          return documents;
        } else {
          throw Exception('Chave "documents" não encontrada no JSON');
        }
      } else {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('💥 ERRO FINAL: $e');
      rethrow;
    }
  }
}