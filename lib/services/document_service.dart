import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';

class DocumentService {
  // URL da pasta API no GitHub
  static const String apiBaseUrl = 
      'https://raw.githubusercontent.com/Alfredoooh/novasignal/main/API/';

  Future<List<DocumentModel>> fetchDocuments() async {
    List<DocumentModel> allDocuments = [];

    try {
      // Lista de possíveis arquivos JSON na pasta API
      // Você pode adicionar mais nomes aqui conforme criar novos JSONs
      final jsonFiles = [
        'documents.json',
        'templates.json',
        'docs.json',
        'files.json',
        'data.json',
      ];

      for (String fileName in jsonFiles) {
        try {
          final url = '$apiBaseUrl$fileName';
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
            },
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

          if (response.statusCode == 200) {
            try {
              final Map<String, dynamic> jsonData = json.decode(response.body);
              
              // Procura pela chave "documents" no JSON
              if (jsonData.containsKey('documents')) {
                final List<dynamic> documentsJson = jsonData['documents'];
                final documents = documentsJson
                    .map((json) {
                      try {
                        return DocumentModel.fromJson(json);
                      } catch (e) {
                        print('Error parsing document: $e');
                        return null;
                      }
                    })
                    .whereType<DocumentModel>()
                    .toList();
                
                allDocuments.addAll(documents);
                print('Loaded ${documents.length} documents from $fileName');
              }
            } catch (parseError) {
              print('Error parsing JSON from $fileName: $parseError');
              continue;
            }
          } else if (response.statusCode == 404) {
            // Arquivo não existe, continua para o próximo
            print('File not found: $fileName');
            continue;
          }
        } catch (fileError) {
          // Erro ao buscar arquivo específico, continua para o próximo
          print('Error fetching $fileName: $fileError');
          continue;
        }
      }

      if (allDocuments.isEmpty) {
        throw Exception('No documents found in any JSON files. Please check your API folder.');
      }

      return allDocuments;
      
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      throw Exception('Error loading documents: ${e.toString()}');
    }
  }
}