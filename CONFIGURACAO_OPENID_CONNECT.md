# 🔐 Configuração OpenID Connect (OIDC) - SedaniHub

Guia para configurar autenticação corporativa usando OpenID Connect no Firebase.

## 📋 Informações do Projeto

- **Projeto Firebase**: `sani-hub`
- **Método de Autenticação**: OpenID Connect (OIDC)
- **Callback URL**: `https://sani-hub.firebaseapp.com/__/auth/handler`
- **Domínios Permitidos**: `@sani.med.br`, `@sedanimed.br`

---

## 🎯 Como Funciona

### Fluxo de Autenticação OIDC

```
Usuário clica "Entrar com Sistema Corporativo"
    ↓
Firebase abre popup/redirect para provedor OIDC
    ↓
Usuário faz login no sistema corporativo (SSO)
    ↓
Provedor OIDC redireciona de volta com token
    ↓
Firebase valida token e cria sessão
    ↓
App recebe usuário autenticado
    ↓
Dashboard carrega
```

### Benefícios do OIDC

✅ **Single Sign-On (SSO)**: Login único para todos os sistemas  
✅ **Segurança Centralizada**: Gerenciada pelo provedor corporativo  
✅ **Sem Gerenciamento de Senhas**: Firebase não armazena senhas  
✅ **Integração Corporativa**: Usa identidade corporativa existente  
✅ **MFA Integrado**: Se provedor tiver MFA, funciona automaticamente  

---

## 🔧 Configuração no Firebase Console

### 1. Habilitar Provider OIDC

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Selecione projeto: **sani-hub**
3. Vá em **Authentication** → **Sign-in method**
4. Role até **"Outros provedores"** ou **"Additional providers"**
5. Clique em **"OpenID Connect"**

### 2. Adicionar Provider

Clique em **"Adicionar novo provedor"** e preencha:

#### Informações Básicas

- **Nome**: `sani-med` (ou nome do seu provedor)
- **ID do provedor**: `oidc.sani-med` ⚠️ **Importante**: Deve ser igual ao código
- **ID do cliente**: (fornecido pelo seu provedor OIDC)
- **Segredo do cliente**: (fornecido pelo seu provedor OIDC)
- **Emissor (Issuer)**: URL do provedor OIDC
  - Exemplo: `https://login.sani.med.br`
  - Ou: `https://accounts.google.com` (se usar Google Workspace)

#### Callback URL

- **URL de redirecionamento**: `https://sani-hub.firebaseapp.com/__/auth/handler`
- ⚠️ **Registre esta URL no seu provedor OIDC!**

#### Escopos (Scopes)

Adicionar escopos necessários:
- `openid` (obrigatório)
- `email` (recomendado)
- `profile` (recomendado)

#### Mapeamento de Claims

Se o provedor usar claims customizados, mapear:
- **Email**: `email` ou `preferred_username`
- **Nome**: `name` ou `given_name`

### 3. Habilitar

- Marcar ✅ **"Ativado"** ou **"Enabled"**
- Clicar em **"Salvar"**

---

## 💻 Configuração no Código

### Já Implementado! ✅

O código já está pronto em:
- `lib/core/providers/auth_provider.dart`
- `lib/features/auth/presentation/pages/login_page.dart`

### ID do Provider

```dart
// lib/core/providers/auth_provider.dart - linha 18
static const String oidcProviderId = 'oidc.sani-med';
```

⚠️ **Importante**: Este ID deve ser **exatamente igual** ao configurado no Firebase Console!

### Alternar Entre Dev e Produção

```dart
// lib/core/providers/auth_provider.dart - linha 22
static const bool _modoDesenvolvimento = false; // ← Mudar para false

// lib/features/auth/presentation/pages/login_page.dart - linha 183
const bool modoDesenvolvimento = false; // ← Mudar para false
```

---

## 🚀 Uso no App

### Modo Desenvolvimento (Atual)

**Tela de login mostra:**
- ⚠️ Aviso: "MODO DESENVOLVIMENTO"
- 📧 Campos de Email e Senha
- 🔑 Botão "Entrar" (qualquer senha funciona)

**Para testar:**
```
Email: teste@sani.med.br
Senha: 123456
```

### Modo Produção (OIDC Configurado)

**Tela de login mostra:**
- 🏢 Botão destacado: "Entrar com Sistema Corporativo"
- ➖ Divisor "ou"
- 📧 Campos de Email e Senha (fallback)
- 🔑 Botão "Entrar"

**Fluxo:**
1. Usuário clica "Entrar com Sistema Corporativo"
2. Popup/redirect para login corporativo
3. Login no sistema corporativo (SSO)
4. Redirecionado de volta autenticado

---

## 🌐 Plataformas

### Web (signInWithPopup)

```dart
// Usa popup para login OIDC
await FirebaseAuth.instance.signInWithPopup(provider);
```

✅ **Já implementado** em `auth_provider.dart`

### Android (signInWithProvider)

```dart
// Android usa redirect nativo
await FirebaseAuth.instance.signInWithProvider(provider);
```

### iOS (signInWithProvider)

```dart
// iOS usa redirect nativo
await FirebaseAuth.instance.signInWithProvider(provider);
```

**Nota**: O mesmo código funciona em todas as plataformas! O Firebase abstrai as diferenças.

---

## ⚙️ Configuração do Provedor OIDC

### Se usar Google Workspace

