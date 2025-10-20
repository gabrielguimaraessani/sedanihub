# 📘 Guia de Integração - Distribuição de Serviços

Este guia explica como integrar a funcionalidade de **Distribuição de Serviços** no app SedaNiHub.

## ✅ Pré-requisitos

1. ✔️ Modelos criados em `lib/core/models/`
2. ✔️ Service criado em `lib/features/servicos/domain/services/`
3. ✔️ Widgets criados em `lib/features/servicos/presentation/widgets/`
4. ✔️ Página criada em `lib/features/servicos/presentation/pages/`
5. ✔️ Rota adicionada em `lib/core/router/app_router.dart`
6. ✔️ Dependência `intl` adicionada no `pubspec.yaml`

## 🔧 Instalação de Dependências

Execute no terminal:

```bash
flutter pub get
```

## 🏗️ Integração no Dashboard

### Passo 1: Criar Provider para Verificar se é Coordenador

Crie o arquivo `lib/core/providers/plantao_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plantao.dart';

/// Provider para verificar se o usuário é coordenador na data atual
final isCoordenadorHojeProvider = FutureProvider<bool>((ref) async {
  try {
    final authState = ref.watch(authNotifierProvider);
    
    final usuarioId = authState.when(
      data: (user) => user?.email,
      loading: () => null,
      error: (_, __) => null,
    );
    
    if (usuarioId == null) return false;
    
    final hoje = DateTime.now();
    final inicioDia = DateTime(hoje.year, hoje.month, hoje.day);
    
    final query = await FirebaseFirestore.instance
        .collection('plantoes')
        .where('usuario', isEqualTo: FirebaseFirestore.instance.doc('usuarios/$usuarioId'))
        .where('data', isEqualTo: Timestamp.fromDate(inicioDia))
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) return false;
    
    final plantao = Plantao.fromFirestore(query.docs.first);
    return plantao.isCoordenador;
  } catch (e) {
    print('Erro ao verificar se é coordenador: $e');
    return false;
  }
});
```

### Passo 2: Atualizar o Dashboard

