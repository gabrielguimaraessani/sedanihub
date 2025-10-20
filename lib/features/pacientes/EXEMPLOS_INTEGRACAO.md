# Exemplos de Integração - Sistema de Prontuário

## 📚 Exemplos de Código para Integração Real

### 1. Integração com Gemini API

#### Configurar API Key
```dart
// lib/core/config/gemini_config.dart
class GeminiConfig {
  static const String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  static const String apiEndpoint = 
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  static const String visionEndpoint = 
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent';
}

// Executar app com API key:
// flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

#### Processar Texto Real
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> processarTextoReal(String texto) async {
  final prompt = '''
Você é um assistente médico especializado em anestesiologia.
Analise o seguinte texto e extraia informações relevantes.
Retorne APENAS um JSON válido no seguinte formato:
{
  "categoria": "identificacao|historiaMedica|medicamentos|examesComplementares|avaliacaoPreAnestesica",
  "dados": {
    // Dados estruturados extraídos
  }
}

Texto:
$texto
''';

  final response = await http.post(
    Uri.parse(GeminiConfig.apiEndpoint),
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': GeminiConfig.apiKey,
    },
    body: jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      },
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final texto = data['candidates'][0]['content']['parts'][0]['text'];
    
    // Extrair JSON do texto
    final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(texto);
    if (jsonMatch != null) {
      return jsonDecode(jsonMatch.group(0)!);
    }
  }
  
  throw Exception('Erro ao processar texto: ${response.statusCode}');
}
```

#### Processar Imagem Real
```dart
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

Future<Map<String, dynamic>> processarImagemReal() async {
  // 1. Capturar/Selecionar imagem
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);
  
  if (image == null) return {};
  
  // 2. Converter para base64
  final bytes = await File(image.path).readAsBytes();
  final base64Image = base64Encode(bytes);
  
  // 3. Enviar para Gemini Vision
  final response = await http.post(
    Uri.parse(GeminiConfig.visionEndpoint),
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': GeminiConfig.apiKey,
    },
    body: jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text': '''
Analise esta imagem médica e extraia todas as informações relevantes.
Se for um exame, identifique o tipo e principais achados.
Se for um documento, extraia os dados via OCR.
Retorne em formato JSON estruturado.
'''
            },
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              }
            }
          ]
        }
      ],
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final texto = data['candidates'][0]['content']['parts'][0]['text'];
    
    // Processar resposta
    return {
      'categoria': 'examesComplementares',
      'dados': {
        'imagem': {
          'descricao': texto,
          'dataProcessamento': DateTime.now().toIso8601String(),
        },
      },
    };
  }
  
  throw Exception('Erro ao processar imagem: ${response.statusCode}');
}
```

#### Processar Áudio Real
```dart
import 'package:record/record.dart';
import 'package:google_speech/google_speech.dart';

Future<Map<String, dynamic>> processarAudioReal() async {
  // 1. Gravar áudio
  final recorder = Record();
  await recorder.start();
  
  // Aguardar usuário parar gravação
  await Future.delayed(const Duration(seconds: 30));
  
  final path = await recorder.stop();
  if (path == null) return {};
  
  // 2. Transcrever com Google Speech-to-Text
  final serviceAccount = ServiceAccount.fromString(
    await File('assets/credentials.json').readAsString(),
  );
  final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
  
  final audioBytes = await File(path).readAsBytes();
  final config = RecognitionConfig(
    encoding: AudioEncoding.LINEAR16,
    sampleRateHertz: 16000,
    languageCode: 'pt-BR',
    enableAutomaticPunctuation: true,
  );
  
  final audio = RecognitionAudio(content: base64Encode(audioBytes));
  final response = await speechToText.recognize(config, audio);
  
  final transcricao = response.results
      .map((result) => result.alternatives.first.transcript)
      .join(' ');
  
  // 3. Processar transcrição com Gemini
  return await processarTextoReal(transcricao);
}
```

### 2. Persistência com Firestore

