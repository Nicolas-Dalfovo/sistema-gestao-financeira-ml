import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  bool _tokenLoaded = false;

  Future<void> setToken(String token) async {
    print('🔑 ApiService.setToken() chamado com token: ${token.substring(0, 20)}...');
    _token = token;
    _tokenLoaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    print('✅ Token salvo no SharedPreferences com chave: ${AppConstants.tokenKey}');
  }

  Future<void> loadToken() async {
    if (_tokenLoaded) {
      print('ℹ️ Token já carregado, pulando loadToken()');
      return;
    }
    
    print('📥 Carregando token do SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
    _tokenLoaded = true;
    
    if (_token != null) {
      print('✅ Token carregado: ${_token!.substring(0, 20)}...');
    } else {
      print('❌ NENHUM TOKEN ENCONTRADO no SharedPreferences!');
    }
  }

  Future<void> clearToken() async {
    print('🗑️ Limpando token...');
    _token = null;
    _tokenLoaded = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    print('✅ Token removido');
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
      print('🔐 Header Authorization adicionado');
    } else if (includeAuth && _token == null) {
      print('⚠️ AVISO: includeAuth=true mas _token é null!');
    }

    return headers;
  }

  Future<http.Response> get(String endpoint, {bool includeAuth = true}) async {
    print('📡 GET $endpoint (includeAuth: $includeAuth)');
    
    if (includeAuth && !_tokenLoaded) {
      await loadToken();
    }
    
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    print('🌐 URL completa: $url');
    
    try {
      final headers = _getHeaders(includeAuth: includeAuth);
      print('📋 Headers: ${headers.keys.join(", ")}');
      
      final response = await http
          .get(url, headers: headers)
          .timeout(Duration(seconds: AppConstants.requestTimeout));
      
      print('📥 Resposta: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Erro na requisição GET: $e');
      throw Exception('Erro na requisição GET: $e');
    }
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    print('📡 POST $endpoint (includeAuth: $includeAuth)');
    
    if (includeAuth && !_tokenLoaded) {
      await loadToken();
    }
    
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    print('🌐 URL completa: $url');
    print('📦 Body: ${jsonEncode(data)}');
    
    try {
      final headers = _getHeaders(includeAuth: includeAuth);
      print('📋 Headers: ${headers.keys.join(", ")}');
      
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: AppConstants.requestTimeout));
      
      print('📥 Resposta: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Erro na requisição POST: $e');
      throw Exception('Erro na requisição POST: $e');
    }
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    if (includeAuth && !_tokenLoaded) {
      await loadToken();
    }
    
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    
    try {
      final response = await http
          .put(
            url,
            headers: _getHeaders(includeAuth: includeAuth),
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: AppConstants.requestTimeout));
      
      return response;
    } catch (e) {
      throw Exception('Erro na requisição PUT: $e');
    }
  }

  Future<http.Response> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    if (includeAuth && !_tokenLoaded) {
      await loadToken();
    }
    
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    
    try {
      final response = await http
          .delete(url, headers: _getHeaders(includeAuth: includeAuth))
          .timeout(Duration(seconds: AppConstants.requestTimeout));
      
      return response;
    } catch (e) {
      throw Exception('Erro na requisição DELETE: $e');
    }
  }

  dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      print('❌ ERRO 401: Não autorizado!');
      throw Exception('Não autorizado. Faça login novamente.');
    } else if (response.statusCode == 404) {
      throw Exception('Recurso não encontrado.');
    } else if (response.statusCode == 422) {
      final error = jsonDecode(response.body);
      print('❌ ERRO 422: ${error['detail']}');
      throw Exception(error['detail'] ?? 'Dados inválidos.');
    } else if (response.statusCode >= 500) {
      throw Exception('Erro no servidor. Tente novamente mais tarde.');
    } else {
      throw Exception('Erro: ${response.statusCode}');
    }
  }
}