class Categoria {
  final int id;
  final int? usuarioId;
  final String nome;
  final String tipo;
  final String? icone;
  final String? cor;
  final String? descricao;
  final bool ativa;

  Categoria({
    required this.id,
    this.usuarioId,
    required this.nome,
    required this.tipo,
    this.icone,
    this.cor,
    this.descricao,
    this.ativa = true,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      usuarioId: json['usuario_id'],
      nome: json['nome'],
      tipo: json['tipo'],
      icone: json['icone'],
      cor: json['cor'],
      descricao: json['descricao'],
      ativa: json['ativa'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nome': nome,
      'tipo': tipo,
      'icone': icone,
      'cor': cor,
      'descricao': descricao,
      'ativa': ativa,
    };
  }

  bool get isReceita => tipo == 'receita';
  bool get isDespesa => tipo == 'despesa';
  bool get isPadrao => usuarioId == null;

  Categoria copyWith({
    int? id,
    int? usuarioId,
    String? nome,
    String? tipo,
    String? icone,
    String? cor,
    String? descricao,
    bool? ativa,
  }) {
    return Categoria(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      icone: icone ?? this.icone,
      cor: cor ?? this.cor,
      descricao: descricao ?? this.descricao,
      ativa: ativa ?? this.ativa,
    );
  }
}

