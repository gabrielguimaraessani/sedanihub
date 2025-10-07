import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simulação de usuário
class User {
  final String email;
  final String name;
  
  User({required this.email, required this.name});
}

// Provider para o estado de autenticação (simulado)
final authStateProvider = StreamProvider<User?>((ref) {
  // Simular estado de autenticação
  return Stream.value(null);
});

// Provider para o notifier de autenticação (simulado)
final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    return const AsyncValue.data(null);
  }
  
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    print('🔐 Tentativa de login iniciada para: $email');
    state = const AsyncValue.loading();
    
    try {
      // Verificar se o email termina com @sani.med.br
      if (!email.endsWith('@sani.med.br')) {
        print('❌ Email inválido: $email');
        throw Exception('Apenas emails corporativos @sani.med.br são permitidos');
      }
      
      print('✅ Email válido, simulando login...');
      // Simular login bem-sucedido
      await Future.delayed(const Duration(seconds: 1));
      
      final user = User(
        email: email,
        name: email.split('@').first,
      );
      
      print('🎉 Login simulado bem-sucedido para: ${user.name}');
      state = AsyncValue.data(user);
    } catch (e) {
      print('💥 Erro no login: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      // Simular logout
      await Future.delayed(const Duration(milliseconds: 500));
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      if (!email.endsWith('@sani.med.br')) {
        throw Exception('Apenas emails corporativos @sani.med.br são permitidos');
      }
      
      // Simular envio de email
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}