import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para o estado de autenticação do Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider para o notifier de autenticação
final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    // Escutar mudanças de autenticação do Firebase
    final authState = FirebaseAuth.instance.authStateChanges();
    
    authState.listen((user) {
      state = AsyncValue.data(user);
    });
    
    return AsyncValue.data(FirebaseAuth.instance.currentUser);
  }
  
  /// Faz login com email e senha
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    print('🔐 Tentativa de login iniciada para: $email');
    state = const AsyncValue.loading();
    
    try {
      // Verificar se o email termina com @sani.med.br
      if (!email.endsWith('@sani.med.br') && !email.endsWith('@sedanimed.br')) {
        print('❌ Email inválido: $email');
        throw Exception('Apenas emails corporativos @sani.med.br ou @sedanimed.br são permitidos');
      }
      
      print('✅ Email válido, autenticando no Firebase...');
      
      // Autenticação REAL no Firebase
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('🎉 Login bem-sucedido: ${userCredential.user?.email}');
      state = AsyncValue.data(userCredential.user);
    } on FirebaseAuthException catch (e) {
      print('💥 Erro Firebase Auth: ${e.code} - ${e.message}');
      
      String mensagemErro;
      switch (e.code) {
        case 'user-not-found':
          mensagemErro = 'Usuário não encontrado. Verifique o email.';
          break;
        case 'wrong-password':
          mensagemErro = 'Senha incorreta. Tente novamente.';
          break;
        case 'invalid-email':
          mensagemErro = 'Email inválido.';
          break;
        case 'user-disabled':
          mensagemErro = 'Usuário desabilitado. Contate o administrador.';
          break;
        case 'too-many-requests':
          mensagemErro = 'Muitas tentativas. Aguarde alguns minutos.';
          break;
        case 'network-request-failed':
          mensagemErro = 'Erro de conexão. Verifique sua internet.';
          break;
        default:
          mensagemErro = 'Erro ao fazer login: ${e.message}';
      }
      
      state = AsyncValue.error(mensagemErro, StackTrace.current);
    } catch (e) {
      print('💥 Erro desconhecido: $e');
      state = AsyncValue.error('Erro ao fazer login: ${e.toString()}', StackTrace.current);
    }
  }

  /// Faz logout
  Future<void> signOut() async {
    try {
      print('🚪 Fazendo logout...');
      await FirebaseAuth.instance.signOut();
      state = const AsyncValue.data(null);
      print('✅ Logout realizado com sucesso');
    } catch (e) {
      print('💥 Erro ao fazer logout: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Envia email de recuperação de senha
  Future<void> resetPassword(String email) async {
    try {
      if (!email.endsWith('@sani.med.br') && !email.endsWith('@sedanimed.br')) {
        throw Exception('Apenas emails corporativos @sani.med.br ou @sedanimed.br são permitidos');
      }
      
      print('📧 Enviando email de recuperação para: $email');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('✅ Email de recuperação enviado');
    } on FirebaseAuthException catch (e) {
      print('💥 Erro ao enviar email: ${e.code} - ${e.message}');
      
      String mensagemErro;
      switch (e.code) {
        case 'user-not-found':
          mensagemErro = 'Usuário não encontrado.';
          break;
        case 'invalid-email':
          mensagemErro = 'Email inválido.';
          break;
        default:
          mensagemErro = 'Erro ao enviar email: ${e.message}';
      }
      
      throw Exception(mensagemErro);
    }
  }

  /// Cria nova conta (se necessário no futuro)
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    try {
      if (!email.endsWith('@sani.med.br') && !email.endsWith('@sedanimed.br')) {
        throw Exception('Apenas emails corporativos são permitidos');
      }
      
      print('👤 Criando novo usuário: $email');
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      state = AsyncValue.data(userCredential.user);
      print('✅ Usuário criado com sucesso');
    } on FirebaseAuthException catch (e) {
      print('💥 Erro ao criar usuário: ${e.code} - ${e.message}');
      
      String mensagemErro;
      switch (e.code) {
        case 'email-already-in-use':
          mensagemErro = 'Email já está em uso.';
          break;
        case 'weak-password':
          mensagemErro = 'Senha muito fraca. Use pelo menos 6 caracteres.';
          break;
        case 'invalid-email':
          mensagemErro = 'Email inválido.';
          break;
        default:
          mensagemErro = 'Erro ao criar conta: ${e.message}';
      }
      
      state = AsyncValue.error(mensagemErro, StackTrace.current);
    }
  }
}
