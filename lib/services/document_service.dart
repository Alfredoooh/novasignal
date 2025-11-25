import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';

class DocumentService {
  // URL do seu arquivo JSON no GitHub (raw)
  // Exemplo: https://raw.githubusercontent.com/seu-usuario/seu-repo/main/documents.json
  static const String apiUrl = 
      'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/documents.json';

  Future<List<DocumentModel>> fetchDocuments() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData.containsKey('documents')) {
          final List<dynamic> documentsJson = jsonData['documents'];
          return documentsJson
              .map((json) => DocumentModel.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid JSON structure: missing "documents" key');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Documents not found. Please check the API URL.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Failed to load documents: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid data format received from server.');
    } catch (e) {
      throw Exception('Error loading documents: ${e.toString()}');
    }
  }
}