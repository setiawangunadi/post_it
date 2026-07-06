class AppEnvironment {
  static String get baseUrl => _current.baseUrl;
  static String get domain => _current.domain;
  static String get clienId => _current.clienId;
  static String get privateKey => _current.privateKey;

  static late EnvironmentConfig _current;

  static void setEnvironment(EnvironmentConfig config) {
    _current = config;
  }
}

abstract class EnvironmentConfig {
  String get baseUrl;
  String get domain;
  String get clienId;
  String get privateKey;
}

class DevEnvironment extends EnvironmentConfig {
  @override
  String get baseUrl => 'https://api-dev.example.com';
  @override
  String get domain => 'api-dev.example.com';
  @override
  String get clienId => 'client-id-dev';
  @override
  String get privateKey => '';
}

class StagingEnvironment extends EnvironmentConfig {
  @override
  String get baseUrl => 'https://api-staging.example.com';
  @override
  String get domain => 'api-staging.example.com';
  @override
  String get clienId => 'client-id-staging';
  @override
  String get privateKey => '';
}

class ProdEnvironment extends EnvironmentConfig {
  @override
  String get baseUrl => 'https://api.example.com';
  @override
  String get domain => 'api.example.com';
  @override
  String get clienId => 'client-id-prod';
  @override
  String get privateKey => '';
}
