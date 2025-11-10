import 'dart:convert';
import 'package:http/http.dart' as http;

class MLService {
  final String baseUrl;
  final String token;

  MLService({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> obterPrevisoes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ml/previsoes'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar previsões: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Map<String, dynamic>> obterAlertas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ml/alertas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar alertas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Map<String, dynamic>> obterDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ml/dashboard'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Map<String, dynamic>>> obterHistoricoAnalises({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ml/historico-analises?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['analises']);
      } else {
        throw Exception('Erro ao carregar histórico: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}

