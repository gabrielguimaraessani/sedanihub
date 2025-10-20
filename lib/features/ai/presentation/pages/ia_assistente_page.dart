import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/ai_chat_multimodal_widget.dart';

class IAAssistentePage extends ConsumerStatefulWidget {
  const IAAssistentePage({super.key});

  @override
  ConsumerState<IAAssistentePage> createState() => _IAAssistentePageState();
}

class _IAAssistentePageState extends ConsumerState<IAAssistentePage> {
  AiType _selectedAI = AiType.gemini;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IA Assistente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<AiType>(
            icon: const Icon(Icons.more_vert),
            onSelected: (AiType aiType) {
              setState(() {
                _selectedAI = aiType;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<AiType>(
                value: AiType.gemini,
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: _selectedAI == AiType.gemini ? Theme.of(context).colorScheme.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Google Gemini',
                      style: TextStyle(
                        color: _selectedAI == AiType.gemini ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<AiType>(
                value: AiType.vertexAi,
                child: Row(
                  children: [
                    Icon(
                      Icons.smart_toy,
                      color: _selectedAI == AiType.vertexAi ? Theme.of(context).colorScheme.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Vertex AI',
                      style: TextStyle(
                        color: _selectedAI == AiType.vertexAi ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com informações sobre o AI selecionado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _selectedAI == AiType.gemini ? Colors.blue : Colors.green,
                  child: Icon(
                    _selectedAI == AiType.gemini ? Icons.psychology : Icons.smart_toy,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedAI == AiType.gemini ? 'Google Gemini' : 'Vertex AI',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _selectedAI == AiType.gemini 
                            ? 'IA geral para consultas e suporte'
                            : 'IA corporativa com acesso a protocolos institucionais',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Sobre ${_selectedAI == AiType.gemini ? 'Google Gemini' : 'Vertex AI'}'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedAI == AiType.gemini 
                                  ? 'Google Gemini é um modelo de linguagem avançado que pode ajudar com:\n\n• Consultas gerais sobre medicina\n• Explicações sobre procedimentos\n• Suporte educacional\n• Análise de textos médicos'
                                  : 'Vertex AI é nossa IA corporativa que possui:\n\n• Acesso aos protocolos institucionais\n• Conhecimento sobre procedimentos específicos\n• Integração com dados da empresa\n• Suporte especializado para anestesiologia',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
          ),
          
          // Área de contexto (para Vertex AI)
          if (_selectedAI == AiType.vertexAi)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Contexto ativo: Protocolos institucionais, procedimentos de anestesiologia e dados corporativos carregados.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Widget de chat multimodal
          Expanded(
            child: AiChatMultimodalWidget(
              aiType: _selectedAI,
              permitirAnexos: true,
            ),
          ),
        ],
      ),
    );
  }
}
