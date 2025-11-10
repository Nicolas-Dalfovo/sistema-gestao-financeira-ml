class Meta {
  final int? id;
  final int usuarioId;
  final String nome;
  final String? descricao;
  final double valorAlvo;
  final double valorAtual;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String status;
  final int prioridade;
  final String? icone;
  final String? cor;
  final DateTime? dataCriacao;

  Meta({
    this.id,
    required this.usuarioId,
    required this.nome,
    this.descricao,
    required this.valorAlvo,
    this.valorAtual = 0.0,
    required this.dataInicio,
    required this.dataFim,
    this.status = 'ativa',
    this.prioridade = 1,
    this.icone,
    this.cor,
    this.dataCriacao,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      id: json['id'],
      usuarioId: json['usuario_id'],
      nome: json['nome'],
      descricao: json['descricao'],
      valorAlvo: (json['valor_alvo'] as num).toDouble(),
      valorAtual: (json['valor_atual'] as num?)?.toDouble() ?? 0.0,
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: DateTime.parse(json['data_fim']),
      status: json['status'] ?? 'ativa',
      prioridade: json['prioridade'] ?? 1,
      icone: json['icone'],
      cor: json['cor'],
      dataCriacao: json['data_criacao'] != null
          ? DateTime.parse(json['data_criacao'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'nome': nome,
      'descricao': descricao,
      'valor_alvo': valorAlvo,
      'valor_atual': valorAtual,
      'data_inicio': dataInicio.toIso8601String().split('T')[0],
      'data_fim': dataFim.toIso8601String().split('T')[0],
      'status': status,
      'prioridade': prioridade,
      'icone': icone,
      'cor': cor,
      if (dataCriacao != null) 'data_criacao': dataCriacao!.toIso8601String(),
    };
  }

  double get percentualCompleto {
    if (valorAlvo == 0) return 0;
    return (valorAtual / valorAlvo * 100).clamp(0, 100);
  }

  double get valorFaltante => (valorAlvo - valorAtual).clamp(0, double.infinity);

  bool get isAtiva => status == 'ativa';
  bool get isConcluida => status == 'concluida';
  bool get isCancelada => status == 'cancelada';
  bool get isPausada => status == 'pausada';

  int get diasRestantes {
    final now = DateTime.now();
    if (dataFim.isBefore(now)) return 0;
    return dataFim.difference(now).inDays;
  }

  int get diasDecorridos {
    final now = DateTime.now();
    return now.difference(dataInicio).inDays;
  }

  Meta copyWith({
    int? id,
    int? usuarioId,
    String? nome,
    String? descricao,
    double? valorAlvo,
    double? valorAtual,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? status,
    int? prioridade,
    String? icone,
    String? cor,
    DateTime? dataCriacao,
  }) {
    return Meta(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      valorAlvo: valorAlvo ?? this.valorAlvo,
      valorAtual: valorAtual ?? this.valorAtual,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      status: status ?? this.status,
      prioridade: prioridade ?? this.prioridade,
      icone: icone ?? this.icone,
      cor: cor ?? this.cor,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}

