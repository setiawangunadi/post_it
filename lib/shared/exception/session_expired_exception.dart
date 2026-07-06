class SessionExpiredException implements Exception {
  final String? message;
  const SessionExpiredException([this.message]);
}
