# 🔧 Guia de Configuração - SaniHub

Este guia irá ajudá-lo a configurar o SaniHub com todas as integrações necessárias.

## 📋 Checklist de Configuração

### 1. ✅ Configuração do Firebase

1. **Criar projeto Firebase:**
   - Acesse [Firebase Console](https://console.firebase.google.com/)
   - Clique em "Adicionar projeto"
   - Nome: `SaniHub` ou similar
   - Ative o Google Analytics (opcional)

2. **Configurar Authentication:**
   - No console Firebase, vá para "Authentication"
   - Clique em "Começar"
   - Vá para "Sign-in method"
   - Ative "Email/senha"
   - Configure domínios autorizados para @sani.med.br

3. **Configurar Firestore:**
   - Vá para "Firestore Database"
   - Clique em "Criar banco de dados"
   - Escolha "Modo de produção"
   - Selecione uma localização (ex: us-central1)

4. **Baixar arquivos de configuração:**
   - Vá para "Configurações do projeto" > "Seus apps"
   - Adicione um app Android
   - Package name: `com.sani.med.sanihub`
   - Baixe `google-services.json`
   - Coloque em `android/app/google-services.json`

5. **Atualizar firebase_options.dart:**
   - Execute: `flutterfire configure`
   - Ou edite manualmente `lib/core/config/firebase_options.dart`

### 2. ✅ Configuração do Google Gemini

1. **Obter API Key:**
   - Acesse [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Faça login com sua conta Google
   - Clique em "Create API Key"
   - Copie a chave gerada

2. **Configurar no código:**
   - Edite `lib/core/providers/gemini_provider.dart`
   - Substitua `'YOUR_GEMINI_API_KEY'` pela sua chave real

### 3. ✅ Configuração do Vertex AI

1. **Configurar Google Cloud Platform:**
   - Acesse [Google Cloud Console](https://console.cloud.google.com/)
   - Crie um novo projeto ou selecione um existente
   - Ative a API do Vertex AI
   - Ative a API do AI Platform

2. **Configurar Service Account:**
   - Vá para "IAM & Admin" > "Service Accounts"
   - Clique em "Create Service Account"
   - Nome: `sanihub-vertex-ai`
   - Role: "Vertex AI User"
   - Baixe o arquivo JSON de credenciais

3. **Configurar no código:**
   - Edite `lib/core/providers/vertex_ai_provider.dart`
   - Substitua `'YOUR_PROJECT_ID'` pelo seu Project ID
   - Adicione as credenciais do Service Account

### 4. ✅ Configuração do Ambiente de Desenvolvimento

1. **Instalar dependências:**
   ```bash
   flutter pub get
   ```

2. **Gerar código:**
   ```bash
   dart run build_runner build
   ```

3. **Configurar credenciais:**
   - Copie `lib/core/config/credentials_example.dart`
   - Renomeie para `credentials.dart`
   - Adicione suas credenciais reais

### 5. ✅ Teste da Configuração

1. **Executar aplicação:**
   ```bash
   flutter run
   ```

2. **Testar funcionalidades:**
   - ✅ Login com email @sani.med.br
   - ✅ Navegação entre telas
   - ✅ Chat com Gemini
   - ✅ Chat com Vertex AI
   - ✅ Perfil do usuário

## 🔐 Configurações de Segurança

### Firebase Security Rules

Configure as regras do Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir apenas usuários autenticados com email @sani.med.br
    match /{document=**} {
      allow read, write: if request.auth != null 
        && request.auth.token.email.matches('.*@sani\\.med\\.br$');
    }
  }
}
```

### Autenticação Firebase

Configure domínios autorizados:
- Adicione `sani.med.br` aos domínios autorizados
- Configure redirecionamentos apropriados

## 🚨 Solução de Problemas

### Erro: "Firebase not initialized"
- Verifique se `google-services.json` está no local correto
- Execute `flutter clean` e `flutter pub get`

### Erro: "Invalid API key"
- Verifique se as chaves API estão corretas
- Confirme se as APIs estão ativadas no Google Cloud

### Erro: "Permission denied"
- Verifique as regras do Firestore
- Confirme se o usuário está autenticado
- Verifique se o email termina com @sani.med.br

### Erro: "Build failed"
- Execute `flutter clean`
- Execute `dart run build_runner clean`
- Execute `dart run build_runner build --delete-conflicting-outputs`

## 📞 Suporte

Se encontrar problemas:

1. Verifique os logs do Flutter: `flutter logs`
2. Verifique os logs do Firebase Console
3. Consulte a documentação oficial:
   - [Firebase Flutter](https://firebase.flutter.dev/)
   - [Google Gemini](https://ai.google.dev/docs)
   - [Vertex AI](https://cloud.google.com/vertex-ai/docs)

---

**SaniHub** - Sistema Corporativo SaniMed
