# SedaniHub - Sistema Corporativo SedaniMed

Uma aplicação Flutter reativa e multi-tela para usuários autenticados com domínio @sani.med.br, integrando Firebase, Google Gemini e Vertex AI corporativo.

## 🚀 Funcionalidades

- **Autenticação Segura**: Acesso restrito a emails corporativos @sani.med.br
- **Integração Firebase**: Leitura e escrita de dados corporativos
- **Google Gemini**: Processamento de texto com IA avançada
- **Vertex AI**: IA corporativa para processamento avançado
- **Interface Reativa**: Design moderno e responsivo
- **Multi-tela**: Navegação fluida entre diferentes funcionalidades

## 📋 Pré-requisitos

- Flutter SDK 3.0.0 ou superior
- Dart SDK 3.0.0 ou superior
- Firebase project configurado
- Google Cloud Platform account (para Vertex AI)
- Google AI API key (para Gemini)

## 🛠️ Configuração

### 1. Clone o repositório
```bash
git clone <repository-url>
cd sanihub
```

### 2. Instale as dependências
```bash
flutter pub get
```

### 3. Configure o Firebase
1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione um app Android/iOS ao projeto
3. Baixe o arquivo `google-services.json` (Android) ou `GoogleService-Info.plist` (iOS)
4. Coloque os arquivos na pasta apropriada:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 4. Configure as chaves API
1. **Google Gemini**: Obtenha uma API key em [Google AI Studio](https://makersuite.google.com/app/apikey)
2. **Vertex AI**: Configure as credenciais do Google Cloud Platform

### 5. Atualize as configurações
Edite os seguintes arquivos com suas credenciais:

#### `lib/core/config/firebase_options.dart`
```dart
// Substitua as chaves de exemplo pelas suas chaves reais
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'sua-web-api-key',
  appId: '1:seu-project-id:web:seu-app-id',
  // ... outras configurações
);
```

#### `lib/core/providers/gemini_provider.dart`
```dart
_model = GenerativeModel(
  model: 'gemini-pro',
  apiKey: 'SUA_GEMINI_API_KEY', // Substitua pela sua chave
);
```

#### `lib/core/providers/vertex_ai_provider.dart`
```dart
_projectId = 'SEU_PROJECT_ID'; // Substitua pelo seu Project ID
```

### 6. Execute a aplicação
```bash
flutter run
```

## 🏗️ Arquitetura

### Estrutura de Pastas
```
lib/
├── core/
│   ├── config/          # Configurações (Firebase, etc.)
│   ├── providers/       # Providers Riverpod
│   ├── router/          # Configuração de rotas
│   └── theme/           # Temas da aplicação
├── features/
│   ├── auth/            # Autenticação
│   ├── dashboard/       # Dashboard principal
│   ├── ai/              # Integração com IA
│   └── profile/         # Perfil do usuário
└── main.dart           # Ponto de entrada
```

### Tecnologias Utilizadas
- **Flutter**: Framework de UI
- **Riverpod**: Gerenciamento de estado reativo
- **Go Router**: Navegação declarativa
- **Firebase**: Backend e autenticação
- **Google Gemini**: IA para processamento de texto
- **Vertex AI**: IA corporativa avançada

## 🔐 Segurança

- Acesso restrito a emails @sani.med.br
- Autenticação Firebase segura
- Credenciais protegidas
- Validação de entrada de dados

## 📱 Funcionalidades por Tela

### 1. Splash Screen
- Carregamento inicial
- Verificação de autenticação
- Redirecionamento automático

### 2. Login
- Validação de email corporativo
- Recuperação de senha
- Interface intuitiva

### 3. Dashboard
- Visão geral do sistema
- Acesso rápido às funcionalidades
- Informações do usuário

### 4. Google Gemini
- Chat interativo com IA
- Processamento de texto
- Interface de conversa

### 5. Vertex AI
- IA corporativa avançada
- Processamento de dados complexos
- Integração com Google Cloud

### 6. Perfil
- Informações do usuário
- Configurações da conta
- Logout seguro

## 🚀 Deploy

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é propriedade da SaniMed e é destinado apenas para uso corporativo interno.

## 📞 Suporte

Para suporte técnico, entre em contato com a equipe de TI da SaniMed.

---

**SaniHub** - Sistema Corporativo SaniMed v1.0.0
