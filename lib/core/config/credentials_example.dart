// Arquivo de exemplo para credenciais
// Copie este arquivo para lib/core/config/credentials.dart
// e adicione suas credenciais reais

class Credentials {
  // Firebase
  static const String firebaseProjectId = 'seu-project-id';
  
  // Google Gemini
  static const String geminiApiKey = 'sua-gemini-api-key';
  
  // Vertex AI
  static const String vertexAiProjectId = 'seu-vertex-ai-project-id';
  static const String vertexAiLocation = 'us-central1';
  
  // Google Cloud Service Account (para Vertex AI)
  static const Map<String, dynamic> serviceAccountCredentials = {
    // Adicione suas credenciais de service account aqui
  };
}
