import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

class AuthService {
  static const String _userKey = 'user_data';

  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': email,
          'password': senha,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        await ApiService().setToken(data['access_token']);
        await saveUserData(data['usuario']);
        
        return data;
      } else {
        throw Exception('Erro ao fazer login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String nome,
    String email,
    String senha,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
          'moeda_padrao': 'BRL',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        await ApiService().setToken(data['access_token']);
        await saveUserData(data['usuario']);
        
        return data;
      } else {
        throw Exception('Erro ao registrar: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao registrar: $e');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await ApiService().clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
