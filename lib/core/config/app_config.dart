class AppConfig {
  // Configurações da aplicação
  static const String appName = 'SedaniHub';
  static const String appVersion = '1.0.0';
  static const String companyDomain = '@sani.med.br';
  
  // URLs e endpoints
  static const String supportEmail = 'suporte@sedani.med.br';
  static const String companyWebsite = 'https://sedani.med.br';
  
  // Configurações de UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;
  
  // Configurações de timeout
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration authTimeout = Duration(seconds: 60);
  
  // Configurações de cache
  static const Duration cacheExpiration = Duration(hours: 24);
  
  // Configurações de logging
  static const bool enableLogging = true;
  static const bool enableDebugMode = true;
}
