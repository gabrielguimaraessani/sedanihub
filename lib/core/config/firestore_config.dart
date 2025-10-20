import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Configuração otimizada do Firestore para SedaniHub
class FirestoreConfig {
  /// Configurar Firestore com cache otimizado e persistência limitada
  static Future<void> configure() async {
    // 1. Configurar settings globais
    FirebaseFirestore.instance.settings = const Settings(
      // Cache de 100 MB (suficiente para catálogos + dados do dia)
      cacheSizeBytes: 100 * 1024 * 1024,
      
      // Persistência habilitada para funcionamento offline limitado
      persistenceEnabled: true,
      
      // SSL sempre habilitado
      sslEnabled: true,
    );

    // 2. Listener de autenticação para limpar cache ao logout
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        // Usuário fez logout - limpar TODO o cache por segurança (LGPD)
        try {
          await FirebaseFirestore.instance.terminate();
          await FirebaseFirestore.instance.clearPersistence();
          print('✅ Cache limpo após logout (segurança LGPD)');
        } catch (e) {
          print('⚠️ Cache já limpo ou em uso: $e');
        }
      }
    });

    print('✅ Firestore configurado com cache otimizado');
  }

  // ========== SOURCE OPTIONS ==========
  
  /// Sempre buscar do servidor (dados sensíveis de pacientes)
  static const GetOptions serverOnly = GetOptions(source: Source.server);
  
  /// Buscar do cache primeiro (catálogos estáticos)
  static const GetOptions cacheOnly = GetOptions(source: Source.cache);
  
  /// Servidor e cache combinados (padrão)
  static const GetOptions serverAndCache = GetOptions(source: Source.serverAndCache);

  // ========== HELPERS DE LIMPEZA ==========
  
  /// Limpa completamente o cache (usar com cuidado)
  static Future<void> limparCacheCompleto() async {
    try {
      await FirebaseFirestore.instance.terminate();
      await FirebaseFirestore.instance.clearPersistence();
      print('✅ Cache completo limpo');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
      rethrow;
    }
  }

  /// Verifica tamanho atual do cache (informativo)
  static void logCacheInfo() {
    print('''
    📊 Configuração de Cache Firestore:
    - Tamanho máximo: 100 MB
    - Persistência: Habilitada
    - SSL: Habilitado
    - Limpeza: Automática no logout
    ''');
  }
}

