# 🔐 Configuração das Credenciais OIDC

## ⚠️ IMPORTANTE: Segurança

As credenciais OIDC estão protegidas e **NÃO estão no GitHub**!

## 📁 Arquivos

### ✅ Commitado (Seguro)
- `lib/core/config/oidc_credentials.example.dart` - Exemplo/template
- `.gitignore` - Protege credenciais

### ❌ NÃO Commitado (Protegido)
- `lib/core/config/oidc_credentials.dart` - **Credenciais REAIS** 🔒

---

## 🔧 Configuração no Firebase Console

### Dados para Configurar

**Authentication → Sign-in Method → OpenID Connect → Add Provider**

```
Nome: Google Workspace SANI
ID do provedor: oidc.google-workspace-sani
Emissor (URL): https://accounts.google.com
ID do cliente: [Ver arquivo local: lib/core/config/oidc_credentials.dart]
Chave secreta do cliente: [Ver arquivo local: lib/core/config/oidc_credentials.dart]
```

**Callback URL (OAuth redirect URI)**:
```
https://sani-hub.firebaseapp.com/__/auth/handler
```

⚠️ **As credenciais reais estão em**: `lib/core/config/oidc_credentials.dart` (arquivo local, não no GitHub)

### Escopos (Scopes)

Adicionar:
- `openid` ✅
- `email` ✅
- `profile` ✅

---

## 🔒 Segurança das Credenciais

### No Repositório Git

✅ **Protegido pelo .gitignore**:
```gitignore
lib/core/config/oidc_credentials.dart
```

### Arquivo Real (Local Apenas)

O arquivo `lib/core/config/oidc_credentials.dart` contém as credenciais reais e está **apenas no seu computador**.

### Arquivo Exemplo (GitHub)

O arquivo `lib/core/config/oidc_credentials.example.dart` é um template sem credenciais reais.

### Para Outros Desenvolvedores

Se outro desenvolvedor clonar o projeto:

1. Copiar `oidc_credentials.example.dart` para `oidc_credentials.dart`
2. Preencher com as credenciais reais (solicitar ao admin)
3. Nunca fazer commit do arquivo real

---

## 📋 Checklist de Configuração

### No Firebase Console (https://console.firebase.google.com)

- [ ] Abrir projeto **sani-hub**
- [ ] Authentication → Sign-in method
- [ ] OpenID Connect → Adicionar provedor
- [ ] Preencher dados:
  - Nome: `Google Workspace SANI`
  - ID: `oidc.google-workspace-sani`
  - Emissor: `https://accounts.google.com`
  - Client ID: [Ver lib/core/config/oidc_credentials.dart]
  - Client Secret: [Ver lib/core/config/oidc_credentials.dart]
- [ ] Callback: `https://sani-hub.firebaseapp.com/__/auth/handler`
- [ ] Escopos: `openid`, `email`, `profile`
- [ ] ✅ Ativar
- [ ] Salvar

### No Código

Já configurado! ✅
- Provider ID atualizado: `oidc.google-workspace-sani`
- Credenciais protegidas no .gitignore

### Ativar Modo Produção (Quando Configurar Firebase)

```dart
// lib/core/providers/auth_provider.dart - linha 24
static const bool _modoDesenvolvimento = false;

// lib/features/auth/presentation/pages/login_page.dart - linha 183
const bool modoDesenvolvimento = false;
```

---

## 🚀 Testando

### Modo Dev (Atual)
```
Email: teste@sani.med.br
Senha: 123456
```

### Modo Produção (Após Configurar)
1. Clicar em "Entrar com Sistema Corporativo"
2. Popup do Google Workspace abre
3. Fazer login com conta @sani.med.br
4. Retorna autenticado automaticamente

---

## ⚠️ NUNCA Commitar

❌ **NUNCA** fazer commit de:
- `lib/core/config/oidc_credentials.dart`
- Client ID e Client Secret
- Tokens de acesso
- Chaves API

✅ **SEMPRE** usar:
- `.gitignore` para proteger
- Arquivo `.example` como template
- Variáveis de ambiente em produção

---

## 📚 Referências

- [Firebase OIDC Documentation](https://firebase.google.com/docs/auth/web/openid-connect)
- [Google Cloud OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)
- [Best Practices for API Keys](https://cloud.google.com/docs/authentication/api-keys)

