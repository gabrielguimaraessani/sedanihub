# Assinatura de Avaliações — SedaNiHub

Este módulo fornece:
1) **Regras do Firestore** com validações de schema e bloqueio pós-assinatura.
2) **Cloud Function (`signEvaluation`)** que:
   - Verifica se a avaliação não está assinada;
   - Calcula `hashConteudo` (SHA-256) com serialização determinística;
   - Lê o `hash` da última avaliação assinada e grava em `hashAvaliacaoAnterior` (cadeia imutável);
   - Define `dataAssinatura` via `serverTimestamp`.

## Deploy

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

## Uso (Flutter)

```dart
final callable = FirebaseFunctions.instance.httpsCallable('signEvaluation');
final res = await callable.call({'avaliacaoId': '<ID>'});
print(res.data); // { status: "ok", hashConteudo: "...", hashAvaliacaoAnterior: "..." }
```

## Observações
- A **Admin SDK** ignora rules, então o cliente não consegue assinar: somente a Function assina.
- Garanta que o cliente **não** consegue escrever `dataAssinatura`, `hashConteudo` ou `hashAvaliacaoAnterior` (já coberto nas rules).
- Se desejar, use uma coleção `ledgerAnchor` para guardar o último hash e evitar busca por `orderBy`.
