import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';
import '../models/transacao.dart';

class TransacaoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Transacao> _transacoes = [];
  bool _isLoading = false;
  String? _error;

  List<Transacao> get transacoes => _transacoes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTransacoes({
    DateTime? dataInicio,
    DateTime? dataFim,
    String? tipo,
    int? categoriaId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String endpoint = ApiEndpoints.transacoes;
      List<String> queryParams = [];

      if (dataInicio != null) {
        queryParams.add('data_inicio=${dataInicio.toIso8601String().split('T')[0]}');
      }
      if (dataFim != null) {
        queryParams.add('data_fim=${dataFim.toIso8601String().split('T')[0]}');
      }
      if (tipo != null) {
        queryParams.add('tipo=$tipo');
      }
      if (categoriaId != null) {
        queryParams.add('categoria_id=$categoriaId');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint);
      final data = _apiService.handleResponse(response);

      _transacoes = (data as List)
          .map((json) => Transacao.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarTransacao(Transacao transacao) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ✅ CORREÇÃO: Usar toJsonCreate() ao invés de toJson()
      final response = await _apiService.post(
        ApiEndpoints.transacoes,
        transacao.toJsonCreate(),  // ✅ Método correto que envia apenas campos necessários
      );
      
      final data = _apiService.handleResponse(response);
      final novaTransacao = Transacao.fromJson(data);
      
      _transacoes.insert(0, novaTransacao);
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

  Future<bool> atualizarTransacao(int id, Transacao transacao) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        '${ApiEndpoints.transacoes}/$id',
        transacao.toJson(),  // Para atualização, usa toJson() completo
      );
      
      final data = _apiService.handleResponse(response);
      final transacaoAtualizada = Transacao.fromJson(data);
      
      final index = _transacoes.indexWhere((t) => t.id == id);
      if (index != -1) {
        _transacoes[index] = transacaoAtualizada;
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

  Future<bool> excluirTransacao(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.delete('${ApiEndpoints.transacoes}/$id');
      
      _transacoes.removeWhere((t) => t.id == id);
      
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

  double get totalReceitas {
    return _transacoes
        .where((t) => t.isReceita && t.efetivada)
        .fold(0, (sum, t) => sum + t.valor);
  }

  double get totalDespesas {
    return _transacoes
        .where((t) => t.isDespesa && t.efetivada)
        .fold(0, (sum, t) => sum + t.valor);
  }

  double get saldo => totalReceitas - totalDespesas;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}