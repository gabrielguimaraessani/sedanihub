import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/fila_solicitacao.dart';
import '../../../../core/providers/filas_provider.dart';

/// Diálogo simplificado para criar nova solicitação de fila
class CriarSolicitacaoDialog extends ConsumerStatefulWidget {
  const CriarSolicitacaoDialog({super.key});

  @override
  ConsumerState<CriarSolicitacaoDialog> createState() => _CriarSolicitacaoDialogState();
}

class _CriarSolicitacaoDialogState extends ConsumerState<CriarSolicitacaoDialog> {
  TipoFila _tipoSelecionado = TipoFila.banheiro;
  bool _processando = false;

  Future<void> _criarSolicitacao() async {
    setState(() => _processando = true);

    try {
      final service = ref.read(filasServiceProvider);
      await service.criarSolicitacao(tipo: _tipoSelecionado);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitação de ${_tipoSelecionado.label.toLowerCase()} criada com sucesso!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar solicitação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Solicitação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Selecione o tipo de solicitação:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          
          // Botões grandes para cada tipo
          _TipoButton(
            tipo: TipoFila.banheiro,
            selecionado: _tipoSelecionado == TipoFila.banheiro,
            onTap: () => setState(() => _tipoSelecionado = TipoFila.banheiro),
          ),
          
          const SizedBox(height: 12),
          
          _TipoButton(
            tipo: TipoFila.alimentacao,
            selecionado: _tipoSelecionado == TipoFila.alimentacao,
            onTap: () => setState(() => _tipoSelecionado = TipoFila.alimentacao),
          ),
          
          const SizedBox(height: 24),
          
          // Informação sobre expiração
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sua solicitação expira em 2 horas se não for concluída.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _processando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _processando ? null : _criarSolicitacao,
          icon: _processando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.add_circle),
          label: Text(_processando ? 'Criando...' : 'Criar Solicitação'),
        ),
      ],
    );
  }
}

/// Botão para selecionar tipo de fila
class _TipoButton extends StatelessWidget {
  final TipoFila tipo;
  final bool selecionado;
  final VoidCallback onTap;

  const _TipoButton({
    required this.tipo,
    required this.selecionado,
    required this.onTap,
  });

  IconData _getIcon() {
    return tipo == TipoFila.banheiro ? Icons.wc : Icons.restaurant;
  }

  Color _getColor() {
    return tipo == TipoFila.banheiro ? Colors.blue : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final cor = _getColor();
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selecionado ? cor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? cor : Colors.grey[300]!,
            width: selecionado ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selecionado ? cor : Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tipo.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selecionado ? cor : Colors.grey[700],
                    ),
                  ),
                  if (selecionado)
                    Text(
                      'Selecionado',
                      style: TextStyle(
                        fontSize: 12,
                        color: cor,
                      ),
                    ),
                ],
              ),
            ),
            if (selecionado)
              Icon(
                Icons.check_circle,
                color: cor,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
