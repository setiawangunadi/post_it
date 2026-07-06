import 'package:dio/dio.dart';

class ResponseServer {
  final dynamic data;
  final Headers? header;
  final int? statusCode;

  const ResponseServer({
    required this.data,
    this.header,
    this.statusCode,
  });
}
