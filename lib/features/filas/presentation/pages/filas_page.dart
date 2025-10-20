import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fila_solicitacao.dart';
import '../../../../core/providers/filas_provider.dart';
import '../widgets/fila_solicitacao_card.dart';
import '../widgets/criar_solicitacao_dialog.dart';

/// Página principal de gerenciamento de filas
class FilasPage extends ConsumerStatefulWidget {
  const FilasPage({super.key});

  @override
  ConsumerState<FilasPage> createState() => _FilasPageState();
}

class _FilasPageState extends ConsumerState<FilasPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contagem = ref.watch(contagemPorTipoProvider);
    final totalAtivas = ref.watch(totalSolicitacoesAtivasProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filas de Atendimento'),
            Text(
              '$totalAtivas ${totalAtivas == 1 ? 'solicitação ativa' : 'solicitações ativas'}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: const Icon(Icons.format_list_bulleted),
              text: 'Todas ($totalAtivas)',
            ),
            Tab(
              icon: const Icon(Icons.wc),
              text: 'Banheiro (${contagem[TipoFila.banheiro] ?? 0})',
            ),
            Tab(
              icon: const Icon(Icons.restaurant),
              text: 'Alimentação (${contagem[TipoFila.alimentacao] ?? 0})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FilaTab(tipo: null), // Todas
          _FilaTab(tipo: TipoFila.banheiro),
          _FilaTab(tipo: TipoFila.alimentacao),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogNovaSolicitacao(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Solicitação'),
      ),
    );
  }

  Future<void> _mostrarDialogNovaSolicitacao() async {
    await showDialog(
      context: context,
      builder: (context) => const CriarSolicitacaoDialog(),
    );
  }
}

/// Tab para exibir solicitações de um tipo específico
class _FilaTab extends ConsumerWidget {
  final TipoFila? tipo;

  const _FilaTab({this.tipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FilaSolicitacao>> solicitacoesAsync;
    
    if (tipo == null) {
      solicitacoesAsync = ref.watch(solicitacoesAtivasProvider);
    } else if (tipo == TipoFila.banheiro) {
      solicitacoesAsync = ref.watch(solicitacoesBanheiroProvider);
    } else {
      solicitacoesAsync = ref.watch(solicitacoesAlimentacaoProvider);
    }

    return solicitacoesAsync.when(
      data: (solicitacoes) {
        if (solicitacoes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tipo == null
                      ? Icons.inbox
                      : tipo == TipoFila.banheiro
                          ? Icons.wc
                          : Icons.restaurant,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  tipo == null
                      ? 'Nenhuma solicitação ativa'
                      : 'Nenhuma solicitação de ${tipo?.label.toLowerCase()}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Toque no botão + para criar uma nova solicitação',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Agrupar por urgência
        final criticas = solicitacoes.where((s) => s.urgencia == 'critico').toList();
        final urgentes = solicitacoes.where((s) => s.urgencia == 'urgente').toList();
        final atencao = solicitacoes.where((s) => s.urgencia == 'atencao').toList();
        final normais = solicitacoes.where((s) => s.urgencia == 'normal').toList();

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (criticas.isNotEmpty) ...[
              _buildSecaoUrgencia('🚨 Críticas', criticas, Colors.red),
              const SizedBox(height: 16),
            ],
            if (urgentes.isNotEmpty) ...[
              _buildSecaoUrgencia('⚠️ Urgentes', urgentes, Colors.orange),
              const SizedBox(height: 16),
            ],
            if (atencao.isNotEmpty) ...[
              _buildSecaoUrgencia('⏰ Atenção', atencao, Colors.yellow[700]!),
              const SizedBox(height: 16),
            ],
            if (normais.isNotEmpty) ...[
              _buildSecaoUrgencia('✅ Normais', normais, Colors.green),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro ao carregar filas: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoUrgencia(
    String titulo,
    List<FilaSolicitacao> solicitacoes,
    Color cor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${solicitacoes.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...solicitacoes.map((solicitacao) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilaSolicitacaoCard(solicitacao: solicitacao),
            )),
      ],
    );
  }
}

