import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../models/usuario.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  Usuario? _usuario;
  bool _isLoading = false;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _usuario != null;

  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.login(email, senha);
      
      if (data['usuario'] != null) {
        _usuario = Usuario.fromJson(data['usuario']);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Assuming register expects: String email, String senha, String nome
      final data = await _authService.register(
      userData['nome'],
      userData['email'],
      userData['senha'],
);

      
      if (data['usuario'] != null) {
        _usuario = Usuario.fromJson(data['usuario']);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _usuario = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (isLoggedIn) {
      final userData = await _authService.getUserData();
if (userData != null) {
  _usuario = Usuario.fromJson(userData);
}

      notifyListeners();
    }
    
    return isLoggedIn;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

