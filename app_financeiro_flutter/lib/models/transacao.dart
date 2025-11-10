import 'categoria.dart';

class Transacao {
  final int? id;
  final int usuarioId;
  final int categoriaId;
  final int contaId;
  final String tipo;
  final double valor;
  final String? descricao;
  final DateTime dataTransacao;
  final DateTime? dataCriacao;
  final bool recorrente;
  final String? frequencia;
  final int? parcelas;
  final int? parcelaAtual;
  final int? transacaoPaiId;
  final List<String>? tags;
  final String? anexo;
  final String? observacoes;
  final bool efetivada;
  
  Categoria? categoria;
  String? contaNome;

  Transacao({
    this.id,
    required this.usuarioId,
    required this.categoriaId,
    required this.contaId,
    required this.tipo,
    required this.valor,
    this.descricao,
    required this.dataTransacao,
    this.dataCriacao,
    this.recorrente = false,
    this.frequencia,
    this.parcelas,
    this.parcelaAtual,
    this.transacaoPaiId,
    this.tags,
    this.anexo,
    this.observacoes,
    this.efetivada = true,
    this.categoria,
    this.contaNome,
  });

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
      id: json['id'],
      usuarioId: json['usuario_id'],
      categoriaId: json['categoria_id'],
      contaId: json['conta_id'],
      tipo: json['tipo'],
      valor: (json['valor'] as num).toDouble(),
      descricao: json['descricao'],
      dataTransacao: DateTime.parse(json['data_transacao']),
      dataCriacao: json['data_criacao'] != null
          ? DateTime.parse(json['data_criacao'])
          : null,
      recorrente: json['recorrente'] ?? false,
      frequencia: json['frequencia'],
      parcelas: json['parcelas'],
      parcelaAtual: json['parcela_atual'],
      transacaoPaiId: json['transacao_pai_id'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      anexo: json['anexo'],
      observacoes: json['observacoes'],
      efetivada: json['efetivada'] ?? true,
      categoria: json['categoria'] != null
          ? Categoria.fromJson(json['categoria'])
          : null,
      contaNome: json['conta_nome'],
    );
  }

  // ✅ NOVO MÉTODO: Envia APENAS os campos que o backend espera para criação
  Map<String, dynamic> toJsonCreate() {
    return {
      'descricao': descricao ?? '',
      'valor': valor,  // ✅ Já é double, não String
      'tipo': tipo,
      'data': dataTransacao.toIso8601String().split('T')[0],  // Backend espera 'data'
      'categoria_id': categoriaId,
      'efetivada': efetivada,
      'observacoes': observacoes,
    };
  }

  // Método toJson completo para atualização e outras operações
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'categoria_id': categoriaId,
      'conta_id': contaId,
      'tipo': tipo,
      'valor': valor,
      'descricao': descricao,
      'data_transacao': dataTransacao.toIso8601String().split('T')[0],
      if (dataCriacao != null)
        'data_criacao': dataCriacao!.toIso8601String(),
      'recorrente': recorrente,
      'frequencia': frequencia,
      'parcelas': parcelas,
      'parcela_atual': parcelaAtual,
      'transacao_pai_id': transacaoPaiId,
      'tags': tags,
      'anexo': anexo,
      'observacoes': observacoes,
      'efetivada': efetivada,
    };
  }

  bool get isReceita => tipo == 'receita';
  bool get isDespesa => tipo == 'despesa';
  bool get isTransferencia => tipo == 'transferencia';
  
  String get parcelasTexto {
    if (parcelas != null && parcelaAtual != null) {
      return '$parcelaAtual/$parcelas';
    }
    return '';
  }

  Transacao copyWith({
    int? id,
    int? usuarioId,
    int? categoriaId,
    int? contaId,
    String? tipo,
    double? valor,
    String? descricao,
    DateTime? dataTransacao,
    DateTime? dataCriacao,
    bool? recorrente,
    String? frequencia,
    int? parcelas,
    int? parcelaAtual,
    int? transacaoPaiId,
    List<String>? tags,
    String? anexo,
    String? observacoes,
    bool? efetivada,
    Categoria? categoria,
    String? contaNome,
  }) {
    return Transacao(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      categoriaId: categoriaId ?? this.categoriaId,
      contaId: contaId ?? this.contaId,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      descricao: descricao ?? this.descricao,
      dataTransacao: dataTransacao ?? this.dataTransacao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      recorrente: recorrente ?? this.recorrente,
      frequencia: frequencia ?? this.frequencia,
      parcelas: parcelas ?? this.parcelas,
      parcelaAtual: parcelaAtual ?? this.parcelaAtual,
      transacaoPaiId: transacaoPaiId ?? this.transacaoPaiId,
      tags: tags ?? this.tags,
      anexo: anexo ?? this.anexo,
      observacoes: observacoes ?? this.observacoes,
      efetivada: efetivada ?? this.efetivada,
      categoria: categoria ?? this.categoria,
      contaNome: contaNome ?? this.contaNome,
    );
  }
}