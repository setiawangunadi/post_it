class ServerException implements Exception {
  final String message;
  const ServerException([this.message = '']);
}

class CacheException implements Exception {}

class NetworkException implements Exception {
  int? httpStatus;
  String? responseCode;
  String? responseMessage;

  NetworkException({this.httpStatus, this.responseCode, this.responseMessage});
}
