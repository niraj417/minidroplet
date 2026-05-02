import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/network/api_endpoints.dart';
import '../utils/shared_pref.dart';

final logger = Logger(
  printer: PrettyPrinter(
    colors: kDebugMode,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.dateAndTime,
  ),
);

class DioClient {
  final Dio _dio;

  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.serverURL,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.addAll([
      _authInterceptor(),
      _loggingInterceptor(),
      _errorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefData = SharedPref.getLoginData();
        String apiToken = prefData?.data?.apiToken ?? '';

        if (apiToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $apiToken';
        }

        return handler.next(options);
      },
    );
  }

  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          logger.d('Request: ${options.method} ${options.path}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          logger.i('Response [${response.statusCode}] ${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        if (kDebugMode) {
          logger.e(error.message);
        }
        return handler.next(error);
      },
    );
  }

  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException error, handler) {
        String? errorMessage = "An unexpected error occurred.";

        if (error.response?.data != null &&
            error.response?.data['message'] != null) {
          errorMessage = error.response?.data['message'];
        } else if (error.message != null) {
          errorMessage = error.message;
        }

        handler.next(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: error.error,
            message: errorMessage,
          ),
        );
      },
    );
  }

  Future<Response> sendGetRequest(String endPoint) async {
    try {
      final response = await _dio.get(endPoint, options: Options());
      if (response.statusCode == 200 && response.data['status'] == 1) {
        if (kDebugMode) {
          logger.w('GET success: $endPoint');
        }
        return response;
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error occurred.');
      }
    } catch (error) {
      if (kDebugMode) {
        logger.e("GET error $endPoint: $error");
      }

      _handleError(error);
      rethrow;
    }
  }

  Future<Response> sendPostRequest(
    String endPoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(endPoint, data: data);
      if (response.statusCode == 200 && response.data['status'] == 1) {
        if (kDebugMode) {
          logger.w('POST success: $endPoint');
        }
        return response;
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error occurred.');
      }
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  void _handleError(Object error) {
    if (error is DioException) {
      final errorMessage = error.response?.data?['message'] ?? error.message;
      if (kDebugMode) {
        logger.e('Dio error $errorMessage');
      }
      // CommonMethods.showSnackBar(context, errorMessage);
    } else {
      if (kDebugMode) {
        logger.e('Error: ${error.toString()}');
      }
    }
  }
}