No arquivo `lib/features/dashboard/presentation/pages/dashboard_page.dart`, adicione:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../servicos/presentation/widgets/distribuicao_feature_card.dart';
import '../../../../core/providers/plantao_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCoordenador = ref.watch(isCoordenadorHojeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SedaNiHub'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          // Cards existentes...
          FeatureCard(
            title: 'Serviços Pendentes',
            icon: Icons.pending_actions,
            onTap: () => context.push('/dashboard/servicos-pendentes'),
          ),
          
          // Card de Distribuição (APENAS para coordenadores)
          isCoordenador.when(
            data: (isCoordenador) {
              if (!isCoordenador) return const SizedBox.shrink();
              return const DistribuicaoFeatureCard();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // Demais cards...
        ],
      ),
    );
  }
}
```

### Alternativa: Verificação Local no Build

Se preferir uma abordagem mais simples sem provider:

```dart
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isCoordenador = false;
  bool _verificandoCoordenador = true;

  @override
  void initState() {
    super.initState();
    _verificarSeCoordenador();
  }

  Future<void> _verificarSeCoordenador() async {
    try {
      // Obter usuário atual do Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _verificandoCoordenador = false);
        return;
      }

      final hoje = DateTime.now();
      final inicioDia = DateTime(hoje.year, hoje.month, hoje.day);

      final query = await FirebaseFirestore.instance
          .collection('plantoes')
          .where('usuario', 
            isEqualTo: FirebaseFirestore.instance.doc('usuarios/${user.email}'))
          .where('data', isEqualTo: Timestamp.fromDate(inicioDia))
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final plantao = Plantao.fromFirestore(query.docs.first);
        setState(() {
          _isCoordenador = plantao.isCoordenador;
          _verificandoCoordenador = false;
        });
      } else {
        setState(() => _verificandoCoordenador = false);
      }
    } catch (e) {
      print('Erro ao verificar coordenador: $e');
      setState(() => _verificandoCoordenador = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SedaNiHub'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          // Cards normais...
          FeatureCard(
            title: 'Serviços Pendentes',
            icon: Icons.pending_actions,
            onTap: () => context.push('/dashboard/servicos-pendentes'),
          ),
          
          // Card de coordenador (condicional)
          if (!_verificandoCoordenador && _isCoordenador)
            const DistribuicaoFeatureCard(),
          
          // Demais cards...
        ],
      ),
    );
  }
}
```

## 🔐 Configurar Regras de Segurança no Firestore

Adicione ao arquivo `security/firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Função helper para verificar se é coordenador
    function isCoordenador() {
      let hoje = request.time.toMillis();
      let inicioDia = timestamp.date(hoje.year(), hoje.month(), hoje.day());
      
      return exists(/databases/$(database)/documents/plantoes/$(request.auth.uid))
        && get(/databases/$(database)/documents/plantoes/$(request.auth.uid)).data.posicao == 1
        && get(/databases/$(database)/documents/plantoes/$(request.auth.uid)).data.data == inicioDia;
    }
    
    // Usuários (todos autenticados podem ler, apenas admin pode escrever)
    match /usuarios/{usuarioId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && (request.auth.token.email.matches('.*@sedani\\.med\\.br$'));
    }
    
    // Plantões (todos podem ler, apenas coordenadores podem escrever)
    match /plantoes/{plantaoId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && isCoordenador();
      allow delete: if false; // Nunca deletar
    }
    
    // Escalas
    match /escalas/{escalaId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && isCoordenador();
      allow delete: if false;
      
      match /plantoes/{plantaoId} {
        allow read: if request.auth != null;
        allow create, update: if request.auth != null && isCoordenador();
        allow delete: if false;
      }
    }
    
    // Serviços
    match /servicos/{servicoId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null;
      allow delete: if false; // Nunca deletar
      
      // Subcoleção de anestesistas
      match /anestesistas/{anestesistaId} {
        allow read: if request.auth != null;
        allow create, update: if request.auth != null && isCoordenador();
        allow delete: if false;
      }
    }
  }
}
```

## 🧪 Testar a Integração

### 1. Criar Dados de Teste no Firestore

#### Criar Usuário:
```json
// Collection: usuarios
// Document ID: usuario@sedani.med.br
{
  "nomeCompleto": "Dr. João Silva",
  "crmDf": 12345,
  "email": "usuario@sedani.med.br",
  "funcaoAtual": "Senior",
  "gerencia": ["Nenhuma"],
  "dataCriacao": "2025-01-10T10:00:00Z",
  "ultimaModificacao": "2025-01-10T10:00:00Z"
}
```

#### Criar Plantão (Coordenador):
```json
// Collection: plantoes
// Document ID: auto-gerado
{
  "usuario": "usuarios/usuario@sedani.med.br", // Referência
  "data": "2025-01-10T00:00:00Z", // Data de hoje
  "turnos": ["Manha", "Tarde"],
  "posicao": 1, // COORDENADOR
  "dataCriacao": "2025-01-10T10:00:00Z",
  "ultimaModificacao": "2025-01-10T10:00:00Z"
}
```

#### Criar Serviço:
```json
// Collection: servicos
// Document ID: auto-gerado
{
  "paciente": "pacientes/paciente-123", // Referência
  "procedimentos": [],
  "cirurgioes": [],
  "inicio": "2025-01-10T14:00:00Z",
  "duracao": 120,
  "local": "Centro Cirúrgico",
  "leito": "Sala 1",
  "finalizado": false,
  "dataCriacao": "2025-01-10T10:00:00Z",
  "ultimaModificacao": "2025-01-10T10:00:00Z"
}
```

### 2. Rodar o App

```bash
flutter run
```

### 3. Verificar

1. ✅ Login com o usuário criado
2. ✅ Dashboard deve mostrar o card "Distribuição de Serviços"
3. ✅ Tocar no card abre a página de distribuição
4. ✅ Deve mostrar o serviço na aba "Sem Atribuição"
5. ✅ Atribuir o serviço a um plantonista
6. ✅ Verificar detecção de conflitos

## 🐛 Troubleshooting

### Problema: Card não aparece no dashboard

**Solução:**
- Verificar se o usuário tem plantão na data atual
- Verificar se a posição do plantão é 1
- Verificar logs do console

### Problema: Erro ao carregar serviços

**Solução:**
- Verificar regras de segurança do Firestore
- Verificar se as coleções existem
- Verificar formato dos documentos

### Problema: Detecção de conflitos não funciona

**Solução:**
- Verificar se os serviços têm campo `duracao`
- Verificar cálculo de `fimPrevisto`
- Verificar lógica em `hasConflict()`

## 📚 Recursos Adicionais

- [Documentação completa](./lib/features/servicos/README.md)
- [Modelo de dados](./documentation/data/colecoes_sedanihub.md)
- [Firebase Firestore Rules](https://firebase.google.com/docs/firestore/security/get-started)

## ⚡ Próximos Passos

1. ✅ Testar com dados reais
2. ✅ Ajustar layout conforme feedback
3. ✅ Adicionar analytics/tracking
4. ✅ Implementar notificações
5. ✅ Adicionar modo offline

## 🎉 Conclusão

A funcionalidade de Distribuição de Serviços está pronta para uso! Siga este guia para integrar no app e começar a usar.

Para dúvidas ou sugestões, consulte a documentação ou entre em contato com a equipe de desenvolvimento.

