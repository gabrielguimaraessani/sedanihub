import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gemini_provider.dart';

// Provider para o chat do Vertex AI
final vertexAiChatProvider = NotifierProvider<VertexAiChatNotifier, List<ChatMessage>>(() {
  return VertexAiChatNotifier();
});

class VertexAiChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    return [];
  }

  Future<void> sendMessage(String message) async {
    // Adicionar mensagem do usuário
    final userMessage = ChatMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = [...state, userMessage];

    try {
      // Simular processamento do Vertex AI
      await Future.delayed(const Duration(seconds: 2));
      
      final aiMessage = ChatMessage(
        content: 'Resposta simulada do Vertex AI para: "$message"\n\nEsta é uma resposta de exemplo. Para usar o Vertex AI real, configure suas credenciais de Service Account no Google Cloud Platform.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      state = [...state, aiMessage];
    } catch (e) {
      // Adicionar mensagem de erro
      final errorMessage = ChatMessage(
        content: 'Erro ao processar mensagem: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      state = [...state, errorMessage];
    }
  }

  void clearChat() {
    state = [];
  }
}