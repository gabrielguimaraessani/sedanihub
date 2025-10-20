import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pacientes/domain/services/anonimizacao_service.dart';
import '../../../pacientes/domain/services/gemini_prompts.dart';

enum AiType { gemini, vertexAi }

enum MessageType { text, image, audio }

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;
  final double? confianca;
  final List<String>? alertas;
  
  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
    this.imageUrl,
    this.confianca,
    this.alertas,
  });
}

class AiChatMultimodalWidget extends ConsumerStatefulWidget {
  final AiType aiType;
  final Map<String, dynamic>? contextoInicial;
  final bool permitirAnexos;
  
  const AiChatMultimodalWidget({
    super.key,
    required this.aiType,
    this.contextoInicial,
    this.permitirAnexos = true,
  });

  @override
  ConsumerState<AiChatMultimodalWidget> createState() => _AiChatMultimodalWidgetState();
}

class _AiChatMultimodalWidgetState extends ConsumerState<AiChatMultimodalWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AnonimizacaoService _anonimizacao = AnonimizacaoService();
  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _adicionarMensagemBoasVindas();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _adicionarMensagemBoasVindas() {
    final mensagem = widget.aiType == AiType.gemini
        ? '''Olá! Sou o assistente Gemini. Posso ajudar com:

• Consultas gerais sobre medicina
• Explicações sobre procedimentos
• Análise de protocolos
• Suporte educacional

Como posso ajudar você hoje?'''
        : '''Olá! Sou o assistente Vertex AI da sua instituição. Tenho acesso a:

• Protocolos institucionais
• Procedimentos específicos
• Diretrizes corporativas
• Dados da organização

Como posso ajudar você hoje?''';

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: mensagem,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isProcessing) return;

    // 1. VALIDAR E SANITIZAR ENTRADA
    String mensagemSegura = message;
    if (_anonimizacao.contemDadosIdentificaveis(message)) {
      mensagemSegura = _anonimizacao.sanitizarTexto(message);
      
      // Avisar usuário
      _mostrarAlertaPrivacidade();
    }

    // 2. ADICIONAR MENSAGEM DO USUÁRIO
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: mensagemSegura,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isProcessing = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // 3. PROCESSAR COM IA
      final resposta = await _processarComIA(mensagemSegura);
      
      // 4. ADICIONAR RESPOSTA DA IA
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: resposta['conteudo'] ?? 'Desculpe, não consegui processar sua mensagem.',
        isUser: false,
        timestamp: DateTime.now(),
        confianca: resposta['confianca'],
        alertas: resposta['alertas']?.cast<String>(),
      );

      setState(() {
        _messages.add(aiMessage);
      });
    } catch (e) {
      // Erro ao processar
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Desculpe, ocorreu um erro ao processar sua mensagem. Tente novamente.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
      _scrollToBottom();
    }
  }

  Future<Map<String, dynamic>> _processarComIA(String mensagem) async {
    // TODO: Integrar com serviço real do Gemini/Vertex AI
    
    // Simular processamento
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock de resposta contextualizada
    if (mensagem.toLowerCase().contains('protocolo') || 
        mensagem.toLowerCase().contains('diretriz')) {
      return {
        'conteudo': '''Com base nos protocolos institucionais, aqui está a informação:

Para procedimentos de anestesiologia:
• Avaliação pré-anestésica obrigatória
• Classificação ASA necessária
• Jejum conforme protocolo (6-8h sólidos, 2h líquidos claros)
• Checklist de segurança cirúrgica

Alguma dúvida específica sobre algum protocolo?''',
        'confianca': 0.95,
        'alertas': [],
      };
    }
    
    if (mensagem.toLowerCase().contains('risco') || 
        mensagem.toLowerCase().contains('asa')) {
      return {
        'conteudo': '''A classificação ASA (American Society of Anesthesiologists) é um sistema de avaliação do estado físico:

• ASA I: Paciente saudável
• ASA II: Doença sistêmica leve
• ASA III: Doença sistêmica grave
• ASA IV: Doença sistêmica grave com ameaça constante à vida
• ASA V: Moribundo
• ASA VI: Morte cerebral (doador de órgãos)

Adicione "E" se cirurgia de emergência.

Precisa de ajuda para classificar algum paciente?''',
        'confianca': 0.98,
        'alertas': [],
      };
    }
    
    // Resposta genérica
    return {
      'conteudo': '''Entendi sua pergunta: "$mensagem"

${widget.aiType == AiType.vertexAi ? 'Consultei os protocolos institucionais e ' : ''}Posso fornecer mais informações. Poderia ser mais específico sobre:

• Qual procedimento ou protocolo você precisa?
• Há algum caso clínico específico?
• Precisa de diretrizes ou recomendações?

Estou aqui para ajudar!''',
      'confianca': 0.75,
      'alertas': [],
    };
  }

  void _mostrarAlertaPrivacidade() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.shield, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dados pessoais detectados e removidos por segurança',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Entendi',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _adicionarImagem() async {
    if (!widget.permitirAnexos) return;
    
    // TODO: Implementar seleção de imagem
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.image, color: Colors.blue),
            SizedBox(width: 12),
            Text('Adicionar Imagem'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⚠️ IMPORTANTE: Certifique-se de que a imagem não contém dados pessoais identificáveis (nome, CPF, etc).',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar captura
                _mostrarEmDesenvolvimento('Captura via câmera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar seleção
                _mostrarEmDesenvolvimento('Seleção da galeria');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adicionarAudio() async {
    if (!widget.permitirAnexos) return;
    
    // TODO: Implementar gravação de áudio
    _mostrarEmDesenvolvimento('Gravação de áudio');
  }

  void _mostrarEmDesenvolvimento(String funcionalidade) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$funcionalidade em desenvolvimento'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _limparConversa() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Conversa'),
        content: const Text('Deseja realmente limpar toda a conversa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _adicionarMensagemBoasVindas();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lista de mensagens
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(context, message);
                  },
                ),
        ),

        // Indicador de processamento
        if (_isProcessing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'IA está processando...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

        // Campo de entrada
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Column(
            children: [
              // Barra de ferramentas
              Row(
                children: [
                  if (widget.permitirAnexos) ...[
                    IconButton(
                      onPressed: _isProcessing ? null : _adicionarImagem,
                      icon: const Icon(Icons.image, size: 20),
                      tooltip: 'Adicionar Imagem',
                    ),
                    IconButton(
                      onPressed: _isProcessing ? null : _adicionarAudio,
                      icon: const Icon(Icons.mic, size: 20),
                      tooltip: 'Gravar Áudio',
                    ),
                  ],
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _messages.length > 1 ? _limparConversa : null,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Limpar'),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Campo de texto
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isProcessing,
                      decoration: InputDecoration(
                        hintText: 'Digite sua mensagem...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _isProcessing ? null : (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isProcessing 
                          ? Colors.grey 
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: _isProcessing ? null : _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.aiType == AiType.gemini
                ? Icons.psychology
                : Icons.smart_toy,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Inicie uma conversa',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Digite uma mensagem para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final isUser = message.isUser;
    final color = isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.aiType == AiType.gemini ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.aiType == AiType.gemini ? Icons.psychology : Icons.smart_toy,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUser ? Colors.white : null,
                    ),
                  ),
                  
                  // Alertas (se houver)
                  if (message.alertas != null && message.alertas!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                'Alertas:',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ...message.alertas!.map((alerta) => Text(
                            '• $alerta',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade900,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUser 
                              ? Colors.white.withOpacity(0.7)
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      if (message.confianca != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: isUser 
                              ? Colors.white.withOpacity(0.7)
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${(message.confianca! * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isUser 
                                ? Colors.white.withOpacity(0.7)
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

