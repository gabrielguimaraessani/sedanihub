import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_mensagem.dart';
import '../services/chat_plantao_service.dart';

/// Provider do serviço de chat do plantão
final chatPlantaoServiceProvider = Provider<ChatPlantaoService>((ref) {
  return ChatPlantaoService();
});

/// Provider para stream de mensagens do plantão de hoje
final mensagensPlantaoProvider = StreamProvider<List<ChatMensagem>>((ref) {
  final service = ref.watch(chatPlantaoServiceProvider);
  return service.getMensagensPlantaoHoje();
});

/// Provider para verificar se usuário está no plantão
final usuarioNoPlantaoProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(chatPlantaoServiceProvider);
  return await service.usuarioEstaNoPlantaoHoje();
});

/// Provider para informações do plantão de hoje
final infoPlantaoHojeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(chatPlantaoServiceProvider);
  return await service.getInfoPlantaoHoje();
});

/// Provider para contagem de mensagens do dia
final contagemMensagensProvider = Provider<int>((ref) {
  final mensagensAsync = ref.watch(mensagensPlantaoProvider);
  
  return mensagensAsync.when(
    data: (mensagens) => mensagens.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

