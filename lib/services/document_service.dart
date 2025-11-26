import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';

class DocumentService {
  static const String apiBaseUrl = 
      'https://alfredoooh.github.io/database/API/';

  Future<List<DocumentModel>> fetchDocuments() async {
    print('🚀 INICIANDO FETCH DE DOCUMENTOS');
    List<DocumentModel> allDocuments = [];

    try {
      final url = '${apiBaseUrl}documents.json';
      print('📡 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('⏱️ Timeout - Servidor não respondeu');
        },
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Headers: ${response.headers}');
      print('📥 Body length: ${response.body.length}');
      print('📥 Body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        try {
          // Tenta decodificar o JSON
          final dynamic decodedData = json.decode(response.body);
          print('✅ JSON decodificado com sucesso');
          print('📦 Tipo de dados: ${decodedData.runtimeType}');

          List<dynamic> documentsJson;

          // Verifica se é um objeto com chave "documents" ou array direto
          if (decodedData is Map<String, dynamic>) {
            print('📋 É um Map, procurando chave "documents"');
            
            if (decodedData.containsKey('documents')) {
              documentsJson = decodedData['documents'] as List<dynamic>;
              print('✅ Encontrou chave "documents" com ${documentsJson.length} itens');
            } else {
              print('❌ Chave "documents" não encontrada');
              print('🔑 Chaves disponíveis: ${decodedData.keys.toList()}');
              throw Exception('Estrutura JSON inválida: chave "documents" não encontrada');
            }
          } else if (decodedData is List) {
            print('📋 É um Array direto');
            documentsJson = decodedData;
          } else {
            throw Exception('Tipo de JSON não suportado: ${decodedData.runtimeType}');
          }

          print('🔄 Processando ${documentsJson.length} documentos...');

          for (int i = 0; i < documentsJson.length; i++) {
            try {
              final docJson = documentsJson[i];
              print('📄 Documento $i: ${docJson.toString().substring(0, docJson.toString().length > 100 ? 100 : docJson.toString().length)}');
              
              final document = DocumentModel.fromJson(docJson);
              allDocuments.add(document);
              print('✅ Documento $i processado: ${document.name}');
            } catch (docError, stackTrace) {
              print('❌ Erro ao processar documento $i: $docError');
              print('📚 StackTrace: $stackTrace');
              print('📄 JSON problemático: ${documentsJson[i]}');
              // Continua processando os outros
            }
          }

          if (allDocuments.isEmpty) {
            throw Exception('❌ Nenhum documento foi processado com sucesso');
          }

          print('✅✅✅ SUCESSO! ${allDocuments.length} documentos carregados');
          return allDocuments;

        } catch (parseError, stackTrace) {
          print('❌ ERRO NO PARSE DO JSON: $parseError');
          print('📚 StackTrace: $stackTrace');
          print('📄 Body completo: ${response.body}');
          throw Exception('Erro ao processar JSON: $parseError');
        }
      } else if (response.statusCode == 404) {
        throw Exception('❌ Arquivo não encontrado (404). Verifique se o arquivo existe em: $url');
      } else {
        throw Exception('❌ Erro HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

    } on http.ClientException catch (e) {
      print('❌ ERRO DE REDE: $e');
      throw Exception('Erro de conexão. Verifique sua internet e tente novamente.');
    } catch (e, stackTrace) {
      print('❌ ERRO GERAL: $e');
      print('📚 StackTrace: $stackTrace');
      throw Exception('Erro ao carregar documentos: $e');
    }
  }
}