class Alerta {
  final String tipo;
  final String severidade;
  final String titulo;
  final String mensagem;
  final Map<String, dynamic>? dadosAdicionais;

  Alerta({
    required this.tipo,
    required this.severidade,
    required this.titulo,
    required this.mensagem,
    this.dadosAdicionais,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      tipo: json['tipo'],
      severidade: json['severidade'],
      titulo: json['titulo'],
      mensagem: json['mensagem'],
      dadosAdicionais: Map<String, dynamic>.from(json)
        ..removeWhere((key, value) =>
            ['tipo', 'severidade', 'titulo', 'mensagem'].contains(key)),
    );
  }
}

