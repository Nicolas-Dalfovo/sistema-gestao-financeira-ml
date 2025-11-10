import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InsightsScreen extends StatefulWidget {
  final String token;
  final String baseUrl;

  const InsightsScreen({
    Key? key,
    required this.token,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? previsao;
  List<dynamic> alertas = [];
  List<String> insights = [];
  List<String> recomendacoes = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final headers = {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      };

      // Chamar dashboard
      final dashboardResponse = await http.get(
        Uri.parse('${widget.baseUrl}/ml/dashboard'),
        headers: headers,
      );

      if (dashboardResponse.statusCode != 200) {
        throw Exception('Erro ${dashboardResponse.statusCode}: ${dashboardResponse.body}');
      }

      final dashboardData = json.decode(dashboardResponse.body);

      // Chamar previsoes
      final previsoesResponse = await http.get(
        Uri.parse('${widget.baseUrl}/ml/previsoes'),
        headers: headers,
      );

      if (previsoesResponse.statusCode != 200) {
        throw Exception('Erro ${previsoesResponse.statusCode}: ${previsoesResponse.body}');
      }

      final previsoesData = json.decode(previsoesResponse.body);

      setState(() {
        previsao = dashboardData['previsao_gastos'];
        alertas = dashboardData['alertas'] ?? [];
        insights = List<String>.from(previsoesData['insights'] ?? []);
        recomendacoes = List<String>.from(previsoesData['recomendacoes'] ?? []);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights Inteligentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarDados,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: carregarDados,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (previsao != null) _buildPrevisaoCard(),
                      const SizedBox(height: 16),
                      _buildAlertasSection(),
                      const SizedBox(height: 16),
                      if (insights.isNotEmpty) _buildInsightsSection(),
                      const SizedBox(height: 16),
                      if (recomendacoes.isNotEmpty) _buildRecomendacoesSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar dados',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: carregarDados,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrevisaoCard() {
    if (previsao == null) return const SizedBox();

    final previsaoTotal = (previsao!['previsao_total'] ?? 0).toDouble();
    final confianca = (previsao!['confianca'] ?? 0).toDouble();
    final tendencia = previsao!['tendencia'] ?? 'estavel';
    final porCategoria = previsao!['por_categoria'] as List<dynamic>? ?? [];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Previsão Próximos 30 Dias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${confianca.toStringAsFixed(0)}%'),
                  backgroundColor: _getConfiancaColor(confianca),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'R\$ ${previsaoTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getTendenciaIcon(tendencia),
                  color: _getTendenciaColor(tendencia),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tendência: ${_getTendenciaTexto(tendencia)}',
                  style: TextStyle(
                    color: _getTendenciaColor(tendencia),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (porCategoria.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Top Categorias',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...porCategoria.take(3).map(
                    (cat) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat['categoria_nome'] ?? ''),
                          Text(
                            'R\$ ${(cat['previsao'] ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertasSection() {
    if (alertas.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Tudo certo! Nenhum alerta no momento.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...alertas.map(
          (alerta) => Card(
            color: _getAlertaColor(alerta['severidade'] ?? ''),
            child: ListTile(
              leading: Icon(
                _getAlertaIcon(alerta['tipo'] ?? ''),
                color: Colors.white,
              ),
              title: Text(
                alerta['titulo'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                alerta['mensagem'] ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...insights.map(
          (insight) => Card(
            child: ListTile(
              leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
              title: Text(insight),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecomendacoesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recomendações',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...recomendacoes.map(
          (rec) => Card(
            child: ListTile(
              leading: const Icon(Icons.tips_and_updates, color: Colors.blue),
              title: Text(rec),
            ),
          ),
        ),
      ],
    );
  }

  Color _getConfiancaColor(double confianca) {
    if (confianca >= 70) return Colors.green;
    if (confianca >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getTendenciaIcon(String tendencia) {
    switch (tendencia) {
      case 'crescente':
        return Icons.trending_up;
      case 'decrescente':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTendenciaColor(String tendencia) {
    switch (tendencia) {
      case 'crescente':
        return Colors.red;
      case 'decrescente':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTendenciaTexto(String tendencia) {
    switch (tendencia) {
      case 'crescente':
        return 'Crescente';
      case 'decrescente':
        return 'Decrescente';
      default:
        return 'Estável';
    }
  }

  Color _getAlertaColor(String severidade) {
    switch (severidade) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getAlertaIcon(String tipo) {
    switch (tipo) {
      case 'gasto_acima_media':
        return Icons.warning;
      case 'saldo_baixo':
        return Icons.account_balance_wallet;
      case 'meta_em_risco':
        return Icons.flag;
      default:
        return Icons.info;
    }
  }
}