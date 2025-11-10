class Usuario {
  final int id;
  final String nome;
  final String email;
  final DateTime? dataNascimento;
  final String? telefone;
  final String? fotoPerfil;
  final String moedaPadrao;
  final DateTime? dataCriacao;
  final bool ativo;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.dataNascimento,
    this.telefone,
    this.fotoPerfil,
    this.moedaPadrao = 'BRL',
    this.dataCriacao,
    this.ativo = true,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.parse(json['data_nascimento'] as String)
          : null,
      telefone: json['telefone'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      moedaPadrao: (json['moeda_padrao'] as String?) ?? 'BRL',
      dataCriacao: json['data_criacao'] != null
          ? DateTime.parse(json['data_criacao'] as String)
          : null,
      ativo: (json['ativo'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'data_nascimento': dataNascimento?.toIso8601String(),
      'telefone': telefone,
      'foto_perfil': fotoPerfil,
      'moeda_padrao': moedaPadrao,
      'data_criacao': dataCriacao?.toIso8601String(),
      'ativo': ativo,
    };
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? email,
    DateTime? dataNascimento,
    String? telefone,
    String? fotoPerfil,
    String? moedaPadrao,
    DateTime? dataCriacao,
    bool? ativo,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      telefone: telefone ?? this.telefone,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      moedaPadrao: moedaPadrao ?? this.moedaPadrao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      ativo: ativo ?? this.ativo,
    );
  }
}