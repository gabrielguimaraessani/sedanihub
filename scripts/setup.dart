import 'dart:io';

void main() async {
  print('🚀 Configurando SedaniHub...');
  
  // Criar diretórios necessários
  await _createDirectories();
  
  // Gerar arquivos de código
  await _generateCodeFiles();
  
  print('✅ Configuração concluída!');
  print('');
  print('📋 Próximos passos:');
  print('1. Configure suas credenciais Firebase');
  print('2. Adicione suas chaves API do Google Gemini e Vertex AI');
  print('3. Execute: flutter pub get');
  print('4. Execute: dart run build_runner build');
  print('5. Execute: flutter run');
}

Future<void> _createDirectories() async {
  final directories = [
    'assets/images',
    'assets/icons',
    'assets/fonts',
    'lib/core/models',
    'lib/core/services',
    'lib/core/utils',
    'lib/features/auth/data',
    'lib/features/auth/domain',
    'lib/features/dashboard/data',
    'lib/features/dashboard/domain',
    'lib/features/ai/data',
    'lib/features/ai/domain',
    'lib/features/profile/data',
    'lib/features/profile/domain',
  ];

  for (final dir in directories) {
    await Directory(dir).create(recursive: true);
    print('📁 Criado diretório: $dir');
  }
}

Future<void> _generateCodeFiles() async {
  // Criar arquivo de exemplo para credenciais
  final credentialsExample = '''
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
''';

  await File('lib/core/config/credentials_example.dart').writeAsString(credentialsExample);
  print('📄 Criado arquivo de exemplo: lib/core/config/credentials_example.dart');
}
