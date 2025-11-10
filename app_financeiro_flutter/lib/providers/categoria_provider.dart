import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';
import '../models/categoria.dart';

class CategoriaProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Categoria> _categorias = [];
  bool _isLoading = false;
  String? _error;

  List<Categoria> get categorias => _categorias;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Categoria> get categoriasReceita =>
      _categorias.where((c) => c.isReceita && c.ativa).toList();

  List<Categoria> get categoriasDespesa =>
      _categorias.where((c) => c.isDespesa && c.ativa).toList();

  // ✅ CORREÇÃO: Adicionar parâmetro forceRefresh para limpar cache
  Future<void> fetchCategorias({bool forceRefresh = false}) async {
    // Se não forçar refresh e já tiver categorias, não busca novamente
    if (!forceRefresh && _categorias.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndpoints.categorias);
      final data = _apiService.handleResponse(response);

      // ✅ CORREÇÃO: Limpar lista antes de adicionar novas categorias
      _categorias.clear();
      
      _categorias = (data as List)
          .map((json) => Categoria.fromJson(json))
          .toList();

      print('Categorias carregadas: ${_categorias.length}');
      for (var cat in _categorias) {
        print('  - ID: ${cat.id}, Nome: ${cat.nome}, Tipo: ${cat.tipo}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar categorias: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarCategoria(Categoria categoria) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiEndpoints.categorias,
        categoria.toJson(),
      );
      
      final data = _apiService.handleResponse(response);
      final novaCategoria = Categoria.fromJson(data);
      
      _categorias.add(novaCategoria);
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

  Future<bool> atualizarCategoria(int id, Categoria categoria) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        '${ApiEndpoints.categorias}/$id',
        categoria.toJson(),
      );
      
      final data = _apiService.handleResponse(response);
      final categoriaAtualizada = Categoria.fromJson(data);
      
      final index = _categorias.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categorias[index] = categoriaAtualizada;
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

  Future<bool> deletarCategoria(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.delete('${ApiEndpoints.categorias}/$id');
      
      _categorias.removeWhere((c) => c.id == id);
      
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

  Categoria? getCategoriaById(int id) {
    try {
      return _categorias.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ✅ NOVO MÉTODO: Limpar cache manualmente
  void clearCache() {
    _categorias.clear();
    notifyListeners();
  }
}