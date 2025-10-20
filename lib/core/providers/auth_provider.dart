import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/oidc_credentials.dart';

/// Provider para o estado de autenticação do Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider para o notifier de autenticação
final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  // ID do provider OpenID Connect (vem de oidc_credentials.dart)
  static String get oidcProviderId => OIDCCredentials.providerId;
  
  // Modo de desenvolvimento (sem Firebase configurado)
  // Mudar para false quando Firebase estiver configurado com OIDC
  static const bool _modoDesenvolvimento = true;
  
  @override
  AsyncValue<User?> build() {
    if (_modoDesenvolvimento) {
      // Modo dev: retorna null inicialmente
      return const AsyncValue.data(null);
    }
    
    // Modo produção: escutar mudanças de autenticação do Firebase
    final authState = FirebaseAuth.instance.authStateChanges();
    
    authState.listen((user) {
      state = AsyncValue.data(user);
    });
    
    return AsyncValue.data(FirebaseAuth.instance.currentUser);
  }
  
  /// Faz login usando OpenID Connect (Popup)
  Future<void> signInWithOIDC() async {
    print('🔐 Iniciando login com OpenID Connect...');
    state = const AsyncValue.loading();
    
    try {
      // Criar provider OpenID Connect
      final provider = OAuthProvider(oidcProviderId);
      
      // Configurar escopos (se necessário)
      provider.addScope('email');
      provider.addScope('profile');
      
      // Parâmetros customizados (se necessário)
      // provider.setCustomParameters({
      //   'tenant': 'sani-med',
      // });
      
      // Login com popup (Web) ou redirect (Mobile)
      final userCredential = await FirebaseAuth.instance.signInWithPopup(provider);
      
      // Verificar se email é do domínio corporativo
      final email = userCredential.user?.email ?? '';
      if (!email.endsWith('@sani.med.br') && !email.endsWith('@sedanimed.br')) {
        // Fazer logout se email inválido
        await FirebaseAuth.instance.signOut();
        throw Exception('Apenas emails corporativos @sani.med.br ou @sedanimed.br são permitidos');
      }
      
      print('🎉 Login OIDC bem-sucedido: ${userCredential.user?.email}');
      state = AsyncValue.data(userCredential.user);
      
    } on FirebaseAuthException catch (e) {
      print('💥 Erro Firebase Auth OIDC: ${e.code} - ${e.message}');
      
      String mensagemErro;
      switch (e.code) {
        case 'popup-closed-by-user':
          mensagemErro = 'Login cancelado.';
          break;
        case 'popup-blocked':
          mensagemErro = 'Popup bloqueado pelo navegador. Permita popups e tente novamente.';
          break;
        case 'network-request-failed':
          mensagemErro = 'Erro de conexão. Verifique sua internet.';
          break;
        case 'unauthorized-domain':
          mensagemErro = 'Domínio não autorizado. Contate o administrador.';
          break;
        case 'operation-not-allowed':
          mensagemErro = 'Operação não permitida. Verifique configuração do Firebase.';
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
  
  /// Faz login com email e senha (modo desenvolvimento ou fallback)
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    print('🔐 Tentativa de login iniciada para: $email');
    state = const AsyncValue.loading();
    
    try {
      // Verificar se o email termina com @sani.med.br
      if (!email.endsWith('@sani.med.br') && !email.endsWith('@sedanimed.br')) {
        print('❌ Email inválido: $email');
        throw Exception('Apenas emails corporativos @sani.med.br ou @sedanimed.br são permitidos');
      }
      
      // ========== MODO DESENVOLVIMENTO ==========
      if (_modoDesenvolvimento) {
        print('⚠️ MODO DESENVOLVIMENTO: Login simulado');
        print('✅ Email válido, simulando login...');
        
        // Qualquer senha funciona em modo dev
        await Future.delayed(const Duration(seconds: 1));
        
        // Criar usuário fake que se comporta como User do Firebase
        final fakeUser = _createFakeUser(email);
        
        print('🎉 Login simulado bem-sucedido para: $email');
        state = AsyncValue.data(fakeUser);
        return;
      }
      
      // ========== MODO PRODUÇÃO ==========
      // Em produção com OIDC, este método não deve ser usado
      // Redirecionar para signInWithOIDC
      print('⚠️ Redirecionando para login OIDC...');
      await signInWithOIDC();
      
    } catch (e) {
      print('💥 Erro: $e');
      state = AsyncValue.error('Erro ao fazer login: ${e.toString()}', StackTrace.current);
    }
  }

  /// Faz logout
  Future<void> signOut() async {
    try {
      print('🚪 Fazendo logout...');
      
      if (_modoDesenvolvimento) {
        // Modo dev: apenas limpar estado
        await Future.delayed(const Duration(milliseconds: 500));
        state = const AsyncValue.data(null);
        print('✅ Logout simulado');
        return;
      }
      
      // Modo produção: logout real do Firebase
      await FirebaseAuth.instance.signOut();
      state = const AsyncValue.data(null);
      print('✅ Logout realizado com sucesso');
    } catch (e) {
      print('💥 Erro ao fazer logout: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Envia email de recuperação de senha (não aplicável para OIDC)
  Future<void> resetPassword(String email) async {
    try {
      if (_modoDesenvolvimento) {
        print('⚠️ MODO DESENVOLVIMENTO: Simulando envio de email');
        await Future.delayed(const Duration(seconds: 1));
        print('✅ Email de recuperação simulado enviado');
        return;
      }
      
      // Em produção com OIDC, recuperação de senha é feita pelo provedor OIDC
      throw Exception('Recuperação de senha deve ser feita através do sistema corporativo');
      
    } catch (e) {
      print('💥 Erro: $e');
      throw Exception(e.toString());
    }
  }

  // ========== HELPER: Criar usuário fake para modo dev ==========
  User _createFakeUser(String email) {
    return _FakeUser(email: email);
  }
}

// ========== CLASSE AUXILIAR PARA MODO DEV ==========
class _FakeUser implements User {
  @override
  final String email;

  _FakeUser({required this.email});

  @override
  String? get displayName => email.split('@').first;

  @override
  String? get photoURL => null;

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  UserMetadata get metadata => _FakeUserMetadata();

  @override
  List<UserInfo> get providerData => [];

  @override
  String? get phoneNumber => null;

  @override
  String? get refreshToken => null;

  @override
  String? get tenantId => null;

  @override
  String get uid => email.hashCode.toString();

  @override
  Future<void> delete() async {}

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'fake-token';

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    throw UnimplementedError();
  }

  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) async {
    throw UnimplementedError();
  }

  @override
  Future<void> linkWithRedirect(AuthProvider provider) async {}

  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) async {
    throw UnimplementedError();
  }

  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}

  @override
  Future<User> unlink(String providerId) async => this;

  @override
  Future<void> updateDisplayName(String? displayName) async {}

  @override
  Future<void> updateEmail(String newEmail) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {}

  @override
  Future<void> updatePhotoURL(String? photoURL) async {}

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {}

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {}

  @override
  MultiFactor get multiFactor => throw UnimplementedError();

  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) async {
    throw UnimplementedError();
  }
}

class _FakeUserMetadata implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();

  @override
  DateTime? get lastSignInTime => DateTime.now();
}
