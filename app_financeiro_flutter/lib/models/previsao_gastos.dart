class PrevisaoGastos {
  final double previsaoTotal;
  final double confianca;
  final int periodoAnaliseDias;
  final int transacoesAnalisadas;
  final String tendencia;
  final List<PrevisaoCategoria> porCategoria;

  PrevisaoGastos({
    required this.previsaoTotal,
    required this.confianca,
    required this.periodoAnaliseDias,
    required this.transacoesAnalisadas,
    required this.tendencia,
    required this.porCategoria,
  });

  factory PrevisaoGastos.fromJson(Map<String, dynamic> json) {
    return PrevisaoGastos(
      previsaoTotal: (json['previsao_total'] ?? 0).toDouble(),
      confianca: (json['confianca'] ?? 0).toDouble(),
      periodoAnaliseDias: json['periodo_analise_dias'] ?? 0,
      transacoesAnalisadas: json['transacoes_analisadas'] ?? 0,
      tendencia: json['tendencia'] ?? 'estavel',
      porCategoria: (json['por_categoria'] as List<dynamic>?)
              ?.map((c) => PrevisaoCategoria.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class PrevisaoCategoria {
  final int categoriaId;
  final String categoriaNome;
  final double previsao;
  final int historicoTransacoes;

  PrevisaoCategoria({
    required this.categoriaId,
    required this.categoriaNome,
    required this.previsao,
    required this.historicoTransacoes,
  });

  factory PrevisaoCategoria.fromJson(Map<String, dynamic> json) {
    return PrevisaoCategoria(
      categoriaId: json['categoria_id'],
      categoriaNome: json['categoria_nome'],
      previsao: (json['previsao'] ?? 0).toDouble(),
      historicoTransacoes: json['historico_transacoes'] ?? 0,
    );
  }
}

