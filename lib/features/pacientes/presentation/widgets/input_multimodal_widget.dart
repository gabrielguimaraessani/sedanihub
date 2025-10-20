import 'package:flutter/material.dart';

/// Widget de input multimodal que aceita texto, imagens e áudio
/// para processamento via IA
class InputMultimodalWidget extends StatefulWidget {
  final Function(String texto) onTextoEnviado;
  final Function()? onImagemSelecionada;
  final Function()? onAudioGravado;
  final Function()? onAnexoSelecionado;
  final bool isProcessando;
  final String? hintText;
  final int maxLinhas;
  
  const InputMultimodalWidget({
    super.key,
    required this.onTextoEnviado,
    this.onImagemSelecionada,
    this.onAudioGravado,
    this.onAnexoSelecionado,
    this.isProcessando = false,
    this.hintText,
    this.maxLinhas = 3,
  });

  @override
  State<InputMultimodalWidget> createState() => _InputMultimodalWidgetState();
}

class _InputMultimodalWidgetState extends State<InputMultimodalWidget> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de ferramentas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (widget.onImagemSelecionada != null)
                  IconButton(
                    onPressed: widget.isProcessando ? null : widget.onImagemSelecionada,
                    icon: const Icon(Icons.image, size: 20),
                    tooltip: 'Adicionar Imagem',
                  ),
                if (widget.onAudioGravado != null)
                  IconButton(
                    onPressed: widget.isProcessando ? null : widget.onAudioGravado,
                    icon: const Icon(Icons.mic, size: 20),
                    tooltip: 'Gravar Áudio',
                  ),
                if (widget.onAnexoSelecionado != null)
                  IconButton(
                    onPressed: widget.isProcessando ? null : widget.onAnexoSelecionado,
                    icon: const Icon(Icons.attach_file, size: 20),
                    tooltip: 'Anexar Documento',
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isProcessando 
                        ? 'Processando com IA...'
                        : 'IA processará automaticamente',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                if (widget.isProcessando)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          
          // Campo de texto
          TextField(
            controller: _controller,
            enabled: !widget.isProcessando,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Digite ou cole informações, envie imagens/áudio...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                onPressed: widget.isProcessando ? null : _enviarTexto,
                icon: const Icon(Icons.send),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            maxLines: widget.maxLinhas,
            onSubmitted: widget.isProcessando ? null : (_) => _enviarTexto(),
          ),
        ],
      ),
    );
  }
  
  void _enviarTexto() {
    final texto = _controller.text.trim();
    if (texto.isNotEmpty) {
      widget.onTextoEnviado(texto);
      _controller.clear();
    }
  }
}

/// Widget de botão de sugestões da IA
class BotaoSugestoesIA extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;
  final String? label;
  
  const BotaoSugestoesIA({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.psychology),
      label: Text(label ?? 'Sugestões da IA'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
      ),
    );
  }
}

/// Widget indicador de alterações pendentes
class IndicadorAlteracoesPendentes extends StatelessWidget {
  final bool temAlteracoes;
  final String? mensagem;
  
  const IndicadorAlteracoesPendentes({
    super.key,
    required this.temAlteracoes,
    this.mensagem,
  });

  @override
  Widget build(BuildContext context) {
    if (!temAlteracoes) return const SizedBox.shrink();
    
    return Chip(
      label: Text(
        mensagem ?? 'Alterações não liberadas',
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: Colors.orange,
      avatar: const Icon(Icons.warning, size: 16, color: Colors.white),
    );
  }
}

/// Widget de botão de liberar avaliação
class BotaoLiberarAvaliacao extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;
  
  const BotaoLiberarAvaliacao({
    super.key,
    this.onPressed,
    this.enabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.check_circle),
        label: const Text('Liberar Avaliação / Consulta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

/// Diálogo de confirmação de liberação de avaliação
class DialogoLiberarAvaliacao {
  static Future<bool> mostrar(BuildContext context) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liberar Avaliação'),
        content: const Text(
          'Ao liberar a avaliação, uma nova versão do prontuário será criada e ficará permanentemente registrada no histórico de auditoria. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Liberar'),
          ),
        ],
      ),
    );
    
    return resultado ?? false;
  }
}

/// Widget de histórico de versões
class HistoricoVersoesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> historico;
  
  const HistoricoVersoesWidget({
    super.key,
    required this.historico,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Histórico de Versões'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: historico.length,
          itemBuilder: (context, index) {
            final versao = historico[index];
            final data = DateTime.parse(versao['data'] as String);
            
            return ListTile(
              leading: CircleAvatar(
                child: Text('${versao['versao']}'),
              ),
              title: Text(versao['acao'] as String),
              subtitle: Text(
                '${versao['usuario']}\n${_formatarData(data)}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  // TODO: Visualizar snapshot da versão
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Visualização de versões em desenvolvimento'),
                    ),
                  );
                },
                tooltip: 'Visualizar versão',
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
  
  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year} '
        '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
  }
}

