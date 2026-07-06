class BiometricExpiredException implements Exception {
  final String? message;
  const BiometricExpiredException([this.message]);
}