#### Modelo de Dados
```dart
// lib/features/pacientes/data/models/prontuario_model.dart
class ProntuarioModel {
  final String id;
  final String pacienteId;
  final Map<String, dynamic> dados;
  final List<VersaoModel> historico;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final String criadoPor;
  final String atualizadoPor;
  
  ProntuarioModel({
    required this.id,
    required this.pacienteId,
    required this.dados,
    required this.historico,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.criadoPor,
    required this.atualizadoPor,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'pacienteId': pacienteId,
    'dados': dados,
    'historico': historico.map((v) => v.toJson()).toList(),
    'criadoEm': criadoEm.toIso8601String(),
    'atualizadoEm': atualizadoEm.toIso8601String(),
    'criadoPor': criadoPor,
    'atualizadoPor': atualizadoPor,
  };
  
  factory ProntuarioModel.fromJson(Map<String, dynamic> json) => ProntuarioModel(
    id: json['id'],
    pacienteId: json['pacienteId'],
    dados: json['dados'],
    historico: (json['historico'] as List)
        .map((v) => VersaoModel.fromJson(v))
        .toList(),
    criadoEm: DateTime.parse(json['criadoEm']),
    atualizadoEm: DateTime.parse(json['atualizadoEm']),
    criadoPor: json['criadoPor'],
    atualizadoPor: json['atualizadoPor'],
  );
}

class VersaoModel {
  final int versao;
  final DateTime data;
  final String usuario;
  final String acao;
  final String snapshot;
  
  VersaoModel({
    required this.versao,
    required this.data,
    required this.usuario,
    required this.acao,
    required this.snapshot,
  });
  
  Map<String, dynamic> toJson() => {
    'versao': versao,
    'data': data.toIso8601String(),
    'usuario': usuario,
    'acao': acao,
    'snapshot': snapshot,
  };
  
  factory VersaoModel.fromJson(Map<String, dynamic> json) => VersaoModel(
    versao: json['versao'],
    data: DateTime.parse(json['data']),
    usuario: json['usuario'],
    acao: json['acao'],
    snapshot: json['snapshot'],
  );
}
```

#### Repositório
```dart
// lib/features/pacientes/data/repositories/prontuario_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProntuarioRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'prontuarios';
  
  Future<void> salvar(ProntuarioModel prontuario) async {
    await _firestore
        .collection(_collection)
        .doc(prontuario.id)
        .set(prontuario.toJson(), SetOptions(merge: true));
  }
  
  Future<ProntuarioModel?> buscar(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    
    if (!doc.exists) return null;
    
    return ProntuarioModel.fromJson(doc.data()!);
  }
  
  Future<List<ProntuarioModel>> listarPorPaciente(String pacienteId) async {
    final query = await _firestore
        .collection(_collection)
        .where('pacienteId', isEqualTo: pacienteId)
        .orderBy('atualizadoEm', descending: true)
        .get();
    
    return query.docs
        .map((doc) => ProntuarioModel.fromJson(doc.data()))
        .toList();
  }
  
  Future<void> adicionarVersao(String prontuarioId, VersaoModel versao) async {
    await _firestore.collection(_collection).doc(prontuarioId).update({
      'historico': FieldValue.arrayUnion([versao.toJson()]),
      'atualizadoEm': DateTime.now().toIso8601String(),
    });
  }
  
  Stream<ProntuarioModel?> observar(String id) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return ProntuarioModel.fromJson(doc.data()!);
        });
  }
}
```

### 3. Gerenciamento de Estado com Riverpod

#### Providers
```dart
// lib/features/pacientes/presentation/providers/prontuario_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider do repositório
final prontuarioRepositoryProvider = Provider<ProntuarioRepository>((ref) {
  return ProntuarioRepository();
});

// Provider do serviço Gemini
final geminiServiceProvider = Provider<GeminiProntuarioService>((ref) {
  return GeminiProntuarioService();
});

// Provider de estado do prontuário atual
final prontuarioAtualProvider = StateNotifierProvider<ProntuarioNotifier, AsyncValue<ProntuarioModel?>>((ref) {
  return ProntuarioNotifier(ref.watch(prontuarioRepositoryProvider));
});

class ProntuarioNotifier extends StateNotifier<AsyncValue<ProntuarioModel?>> {
  final ProntuarioRepository _repository;
  
  ProntuarioNotifier(this._repository) : super(const AsyncValue.loading());
  
  Future<void> carregar(String id) async {
    state = const AsyncValue.loading();
    try {
      final prontuario = await _repository.buscar(id);
      state = AsyncValue.data(prontuario);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> salvar(ProntuarioModel prontuario) async {
    try {
      await _repository.salvar(prontuario);
      state = AsyncValue.data(prontuario);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> liberarVersao(String acao) async {
    final prontuario = state.value;
    if (prontuario == null) return;
    
    final novaVersao = VersaoModel(
      versao: prontuario.historico.length + 1,
      data: DateTime.now(),
      usuario: 'TODO: pegar do auth',
      acao: acao,
      snapshot: jsonEncode(prontuario.dados),
    );
    
    await _repository.adicionarVersao(prontuario.id, novaVersao);
    await carregar(prontuario.id);
  }
}
```

### 4. Uso na UI

