import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({Key? key}) : super(key: key);

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final List<Meta> _metas = [
    Meta(
      id: 1,
      titulo: 'Fundo de Emergência',
      valorAlvo: 10000.00,
      valorAtual: 3500.00,
      prazo: DateTime(2024, 12, 31),
      cor: AppTheme.accentBlue,
    ),
    Meta(
      id: 2,
      titulo: 'Viagem de Férias',
      valorAlvo: 5000.00,
      valorAtual: 1200.00,
      prazo: DateTime(2024, 7, 15),
      cor: AppTheme.accentOrange,
    ),
    Meta(
      id: 3,
      titulo: 'Novo Notebook',
      valorAlvo: 4000.00,
      valorAtual: 2800.00,
      prazo: DateTime(2024, 6, 30),
      cor: AppTheme.accentGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Metas'),
        backgroundColor: AppTheme.primaryDark,
      ),
      body: _metas.isEmpty
          ? _buildListaVazia()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _metas.length,
              itemBuilder: (context, index) {
                return _buildMetaCard(_metas[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogNovaMeta,
        backgroundColor: AppTheme.accentBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListaVazia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma meta cadastrada',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque no botão + para criar sua primeira meta',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(Meta meta) {
    final percentual = (meta.valorAtual / meta.valorAlvo * 100).clamp(0, 100);
    final diasRestantes = meta.prazo.difference(DateTime.now()).inDays;
    final faltam = meta.valorAlvo - meta.valorAtual;
    
    return Card(
      color: AppTheme.cardDark,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meta.titulo,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: meta.cor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${percentual.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: meta.cor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progresso',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${meta.valorAtual.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Meta',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${meta.valorAlvo.toStringAsFixed(2).replaceAll('.', ',')}',
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
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentual / 100,
                backgroundColor: AppTheme.backgroundDark,
                valueColor: AlwaysStoppedAnimation<Color>(meta.cor),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: diasRestantes < 30 ? AppTheme.accentRed : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      diasRestantes > 0
                          ? '$diasRestantes dias restantes'
                          : 'Prazo vencido',
                      style: TextStyle(
                        color: diasRestantes < 30 ? AppTheme.accentRed : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Faltam R\$ ${faltam.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _mostrarDialogAdicionar(meta),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Adicionar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: meta.cor,
                      side: BorderSide(color: meta.cor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _mostrarDialogEditar(meta),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentBlue,
                      side: const BorderSide(color: AppTheme.accentBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.accentRed,
                  onPressed: () => _confirmarExclusao(meta),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogNovaMeta() {
    final tituloController = TextEditingController();
    final valorAlvoController = TextEditingController();
    DateTime? prazoSelecionado;
    Color corSelecionada = AppTheme.accentBlue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text(
            'Nova Meta',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valorAlvoController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor Alvo',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    prefixText: 'R\$ ',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Prazo',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  subtitle: Text(
                    prazoSelecionado != null
                        ? '${prazoSelecionado!.day}/${prazoSelecionado!.month}/${prazoSelecionado!.year}'
                        : 'Selecione uma data',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: AppTheme.accentBlue),
                  onTap: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (data != null) {
                      setStateDialog(() {
                        prazoSelecionado = data;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cor',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    AppTheme.accentBlue,
                    AppTheme.accentGreen,
                    AppTheme.accentOrange,
                    AppTheme.accentRed,
                  ].map((cor) {
                    return GestureDetector(
                      onTap: () {
                        setStateDialog(() {
                          corSelecionada = cor;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: corSelecionada == cor
                                ? AppTheme.textPrimary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.isNotEmpty &&
                    valorAlvoController.text.isNotEmpty &&
                    prazoSelecionado != null) {
                  setState(() {
                    _metas.add(
                      Meta(
                        id: _metas.length + 1,
                        titulo: tituloController.text,
                        valorAlvo: double.parse(valorAlvoController.text.replaceAll(',', '.')),
                        valorAtual: 0,
                        prazo: prazoSelecionado!,
                        cor: corSelecionada,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
              ),
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogAdicionar(Meta meta) {
    final valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'Adicionar Valor',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: valorController,
          style: const TextStyle(color: AppTheme.textPrimary),
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Valor',
            labelStyle: TextStyle(color: AppTheme.textSecondary),
            prefixText: 'R\$ ',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.textSecondary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (valorController.text.isNotEmpty) {
                setState(() {
                  final valor = double.parse(valorController.text.replaceAll(',', '.'));
                  meta.valorAtual += valor;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: meta.cor,
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogEditar(Meta meta) {
    final tituloController = TextEditingController(text: meta.titulo);
    final valorAlvoController = TextEditingController(
      text: meta.valorAlvo.toStringAsFixed(2).replaceAll('.', ','),
    );
    DateTime prazoSelecionado = meta.prazo;
    Color corSelecionada = meta.cor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text(
            'Editar Meta',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valorAlvoController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor Alvo',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    prefixText: 'R\$ ',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Prazo',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${prazoSelecionado.day}/${prazoSelecionado.month}/${prazoSelecionado.year}',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: AppTheme.accentBlue),
                  onTap: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: prazoSelecionado,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (data != null) {
                      setStateDialog(() {
                        prazoSelecionado = data;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cor',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    AppTheme.accentBlue,
                    AppTheme.accentGreen,
                    AppTheme.accentOrange,
                    AppTheme.accentRed,
                  ].map((cor) {
                    return GestureDetector(
                      onTap: () {
                        setStateDialog(() {
                          corSelecionada = cor;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: corSelecionada == cor
                                ? AppTheme.textPrimary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.isNotEmpty &&
                    valorAlvoController.text.isNotEmpty) {
                  setState(() {
                    meta.titulo = tituloController.text;
                    meta.valorAlvo = double.parse(
                      valorAlvoController.text.replaceAll(',', '.'),
                    );
                    meta.prazo = prazoSelecionado;
                    meta.cor = corSelecionada;
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(Meta meta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'Excluir Meta',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Deseja realmente excluir a meta "${meta.titulo}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _metas.remove(meta);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class Meta {
  int id;
  String titulo;
  double valorAlvo;
  double valorAtual;
  DateTime prazo;
  Color cor;

  Meta({
    required this.id,
    required this.titulo,
    required this.valorAlvo,
    required this.valorAtual,
    required this.prazo,
    required this.cor,
  });
}