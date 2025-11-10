import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transacao_provider.dart';
import '../../providers/categoria_provider.dart';
import '../../models/transacao.dart';
import '../../models/categoria.dart';

class NovaTransacaoScreen extends StatefulWidget {
  const NovaTransacaoScreen({Key? key}) : super(key: key);

  @override
  State<NovaTransacaoScreen> createState() => _NovaTransacaoScreenState();
}

class _NovaTransacaoScreenState extends State<NovaTransacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  String _tipoSelecionado = 'despesa';
  int? _categoriaSelecionada;
  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoriaProvider>(context, listen: false).fetchCategorias();
    });
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  List<Categoria> _getCategoriasFiltradas(List<Categoria> categorias) {
    return categorias.where((c) => c.tipo == _tipoSelecionado).toList();
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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

    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  Future<void> _salvarTransacao() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma categoria'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transacaoProvider = Provider.of<TransacaoProvider>(context, listen: false);

      final valorString = _valorController.text.replaceAll(',', '.');
      final valor = double.parse(valorString);

      final transacao = Transacao(
        usuarioId: authProvider.usuario!.id,
        categoriaId: _categoriaSelecionada!,
        contaId: 1,
        tipo: _tipoSelecionado,
        valor: valor,
        descricao: _descricaoController.text.trim(),
        dataTransacao: _dataSelecionada,
      );

      final sucesso = await transacaoProvider.criarTransacao(transacao);

      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transação criada com sucesso!'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(transacaoProvider.error ?? 'Erro ao criar transação'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Nova Transação'),
        backgroundColor: AppTheme.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTipoSelector(),
              const SizedBox(height: 20),
              _buildValorField(),
              const SizedBox(height: 16),
              _buildCategoriaDropdown(),
              const SizedBox(height: 16),
              _buildDescricaoField(),
              const SizedBox(height: 16),
              _buildDataSelector(),
              const SizedBox(height: 32),
              _buildSalvarButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _tipoSelecionado = 'receita';
                  _categoriaSelecionada = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _tipoSelecionado == 'receita'
                      ? AppTheme.accentGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: _tipoSelecionado == 'receita'
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Receita',
                      style: TextStyle(
                        color: _tipoSelecionado == 'receita'
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _tipoSelecionado = 'despesa';
                  _categoriaSelecionada = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _tipoSelecionado == 'despesa'
                      ? AppTheme.accentRed
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: _tipoSelecionado == 'despesa'
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Despesa',
                      style: TextStyle(
                        color: _tipoSelecionado == 'despesa'
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValorField() {
    return TextFormField(
      controller: _valorController,
      decoration: const InputDecoration(
        labelText: 'Valor',
        prefixText: 'R\$ ',
        hintText: '0,00',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      ],
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe o valor';
        }
        final valorString = value.replaceAll(',', '.');
        final valor = double.tryParse(valorString);
        if (valor == null || valor <= 0) {
          return 'Valor inválido';
        }
        return null;
      },
    );
  }

  Widget _buildCategoriaDropdown() {
    return Consumer<CategoriaProvider>(
      builder: (context, categoriaProvider, child) {
        if (categoriaProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final categoriasFiltradas = _getCategoriasFiltradas(
          categoriaProvider.categorias,
        );

        if (categoriasFiltradas.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Nenhuma categoria de $_tipoSelecionado encontrada',
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          );
        }

        return DropdownButtonFormField<int>(
          value: _categoriaSelecionada,
          decoration: const InputDecoration(
            labelText: 'Categoria',
            prefixIcon: Icon(Icons.category),
          ),
          dropdownColor: AppTheme.cardDark,
          style: const TextStyle(color: AppTheme.textPrimary),
          items: categoriasFiltradas.map((categoria) {
            return DropdownMenuItem<int>(
              value: categoria.id,
              child: Row(
                children: [
                  Text(
                    categoria.icone ?? '📁',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(categoria.nome),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _categoriaSelecionada = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Selecione uma categoria';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildDescricaoField() {
    return TextFormField(
      controller: _descricaoController,
      decoration: const InputDecoration(
        labelText: 'Descrição',
        prefixIcon: Icon(Icons.description),
        hintText: 'Ex: Almoço no restaurante',
      ),
      maxLines: 3,
      style: const TextStyle(color: AppTheme.textPrimary),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe a descrição';
        }
        return null;
      },
    );
  }

  Widget _buildDataSelector() {
    return InkWell(
      onTap: _selecionarData,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.accentBlue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalvarButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _salvarTransacao,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppTheme.accentBlue,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Salvar Transação',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}