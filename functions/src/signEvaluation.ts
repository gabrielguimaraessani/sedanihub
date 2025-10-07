import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as crypto from "crypto";

admin.initializeApp();
const db = admin.firestore();

/**
 * Deterministic JSON stringify to ensure stable hashing.
 */
function stableStringify(obj: any): string {
  const allKeys = new Set<string>();
  JSON.stringify(obj, (key, value) => { allKeys.add(key); return value; });
  return JSON.stringify(obj, Array.from(allKeys).sort());
}

function sha256(input: string): string {
  return crypto.createHash("sha256").update(input).digest("hex");
}

export const signEvaluation = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Auth required.");
  }

  const avaliacaoId: string = data.avaliacaoId;
  if (!avaliacaoId) {
    throw new functions.https.HttpsError("invalid-argument", "avaliacaoId is required.");
  }

  const docRef = db.collection("avaliacoesAnestesicas").doc(avaliacaoId);
  const snap = await docRef.get();
  if (!snap.exists) {
    throw new functions.https.HttpsError("not-found", "Avaliação não encontrada.");
  }

  const current = snap.data() || {};
  if (current.dataAssinatura) {
    throw new functions.https.HttpsError("failed-precondition", "Avaliação já assinada.");
  }

  // Read last document by creation (or use a dedicated anchor collection for last hash)
  const lastSnap = await db.collection("avaliacoesAnestesicas")
    .orderBy("dataAssinatura", "desc")
    .limit(1)
    .get();

  const lastHash = (lastSnap.empty ? null : lastSnap.docs[0].get("hashConteudo")) || null;

  // Prepare content to hash (exclude signature/hash fields)
  const contentForHash = { ...current };
  delete contentForHash["dataAssinatura"];
  delete contentForHash["hashConteudo"];
  delete contentForHash["hashAvaliacaoAnterior"];

  const payload = stableStringify(contentForHash);
  const hashConteudo = sha256(payload);

  const now = admin.firestore.FieldValue.serverTimestamp();

  await docRef.update({
    dataAssinatura: now,
    hashConteudo,
    hashAvaliacaoAnterior: lastHash,
  });

  return { status: "ok", hashConteudo, hashAvaliacaoAnterior: lastHash };
});
