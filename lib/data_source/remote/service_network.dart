import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_formatter/dio_http_formatter.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:logger/logger.dart';
import 'package:post_it/data/local/user_storage.dart';
import 'package:post_it/shared/constants/app_environment.dart';
import 'package:post_it/shared/exception/biometric_expired_exception.dart';
import 'package:post_it/shared/exception/invalid_device_exception.dart';
import 'package:post_it/shared/exception/network_exception.dart';
import 'package:post_it/shared/exception/session_expired_exception.dart';
import 'package:post_it/shared/exception/token_expired_exception.dart';
import 'package:post_it/shared/utils/base_config.dart';
import 'package:post_it/shared/utils/response_server.dart';

class ServiceNetwork {
  late final Dio _dio;
  // ignore: unused_field
  final _log = Logger();

  static final Map<String, Exception> _rcMap = {
    'MOB:6300': const TokenExpiredException(),
    '6300': const TokenExpiredException(),
    'USR:6304': const InvalidDeviceException(),
    'USR:6308': const SessionExpiredException(),
    'USR:6328': const BiometricExpiredException(),
  };

  ServiceNetwork() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        responseType: ResponseType.json,
        preserveHeaderCase: true,
      ),
    )..interceptors.add(HttpFormatter());
  }

  Future<ResponseServer> request(
    String method,
    String path, {
    String? contentType,
    Map<String, dynamic>? queryParams,
    dynamic content,
  }) async {
    await _preflightChecks();
    return _dispatch(
      method: method,
      path: path,
      content: content,
      queryParams: queryParams,
      contentType: contentType,
      headers: {
        'Authorization': await _getOAuthToken(),
        'sessionId': await _getSessionId() ?? '',
      },
    );
  }

  Future<ResponseServer> requestToken(
    String method,
    String path, {
    String? contentType,
    Map<String, dynamic>? queryParams,
    dynamic content,
    String? clientId,
  }) async {
    await _preflightChecks();
    final jwt = JWT({}, subject: clientId ?? AppEnvironment.clienId);
    final jwtToken = jwt.sign(
      RSAPrivateKey(AppEnvironment.privateKey),
      algorithm: JWTAlgorithm.RS256,
    );
    return _dispatch(
      method: method,
      path: path,
      content: content,
      queryParams: queryParams,
      contentType: contentType,
      headers: {'Authorization': 'Bearer $jwtToken'},
      timeout: const Duration(seconds: 8),
    );
  }

  Future<ResponseServer> requestWithoutContentType(
    String method,
    String path, {
    Map<String, dynamic>? queryParams,
    dynamic content,
  }) async {
    await _preflightChecks();
    return _dispatch(
      method: method,
      path: path,
      content: content is FormData ? content : json.encode(content),
      queryParams: queryParams,
      headers: {
        'Authorization': await _getOAuthToken(),
        'sessionId': await _getSessionId() ?? '',
      },
      timeout: const Duration(seconds: 8),
    );
  }

  Future<ResponseServer> requestBiometric(
    String method,
    String path, {
    String? contentType,
    Map<String, dynamic>? queryParams,
    dynamic content,
  }) async {
    await _preflightChecks();
    return _dispatch(
      method: method,
      path: path,
      content: content,
      queryParams: queryParams,
      contentType: contentType,
      timeout: const Duration(seconds: 8),
    );
  }

  Future<ResponseServer> _dispatch({
    required String method,
    required String path,
    Map<String, dynamic>? queryParams,
    dynamic content,
    String? contentType,
    Map<String, dynamic>? headers,
    Duration? timeout,
  }) async {
    final options = Options(
      headers: headers,
      contentType: contentType,
      responseType: ResponseType.json,
      preserveHeaderCase: true,
      sendTimeout: timeout ?? const Duration(seconds: 60),
      receiveTimeout: timeout ?? const Duration(seconds: 60),
    );

    try {
      final response = switch (method.toUpperCase()) {
        'POST' when content is File => await _dio.post(
            path,
            data: content.readAsBytesSync(),
            queryParameters: queryParams,
            options: options,
          ),
        'POST' => await _dio.post(
            path,
            data: content,
            queryParameters: queryParams,
            options: options,
          ),
        'PUT' => await _dio.put(
            path,
            data: content,
            queryParameters: queryParams,
            options: options,
          ),
        'PATCH' => await _dio.patch(
            path,
            data: content,
            queryParameters: queryParams,
            options: options,
          ),
        'DELETE' => await _dio.delete(
            path,
            data: content,
            queryParameters: queryParams,
            options: options,
          ),
        _ => await _dio.get(
            path,
            queryParameters: queryParams,
            options: options,
          ),
      };

      return ResponseServer(
        data: response.data,
        header: response.headers,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<void> _preflightChecks() async {
    await _checkConnectivity();
    if (BaseConfig.isUseSecure) await _checkSslPinning();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (result.first == ConnectivityResult.none) {
      final lang = await UserStorage.getLanguage();
      throw NetworkException(
        httpStatus: 400,
        responseCode: 'NO_CONNECTION_AVAILABLE',
        responseMessage: lang == 'id'
            ? 'Tidak dapat terhubung ke server. Periksa koneksi Anda atau coba lagi beberapa saat nanti.'
            : 'Unable to connect to server. Check your connection or try again later.',
      );
    }
  }

  Future<void> _checkSslPinning() async {
    try {
      await HttpCertificatePinning.check(
        serverURL: AppEnvironment.domain,
        headerHttp: {},
        sha: SHA.SHA256,
        allowedSHAFingerprints: BaseConfig.serverFingerPrint,
        timeout: 3000,
      );
    } catch (_) {
      final lang = await UserStorage.getLanguage();
      throw NetworkException(
        httpStatus: 500,
        responseCode: 'X0',
        responseMessage: lang == 'en'
            ? 'Connection problem to server. Make sure you are connected to the internet and use the latest version of the application.'
            : 'Kendala koneksi ke server. Pastikan Anda terhubung ke internet dan menggunakan versi aplikasi terbaru.',
      );
    }
  }

  Future<String> _getOAuthToken() async {
    final token = await UserStorage.getAccessToken();
    return 'Bearer $token';
  }

  Future<String?> _getSessionId() => UserStorage.getSessionId();

  Never _handleDioError(DioException e) {
    const defaultMsg =
        'Proses tidak dapat dilakukan, silakan coba beberapa saat lagi';
    const connectionMsg =
        'Terjadi gangguan koneksi pada sistem. Mohon coba beberapa saat lagi.';
    const systemMsg =
        'Terjadi kesalahan pada sistem. Silakan coba beberapa saat lagi.';

    if (e.response?.data is String &&
        (e.response!.data as String).contains('html')) {
      throw NetworkException(
        httpStatus: e.response?.statusCode,
        responseCode: '',
        responseMessage: connectionMsg,
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(
          httpStatus: e.response?.statusCode,
          responseMessage: defaultMsg,
        );
      case DioExceptionType.badResponse:
        final rc = e.response?.headers.value('rc');
        if (rc == null) {
          throw NetworkException(
            httpStatus: e.response?.statusCode,
            responseCode: 'XX',
            responseMessage: e.response?.data?.toString() ?? defaultMsg,
          );
        }
        if (rc.contains(':99')) {
          throw NetworkException(
            httpStatus: e.response?.statusCode,
            responseCode: rc,
            responseMessage: systemMsg,
          );
        }
        final mapped = _rcMap[rc];
        if (mapped != null) throw mapped;
        throw NetworkException(
          httpStatus: e.response?.statusCode,
          responseCode: rc,
          responseMessage: e.response?.data?.toString() ?? defaultMsg,
        );
      default:
        throw NetworkException(
          httpStatus: e.response?.statusCode,
          responseCode: 'XX',
          responseMessage: defaultMsg,
        );
    }
  }
}
