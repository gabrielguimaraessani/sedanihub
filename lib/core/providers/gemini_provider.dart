import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/credentials.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

// Provider para o chat do Gemini
final geminiChatProvider = NotifierProvider<GeminiChatNotifier, List<ChatMessage>>(() {
  return GeminiChatNotifier();
});

class GeminiChatNotifier extends Notifier<List<ChatMessage>> {
  late GenerativeModel _model;

  @override
  List<ChatMessage> build() {
    // Inicializar o modelo Gemini
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: Credentials.geminiApiKey,
    );
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
      // Enviar para o Gemini
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      
      // Adicionar resposta da IA
      final aiMessage = ChatMessage(
        content: response.text ?? 'Desculpe, não consegui processar sua mensagem.',
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