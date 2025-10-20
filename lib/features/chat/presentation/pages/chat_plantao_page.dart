import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/chat_mensagem.dart';
import '../../../../core/providers/chat_plantao_provider.dart';
import '../../../../core/providers/auth_provider.dart';

/// Página do chat do plantão
class ChatPlantaoPage extends ConsumerStatefulWidget {
  const ChatPlantaoPage({super.key});

  @override
  ConsumerState<ChatPlantaoPage> createState() => _ChatPlantaoPageState();
}

class _ChatPlantaoPageState extends ConsumerState<ChatPlantaoPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _enviando = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _enviarMensagem() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _enviando = true);

    try {
      final service = ref.read(chatPlantaoServiceProvider);
      await service.enviarMensagem(_messageController.text);
      
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar mensagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mensagensAsync = ref.watch(mensagensPlantaoProvider);
    final authState = ref.watch(authNotifierProvider);
    final infoPlantaoAsync = ref.watch(infoPlantaoHojeProvider);

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
            const Text('Chat do Plantão'),
            infoPlantaoAsync.when(
              data: (info) {
                final total = info['total'] ?? 0;
                return Text(
                  '$total ${total == 1 ? 'plantonista' : 'plantonistas'} hoje',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                );
              },
              loading: () => const Text(
                'Carregando...',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          // Mostrar info do plantão
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _mostrarInfoPlantao(),
            tooltip: 'Informações do Plantão',
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: mensagensAsync.when(
              data: (mensagens) {
                if (mensagens.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma mensagem ainda',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Seja o primeiro a enviar uma mensagem!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final mensagem = mensagens[index];
                    final userEmail = authState.value?.email ?? '';
                    final isMinhaMensagem = mensagem.isMinhamensagem(userEmail);

                    return _MensagemBubble(
                      mensagem: mensagem,
                      isMinhaMensagem: isMinhaMensagem,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar mensagens: $error'),
                  ],
                ),
              ),
            ),
          ),

          // Campo de input
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Digite sua mensagem...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _enviarMensagem(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _enviando ? null : _enviarMensagem,
                    mini: true,
                    child: _enviando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarInfoPlantao() {
    final infoAsync = ref.read(infoPlantaoHojeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.people, size: 24),
            SizedBox(width: 8),
            Text('Plantão de Hoje'),
          ],
        ),
        content: infoAsync.when(
          data: (info) {
            final coordenador = info['coordenador'] as String?;
            final plantonistas = info['plantonistas'] as List<dynamic>;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (coordenador != null) ...[
                    const Text(
                      'Coordenador:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.star, color: Colors.white, size: 20),
                      ),
                      title: Text(coordenador),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 24),
                  ],
                  const Text(
                    'Plantonistas:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (plantonistas.isEmpty)
                    const Text('Nenhum plantonista registrado para hoje')
                  else
                    ...plantonistas.map((p) {
                      final posicao = p['posicao'] as int?;
                      if (posicao == 1) return const SizedBox.shrink(); // Já mostrado como coordenador
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            posicao?.toString() ?? '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(p['nome'] ?? ''),
                        subtitle: Text((p['turnos'] as List?)?.join(', ') ?? ''),
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Text('Erro ao carregar informações: $e'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

/// Bubble de mensagem
class _MensagemBubble extends StatelessWidget {
  final ChatMensagem mensagem;
  final bool isMinhaMensagem;

  const _MensagemBubble({
    required this.mensagem,
    required this.isMinhaMensagem,
  });

  String _formatarHora(DateTime data) {
    return DateFormat('HH:mm').format(data);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMinhaMensagem 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMinhaMensagem) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                mensagem.remetenteNome[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMinhaMensagem 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                if (!isMinhaMensagem)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      mensagem.remetenteNome,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMinhaMensagem
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMinhaMensagem ? 20 : 4),
                      bottomRight: Radius.circular(isMinhaMensagem ? 4 : 20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mensagem.texto,
                        style: TextStyle(
                          color: isMinhaMensagem ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatarHora(mensagem.dataEnvio),
                        style: TextStyle(
                          fontSize: 11,
                          color: isMinhaMensagem 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMinhaMensagem) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                mensagem.remetenteNome[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

