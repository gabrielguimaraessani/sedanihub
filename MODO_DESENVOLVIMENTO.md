# 🛠️ Modo de Desenvolvimento - SedaniHub

O app possui um **modo de desenvolvimento** que permite testar sem configurar o Firebase.

## 🎯 Como Funciona

### Modo Atual: **DESENVOLVIMENTO** ✅

O app está configurado para funcionar **sem Firebase**:
- ✅ Login simulado (qualquer senha funciona)
- ✅ Todas as funcionalidades de UI funcionam
- ❌ Dados NÃO são salvos (apenas em memória)
- ❌ Notificações NÃO persistem
- ❌ Chat NÃO sincroniza entre dispositivos

### Para Usar:

1. **Email**: qualquer email terminando em `@sani.med.br`
   - Exemplo: `gabriel@sani.med.br`
   - Exemplo: `teste@sani.med.br`
   - Exemplo: `admin@sani.med.br`

2. **Senha**: **QUALQUER SENHA** (pode ser `123456`, `teste`, etc)

3. Clicar em **"Entrar"**

4. ✅ Login bem-sucedido!

---

## 🔄 Mudar para Modo Produção (Firebase Real)

### Quando Configurar Firebase:

1. Seguir guia: `SETUP_FIREBASE_PASSO_A_PASSO.md`
2. Criar projeto, usuários, etc
3. **Editar**: `lib/core/providers/auth_provider.dart`
4. Mudar linha 13:

```dart
// ANTES (Modo Desenvolvimento)
static const bool _modoDesenvolvimento = true;

// DEPOIS (Modo Produção - Firebase Real)
static const bool _modoDesenvolvimento = false;
```

5. Salvar e reiniciar o app
6. Agora precisa de usuário/senha real do Firebase!

---

## 🎨 Visual do Login

### Modo Desenvolvimento (Atual)

```
┌─────────────────────────────┐
│ 🏥 Logo SedaniHub           │
│                             │
│ Bem-vindo ao SedaniHub      │
│ Faça login com sua conta    │
│                             │
│ Email: teste@sani.med.br    │
│ Senha: 123456 (qualquer)    │
│                             │
│ [  ENTRAR  ]                │
│                             │
│ ⚠️ MODO DESENVOLVIMENTO     │
│ Dados não são salvos        │
└─────────────────────────────┘
```

### Logs do Console (Modo Dev)

```
🔐 Tentativa de login iniciada para: teste@sani.med.br
⚠️ MODO DESENVOLVIMENTO: Login simulado
✅ Email válido, simulando login...
🎉 Login simulado bem-sucedido para: teste@sani.med.br
```

---

## ⚡ Quick Start (Desenvolvimento)

```bash
# 1. Rodar o app
flutter run -d chrome

# 2. Fazer login
Email: teste@sani.med.br
Senha: 123456

# 3. Usar o app normalmente!
```

**Tudo funciona exceto**:
- Dados não persistem (apenas na sessão)
- Chat não sincroniza
- Notificações não ficam salvas

---

## 🔥 Quando Configurar Firebase

### O que muda:

| Funcionalidade | Modo Dev | Modo Produção |
|----------------|----------|---------------|
| **Login** | Qualquer senha | Senha real do Firebase |
| **Dados** | Na memória | Firestore (persistente) |
| **Chat** | Não sincroniza | Tempo real entre usuários |
| **Notificações** | Não persistem | Persistem no Firestore |
| **Filas** | Não compartilhadas | Compartilhadas entre todos |

### Quando configurar:

✅ **Agora**: Para testar UI e funcionalidades  
✅ **Depois**: Para usar em produção com dados reais

---

## 🎯 Configurar Firebase em 3 Passos

### 1. Firebase Console (~15 min)
```
1. Criar projeto
2. Authentication → Habilitar Email/Password
3. Authentication → Criar usuário (email + senha REAL)
4. Firestore → Criar database
```

### 2. Terminal (~5 min)
```bash
firebase login
firebase init firestore
firebase deploy --only firestore:rules
```

### 3. Código (~1 min)
```dart
// lib/core/providers/auth_provider.dart
static const bool _modoDesenvolvimento = false; // ← Mudar aqui
```

**Guia completo**: `SETUP_FIREBASE_PASSO_A_PASSO.md`

---

## ❓ FAQ

### Qual senha usar agora?
**Qualquer senha!** Em modo dev, qualquer senha funciona. Basta o email terminar com `@sani.med.br`.

### Preciso configurar Firebase agora?
**Não!** Você pode testar toda a UI em modo dev. Configure Firebase quando quiser dados persistentes.

### Como saber se estou em modo dev?
Veja os logs no console:
- **Modo Dev**: `⚠️ MODO DESENVOLVIMENTO: Login simulado`
- **Modo Produção**: `✅ Email válido, autenticando no Firebase...`

### Posso deixar em modo dev para sempre?
**Não recomendado!** Modo dev é apenas para:
- Desenvolvimento local
- Testes de UI
- Demonstrações

Para uso real, **configure o Firebase**.

---

## 🎉 Pronto para Usar!

### Login de Teste (Modo Dev):

```
Email: teste@sani.med.br
Senha: 123456
```

ou

```
Email: seu.nome@sani.med.br
Senha: qualquercoisa
```

**Funciona! 🚀**

Quando quiser dados reais persistentes, siga o `SETUP_FIREBASE_PASSO_A_PASSO.md`

