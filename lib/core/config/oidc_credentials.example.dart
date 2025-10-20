/// ARQUIVO DE EXEMPLO - Copie para oidc_credentials.dart e preencha com suas credenciais
/// 
/// Este arquivo mostra a estrutura necessária para as credenciais OIDC.
/// NÃO coloque credenciais reais aqui!

class OIDCCredentials {
  // Provider configuration
  static const String providerName = 'Google Workspace SANI';
  static const String providerId = 'oidc.google-workspace-sani';
  
  // OAuth 2.0 credentials
  static const String clientId = 'SEU_CLIENT_ID_AQUI.apps.googleusercontent.com';
  static const String clientSecret = 'SEU_CLIENT_SECRET_AQUI';
  
  // Issuer URL
  static const String issuerUrl = 'https://accounts.google.com';
  
  // Callback URL (configurado no Firebase)
  static const String callbackUrl = 'https://sani-hub.firebaseapp.com/__/auth/handler';
  
  // Scopes necessários
  static const List<String> scopes = [
    'openid',
    'email',
    'profile',
  ];
}