#### Consumir Provider
```dart
class EditarProntuarioPage extends ConsumerWidget {
  final String prontuarioId;
  
  const EditarProntuarioPage({super.key, required this.prontuarioId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prontuarioAsync = ref.watch(prontuarioAtualProvider);
    
    return prontuarioAsync.when(
      data: (prontuario) {
        if (prontuario == null) {
          return const Center(child: Text('Prontuário não encontrado'));
        }
        return _buildConteudo(context, ref, prontuario);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erro: $error'),
      ),
    );
  }
  
  Widget _buildConteudo(BuildContext context, WidgetRef ref, ProntuarioModel prontuario) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Prontuário'),
      ),
      body: Column(
        children: [
          InputMultimodalWidget(
            onTextoEnviado: (texto) async {
              final gemini = ref.read(geminiServiceProvider);
              final dados = await gemini.processarTexto(texto);
              
              // Atualizar prontuário
              final prontuarioAtualizado = prontuario.copyWith(
                dados: {...prontuario.dados, ...dados},
                atualizadoEm: DateTime.now(),
              );
              
              await ref.read(prontuarioAtualProvider.notifier)
                  .salvar(prontuarioAtualizado);
            },
          ),
          // ... resto da UI
        ],
      ),
    );
  }
}
```

### 5. Upload de Arquivos para Firebase Storage

```dart
import 'package:firebase_storage/firebase_storage.dart';

class ArquivoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadImagem(File imagem, String prontuarioId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref()
        .child('prontuarios')
        .child(prontuarioId)
        .child('imagens')
        .child(fileName);
    
    await ref.putFile(imagem);
    final url = await ref.getDownloadURL();
    
    return url;
  }
  
  Future<String> uploadAudio(File audio, String prontuarioId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ref = _storage.ref()
        .child('prontuarios')
        .child(prontuarioId)
        .child('audios')
        .child(fileName);
    
    await ref.putFile(audio);
    final url = await ref.getDownloadURL();
    
    return url;
  }
}
```

### 6. Assinatura Digital (Exemplo Conceitual)

```dart
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:crypto/crypto.dart';

class AssinaturaDigitalService {
  /// Gera hash SHA-256 dos dados do prontuário
  String gerarHash(Map<String, dynamic> dados) {
    final jsonString = jsonEncode(dados);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Salva imagem da assinatura
  Future<String> salvarAssinatura(ui.Image assinatura, String prontuarioId) async {
    final byteData = await assinatura.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    // Upload para storage
    final ref = FirebaseStorage.instance
        .ref()
        .child('assinaturas')
        .child('$prontuarioId.png');
    
    await ref.putData(buffer);
    return await ref.getDownloadURL();
  }
  
  /// Cria registro de assinatura
  Map<String, dynamic> criarRegistroAssinatura({
    required String usuarioId,
    required String hash,
    required String urlAssinatura,
  }) {
    return {
      'usuarioId': usuarioId,
      'dataHora': DateTime.now().toIso8601String(),
      'hash': hash,
      'assinaturaUrl': urlAssinatura,
      'dispositivo': 'TODO: obter info do dispositivo',
      'localizacao': 'TODO: obter geolocalização se permitido',
    };
  }
}
```

### 7. Regras de Segurança Firestore

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Prontuários
    match /prontuarios/{prontuarioId} {
      // Permitir leitura apenas para profissionais autenticados
      allow read: if request.auth != null 
                  && exists(/databases/$(database)/documents/profissionais/$(request.auth.uid));
      
      // Permitir criação apenas para profissionais
      allow create: if request.auth != null
                    && exists(/databases/$(database)/documents/profissionais/$(request.auth.uid))
                    && request.resource.data.criadoPor == request.auth.uid;
      
      // Permitir atualização apenas para profissionais
      // Mas NÃO permitir alterar histórico já existente
      allow update: if request.auth != null
                    && exists(/databases/$(database)/documents/profissionais/$(request.auth.uid))
                    && request.resource.data.atualizadoPor == request.auth.uid
                    && isValidUpdate(resource.data.historico, request.resource.data.historico);
      
      // Não permitir delete
      allow delete: if false;
      
      // Função auxiliar para validar atualização de histórico
      function isValidUpdate(oldHistorico, newHistorico) {
        // Histórico só pode crescer, nunca diminuir ou mudar
        return newHistorico.size() >= oldHistorico.size()
               && oldHistorico == newHistorico[0:oldHistorico.size()];
      }
    }
  }
}
```

---

## 🔗 Links Úteis

- [Documentação Gemini API](https://ai.google.dev/docs)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Riverpod](https://riverpod.dev/)
- [Image Picker](https://pub.dev/packages/image_picker)
- [Record Plugin](https://pub.dev/packages/record)

## 📝 Notas Importantes

⚠️ **Segurança:**
- Nunca commitar API keys no código
- Usar variáveis de ambiente
- Implementar rate limiting
- Validar todos os inputs
- Criptografar dados sensíveis

⚠️ **Performance:**
- Implementar cache local
- Usar paginação para listas grandes
- Otimizar tamanho de imagens
- Comprimir áudios antes de upload

⚠️ **Conformidade:**
- Seguir LGPD/HIPAA
- Manter logs de auditoria
- Implementar backup regular
- Ter plano de recuperação de desastres

