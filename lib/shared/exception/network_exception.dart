class NetworkException implements Exception {
  int? httpStatus;
  String? responseCode;
  String? responseMessage;

  NetworkException({this.httpStatus, this.responseCode, this.responseMessage});
}
