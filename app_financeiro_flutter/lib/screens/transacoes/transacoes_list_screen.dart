import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/transacao_provider.dart';
import '../../providers/categoria_provider.dart';
import '../../models/transacao.dart';
import 'transacao_screen.dart';

class TransacoesListScreen extends StatefulWidget {
  const TransacoesListScreen({Key? key}) : super(key: key);

  @override
  State<TransacoesListScreen> createState() => _TransacoesListScreenState();
}

class _TransacoesListScreenState extends State<TransacoesListScreen> {
  String _filtroTipo = 'todas';
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await Provider.of<TransacaoProvider>(context, listen: false).fetchTransacoes();
    await Provider.of<CategoriaProvider>(context, listen: false).fetchCategorias();
  }

  List<Transacao> _filtrarTransacoes(List<Transacao> transacoes) {
    var resultado = transacoes;

    if (_filtroTipo != 'todas') {
      resultado = resultado.where((t) => t.tipo == _filtroTipo).toList();
    }

    if (_dataInicio != null) {
      resultado = resultado.where((t) => 
        t.dataTransacao.isAfter(_dataInicio!) || 
        t.dataTransacao.isAtSameMomentAs(_dataInicio!)
      ).toList();
    }

    if (_dataFim != null) {
      resultado = resultado.where((t) => 
        t.dataTransacao.isBefore(_dataFim!.add(const Duration(days: 1)))
      ).toList();
    }

    resultado.sort((a, b) => b.dataTransacao.compareTo(a.dataTransacao));
    return resultado;
  }

  Future<void> _selecionarPeriodo() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _dataInicio != null && _dataFim != null
          ? DateTimeRange(start: _dataInicio!, end: _dataFim!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentBlue,
              surface: AppTheme.cardDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dataInicio = picked.start;
        _dataFim = picked.end;
      });
    }
  }

  void _limparFiltros() {
    setState(() {
      _filtroTipo = 'todas';
      _dataInicio = null;
      _dataFim = null;
    });
  }

  Future<void> _excluirTransacao(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final sucesso = await Provider.of<TransacaoProvider>(context, listen: false)
          .excluirTransacao(id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sucesso ? 'Transação excluída' : 'Erro ao excluir'),
            backgroundColor: sucesso ? AppTheme.accentGreen : AppTheme.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Transações'),
        backgroundColor: AppTheme.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        color: AppTheme.accentBlue,
        child: Column(
          children: [
            if (_filtroTipo != 'todas' || _dataInicio != null || _dataFim != null)
              _buildFiltrosAtivos(),
            Expanded(
              child: _buildListaTransacoes(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NovaTransacaoScreen(),
            ),
          );
          if (resultado == true) {
            _carregarDados();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFiltrosAtivos() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.cardDark,
      child: Row(
        children: [
          const Icon(Icons.filter_alt, color: AppTheme.accentBlue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (_filtroTipo != 'todas')
                  Chip(
                    label: Text(_filtroTipo == 'receita' ? 'Receitas' : 'Despesas'),
                    backgroundColor: _filtroTipo == 'receita' 
                        ? AppTheme.accentGreen 
                        : AppTheme.accentRed,
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => _filtroTipo = 'todas'),
                  ),
                if (_dataInicio != null && _dataFim != null)
                  Chip(
                    label: Text(
                      '${_dataInicio!.day.toString().padLeft(2, '0')}/${_dataInicio!.month.toString().padLeft(2, '0')} - '
                      '${_dataFim!.day.toString().padLeft(2, '0')}/${_dataFim!.month.toString().padLeft(2, '0')}'
                    ),
                    backgroundColor: AppTheme.accentBlue,
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() {
                      _dataInicio = null;
                      _dataFim = null;
                    }),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: _limparFiltros,
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  Widget _buildListaTransacoes() {
    return Consumer<TransacaoProvider>(
      builder: (context, transacaoProvider, child) {
        if (transacaoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final transacoesFiltradas = _filtrarTransacoes(transacaoProvider.transacoes);

        if (transacoesFiltradas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  _filtroTipo != 'todas' || _dataInicio != null || _dataFim != null
                      ? 'Nenhuma transação encontrada com os filtros aplicados'
                      : 'Nenhuma transação encontrada',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transacoesFiltradas.length,
          itemBuilder: (context, index) {
            final transacao = transacoesFiltradas[index];
            return _buildTransacaoCard(transacao);
          },
        );
      },
    );
  }

  Widget _buildTransacaoCard(Transacao transacao) {
    final isReceita = transacao.tipo == 'receita';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isReceita 
              ? AppTheme.accentGreen.withOpacity(0.2)
              : AppTheme.accentRed.withOpacity(0.2),
          child: Icon(
            isReceita ? Icons.arrow_upward : Icons.arrow_downward,
            color: isReceita ? AppTheme.accentGreen : AppTheme.accentRed,
          ),
        ),
        title: Text(
          transacao.descricao ?? 'Sem descrição',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${transacao.dataTransacao.day.toString().padLeft(2, '0')}/'
          '${transacao.dataTransacao.month.toString().padLeft(2, '0')}/'
          '${transacao.dataTransacao.year}',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isReceita ? '+' : '-'} R\$ ${transacao.valor.toStringAsFixed(2).replaceAll('.', ',')}',
              style: TextStyle(
                color: isReceita ? AppTheme.accentGreen : AppTheme.accentRed,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed),
              onPressed: () => _excluirTransacao(transacao.id!),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tipo de Transação',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'todas', label: Text('Todas')),
                  ButtonSegment(value: 'receita', label: Text('Receitas')),
                  ButtonSegment(value: 'despesa', label: Text('Despesas')),
                ],
                selected: {_filtroTipo},
                onSelectionChanged: (Set<String> newSelection) {
                  setModalState(() {
                    _filtroTipo = newSelection.first;
                  });
                  setState(() {
                    _filtroTipo = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _selecionarPeriodo();
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _dataInicio != null && _dataFim != null
                      ? '${_dataInicio!.day.toString().padLeft(2, '0')}/${_dataInicio!.month.toString().padLeft(2, '0')} - '
                        '${_dataFim!.day.toString().padLeft(2, '0')}/${_dataFim!.month.toString().padLeft(2, '0')}'
                      : 'Selecionar Período'
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _limparFiltros();
                        Navigator.pop(context);
                      },
                      child: const Text('Limpar Filtros'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

