import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/transacao_provider.dart';
import '../../providers/categoria_provider.dart';
import '../../models/transacao.dart';
import '../../models/categoria.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({Key? key}) : super(key: key);

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  String _periodoSelecionado = 'mes';
  DateTime _dataReferencia = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await Provider.of<TransacaoProvider>(context, listen: false).fetchTransacoes();
    await Provider.of<CategoriaProvider>(context, listen: false).fetchCategorias();
  }

  List<Transacao> _filtrarPorPeriodo(List<Transacao> transacoes) {
    final agora = _dataReferencia;
    
    return transacoes.where((t) {
      if (_periodoSelecionado == 'mes') {
        return t.dataTransacao.year == agora.year && 
               t.dataTransacao.month == agora.month;
      } else if (_periodoSelecionado == 'ano') {
        return t.dataTransacao.year == agora.year;
      } else {
        final hoje = DateTime.now();
        final seteDiasAtras = hoje.subtract(const Duration(days: 7));
        return t.dataTransacao.isAfter(seteDiasAtras) && 
               t.dataTransacao.isBefore(hoje.add(const Duration(days: 1)));
      }
    }).toList();
  }

  Map<String, double> _calcularPorCategoria(List<Transacao> transacoes, String tipo) {
    final categoriaProvider = Provider.of<CategoriaProvider>(context, listen: false);
    final Map<String, double> resultado = {};
    
    final transacoesFiltradas = transacoes.where((t) => t.tipo == tipo).toList();
    
    for (var transacao in transacoesFiltradas) {
      final categoria = categoriaProvider.categorias.firstWhere(
        (c) => c.id == transacao.categoriaId,
        orElse: () => Categoria(
          id: 0,
          nome: 'Outros',
          tipo: tipo,
          icone: '',
          cor: '#808080',
        ),
      );
      
      resultado[categoria.nome] = (resultado[categoria.nome] ?? 0) + transacao.valor;
    }
    
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: AppTheme.primaryDark,
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        color: AppTheme.accentBlue,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSeletorPeriodo(),
              const SizedBox(height: 24),
              _buildResumoFinanceiro(),
              const SizedBox(height: 24),
              _buildGraficoDespesas(),
              const SizedBox(height: 24),
              _buildGraficoReceitas(),
              const SizedBox(height: 24),
              _buildEvolucaoMensal(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeletorPeriodo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Período',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'semana', label: Text('Semana')),
              ButtonSegment(value: 'mes', label: Text('Mês')),
              ButtonSegment(value: 'ano', label: Text('Ano')),
            ],
            selected: {_periodoSelecionado},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _periodoSelecionado = newSelection.first;
              });
            },
          ),
          if (_periodoSelecionado == 'mes') ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _dataReferencia = DateTime(
                        _dataReferencia.year,
                        _dataReferencia.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  _getNomeMes(_dataReferencia.month) + ' ${_dataReferencia.year}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _dataReferencia = DateTime(
                        _dataReferencia.year,
                        _dataReferencia.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResumoFinanceiro() {
    return Consumer<TransacaoProvider>(
      builder: (context, transacaoProvider, child) {
        final transacoesPeriodo = _filtrarPorPeriodo(transacaoProvider.transacoes);
        
        final receitas = transacoesPeriodo
            .where((t) => t.tipo == 'receita')
            .fold<double>(0, (sum, t) => sum + t.valor);
        
        final despesas = transacoesPeriodo
            .where((t) => t.tipo == 'despesa')
            .fold<double>(0, (sum, t) => sum + t.valor);
        
        final saldo = receitas - despesas;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentBlue,
                AppTheme.accentBlue.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'Resumo do Período',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward, color: AppTheme.accentGreen, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Receitas',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${receitas.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: AppTheme.accentGreen,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white30,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_downward, color: AppTheme.accentRed, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Despesas',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${despesas.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: AppTheme.accentRed,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGraficoDespesas() {
    return Consumer<TransacaoProvider>(
      builder: (context, transacaoProvider, child) {
        final transacoesPeriodo = _filtrarPorPeriodo(transacaoProvider.transacoes);
        final despesasPorCategoria = _calcularPorCategoria(transacoesPeriodo, 'despesa');
        
        if (despesasPorCategoria.isEmpty) {
          return _buildCardVazio('Despesas por Categoria', 'Nenhuma despesa no período');
        }
        
        final total = despesasPorCategoria.values.fold<double>(0, (sum, v) => sum + v);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Despesas por Categoria',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...despesasPorCategoria.entries.map((entry) {
                final percentual = (entry.value / total * 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'R\$ ${entry.value.toStringAsFixed(2).replaceAll('.', ',')} (${percentual.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentual / 100,
                          backgroundColor: AppTheme.backgroundDark,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentRed),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGraficoReceitas() {
    return Consumer<TransacaoProvider>(
      builder: (context, transacaoProvider, child) {
        final transacoesPeriodo = _filtrarPorPeriodo(transacaoProvider.transacoes);
        final receitasPorCategoria = _calcularPorCategoria(transacoesPeriodo, 'receita');
        
        if (receitasPorCategoria.isEmpty) {
          return _buildCardVazio('Receitas por Categoria', 'Nenhuma receita no período');
        }
        
        final total = receitasPorCategoria.values.fold<double>(0, (sum, v) => sum + v);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Receitas por Categoria',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...receitasPorCategoria.entries.map((entry) {
                final percentual = (entry.value / total * 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'R\$ ${entry.value.toStringAsFixed(2).replaceAll('.', ',')} (${percentual.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentual / 100,
                          backgroundColor: AppTheme.backgroundDark,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvolucaoMensal() {
    return Consumer<TransacaoProvider>(
      builder: (context, transacaoProvider, child) {
        final transacoes = transacaoProvider.transacoes;
        
        final Map<int, double> receitasPorMes = {};
        final Map<int, double> despesasPorMes = {};
        
        for (var transacao in transacoes) {
          if (transacao.dataTransacao.year == DateTime.now().year) {
            final mes = transacao.dataTransacao.month;
            if (transacao.tipo == 'receita') {
              receitasPorMes[mes] = (receitasPorMes[mes] ?? 0) + transacao.valor;
            } else {
              despesasPorMes[mes] = (despesasPorMes[mes] ?? 0) + transacao.valor;
            }
          }
        }
        
        if (receitasPorMes.isEmpty && despesasPorMes.isEmpty) {
          return _buildCardVazio('Evolução Mensal', 'Nenhuma transação este ano');
        }
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Evolução Mensal (Ano Atual)',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(12, (index) {
                final mes = index + 1;
                final receita = receitasPorMes[mes] ?? 0;
                final despesa = despesasPorMes[mes] ?? 0;
                final saldo = receita - despesa;
                
                if (receita == 0 && despesa == 0) return const SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          _getNomeMes(mes).substring(0, 3),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            if (receita > 0)
                              Flexible(
                                flex: (receita * 100).toInt(),
                                child: Container(
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentGreen,
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            if (despesa > 0)
                              Flexible(
                                flex: (despesa * 100).toInt(),
                                child: Container(
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentRed,
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: Text(
                          'R\$ ${saldo.abs().toStringAsFixed(0)}',
                          style: TextStyle(
                            color: saldo >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardVazio(String titulo, String mensagem) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.bar_chart_outlined,
            size: 48,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            mensagem,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getNomeMes(int mes) {
    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return meses[mes - 1];
  }
}