1. **Firebase Console** → Authentication → OpenID Connect
2. Preencher:
   - **Nome**: Google Workspace
   - **ID do provedor**: `oidc.google-workspace`
   - **ID do cliente**: (do Google Cloud Console)
   - **Segredo**: (do Google Cloud Console)
   - **Emissor**: `https://accounts.google.com`

### Se usar Azure AD

1. **Firebase Console** → Authentication → OpenID Connect
2. Preencher:
   - **Nome**: Azure AD
   - **ID do provedor**: `oidc.azure-ad`
   - **ID do cliente**: (do Azure Portal)
   - **Segredo**: (do Azure Portal)
   - **Emissor**: `https://login.microsoftonline.com/{tenant-id}/v2.0`

### Se usar provedor customizado

Consulte a documentação do seu provedor OIDC corporativo para:
- Client ID
- Client Secret  
- Issuer URL
- Scopes necessários

---

## 🔒 Segurança

### Validação de Email

O código verifica se o email é corporativo:

```dart
if (!email.endsWith('@sani.med.br') && !email.endsWith('@sedanimed.br')) {
  // Fazer logout e negar acesso
  await FirebaseAuth.instance.signOut();
  throw Exception('Apenas emails corporativos são permitidos');
}
```

### Regras do Firestore

```javascript
function isSedaniUser() {
  return isAuthenticated() && 
         (request.auth.token.email.matches('.*@sedanimed\\.br$') ||
          request.auth.token.email.matches('.*@sani\\.med\\.br$'));
}
```

Mesmo que alguém consiga fazer login, as regras do Firestore bloqueiam se não for do domínio correto.

---

## 📝 Checklist de Configuração OIDC

### No Console do Provedor OIDC (Google Workspace/Azure/Outro)

- [ ] Criar aplicação OAuth 2.0/OIDC
- [ ] Configurar Callback URL: `https://sani-hub.firebaseapp.com/__/auth/handler`
- [ ] Obter Client ID
- [ ] Obter Client Secret
- [ ] Anotar Issuer URL
- [ ] Configurar escopos: `openid`, `email`, `profile`
- [ ] Restringir acesso a domínio `@sani.med.br`

### No Firebase Console

- [ ] Authentication → Sign-in method → OpenID Connect
- [ ] Adicionar novo provedor
- [ ] Nome: `sani-med`
- [ ] ID do provedor: `oidc.sani-med`
- [ ] Preencher Client ID
- [ ] Preencher Client Secret
- [ ] Preencher Issuer URL
- [ ] Adicionar escopos
- [ ] Ativar provider
- [ ] Salvar

### No Código

- [ ] Verificar `oidcProviderId` em `auth_provider.dart` (linha 18)
- [ ] Mudar `_modoDesenvolvimento` para `false` (linha 22)
- [ ] Mudar `modoDesenvolvimento` em `login_page.dart` (linha 183)
- [ ] Testar login OIDC

---

## 🧪 Testar OIDC

### 1. Modo Desenvolvimento (Atual)

```
Email: teste@sani.med.br
Senha: 123456 (qualquer)
```

### 2. Modo Produção (OIDC)

1. Clicar botão "Entrar com Sistema Corporativo"
2. Popup abre com login corporativo
3. Fazer login com credenciais corporativas
4. Automático! ✨

---

## 🐛 Troubleshooting

### Erro: "popup-blocked"

**Solução**: Permitir popups para `sani-hub.firebaseapp.com`

### Erro: "unauthorized-domain"

**Solução**: Adicionar domínio em:
- Firebase Console → Authentication → Settings → Authorized domains

### Erro: "invalid-oauth-client-id"

**Solução**: Verificar Client ID no Firebase Console

### Erro: "redirect-uri-mismatch"

**Solução**: Verificar callback URL no provedor OIDC:
- Deve ser: `https://sani-hub.firebaseapp.com/__/auth/handler`

### Popup não abre

**Web**: Verificar se navegador não bloqueou popup  
**Mobile**: Usar redirect ao invés de popup

---

## 📱 Implementação Mobile (Futuro)

Para Android/iOS, usar redirect ao invés de popup:

```dart
// Para mobile
if (Platform.isAndroid || Platform.isIOS) {
  await FirebaseAuth.instance.signInWithProvider(provider);
} else {
  // Web usa popup
  await FirebaseAuth.instance.signInWithPopup(provider);
}
```

---

## 📚 Referências

- [Firebase OIDC Web](https://firebase.google.com/docs/auth/web/openid-connect?hl=pt-br)
- [Firebase OIDC iOS](https://firebase.google.com/docs/auth/ios/openid-connect)
- [Firebase OIDC Android](https://firebase.google.com/docs/auth/android/openid-connect)
- [OAuth Provider Reference](https://firebase.google.com/docs/reference/js/auth.oauthprovider)

---

## 🎯 Próximos Passos

### Agora (Modo Dev):

✅ App funciona com login simulado  
✅ Teste toda a interface  
✅ Email: `teste@sani.med.br`, Senha: `123456`

### Depois (Configurar OIDC):

1. 📋 Obter credenciais OIDC do provedor corporativo
2. ⚙️ Configurar provider no Firebase Console
3. 🔄 Mudar flags de desenvolvimento para `false`
4. 🚀 Testar login com sistema corporativo

---

**Status Atual**: ✅ Código pronto para OIDC, aguardando configuração do provedor

