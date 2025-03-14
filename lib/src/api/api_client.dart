import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:manage_authentication/src/services/token_service.dart';

class ApiClient extends GetxService {
  final dio.Dio _dio = dio.Dio();
  final String baseUrl = 'https://dummyjson.com';
  late TokenService _tokenService;

  @override
  void onInit() {
    super.onInit();
    _tokenService = Get.find<TokenService>();
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.contentType = 'application/json';
    _setupInterceptors();
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? accessToken = _tokenService.accessToken.value;
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (dio.DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              bool refreshed = await _refreshToken();
              if (refreshed) {
                return handler.resolve(await _retry(error.requestOptions));
              }
            } catch (e) {
              _log('❌ Token refresh failed: $e');
              await _tokenService.clearTokens();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    String url = '${_dio.options.baseUrl}/auth/refresh';
    String? refreshToken = _tokenService.refreshToken.value;

    _log('🔄 Refreshing Token...');
    _log('📤 POST Request URL: $url');
    _log('🔑 Refresh Token: ${refreshToken ?? "No Token"}');

    if (refreshToken == null) {
      _log('❌ No refresh token available.');
      return false;
    }

    try {
      final response = await dio.Dio().post(
        url,
        data: {'refreshToken': refreshToken},
      );

      _log('✅ POST Status Code: ${response.statusCode}');
      _log('✅ POST Response: ${response.data}');

      if (response.statusCode == 200) {
        String newAccessToken = response.data['accessToken'];
        String newRefreshToken = response.data['refreshToken'];
        DateTime expiryTime = DateTime.now().add(const Duration(hours: 1));

        await _tokenService.saveAllTokenInfo(
          newAccessToken,
          newRefreshToken,
          expiryTime,
        );

        _log('🔑 Token Refreshed Successfully');
        return true;
      }

      _log('❌ Failed to refresh token.');
      return false;
    } catch (e) {
      _log('❌ Refresh token error: $e');
      return false;
    }
  }

  Future<dio.Response<dynamic>> _retry(
    dio.RequestOptions requestOptions,
  ) async {
    final options = dio.Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    String? accessToken = _tokenService.accessToken.value;
    options.headers?['Authorization'] = 'Bearer $accessToken';
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<bool> login(String username, String password) async {
    String url = '${_dio.options.baseUrl}/auth/login';

    _log('📤 POST Request URL: $url');
    _log(
      '📦 POST Request Body: {"username": $username, "password": $password}',
    );

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      _log('✅ POST Status Code: ${response.statusCode}');
      _log('✅ POST Response: ${response.data}');

      if (response.statusCode == 200) {
        String accessToken = response.data['accessToken'];
        String refreshToken = response.data['refreshToken'];
        DateTime expiryTime = DateTime.now().add(const Duration(hours: 1));

        await _tokenService.saveAllTokenInfo(
          accessToken,
          refreshToken,
          expiryTime,
        );

        _log('🔑 Token Saved Successfully');
        return true;
      }
      return false;
    } catch (e) {
      _log('❌ Login Error: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _tokenService.clearTokens();
      return true;
    } catch (e) {
      _log('❌ Logout error: $e');
      return false;
    }
  }

  Future<dio.Response> getData(String endpoint) async {
    String url = '${_dio.options.baseUrl}$endpoint';
    String? token = _tokenService.accessToken.value;

    _log('📥 GET Request URL: $url');
    _log('🔑 GET Request Token: ${token ?? "No Token"}');

    try {
      final response = await _dio.get(endpoint);
      _log('✅ GET Status Code: ${response.statusCode}');
      _log('✅ GET Response: ${response.data}');
      return response;
    } catch (e) {
      _log('❌ GET Request Error: $e');
      rethrow;
    }
  }

  Future<dio.Response> postData(
    String endpoint,
    Map<String, dynamic> requestBody,
  ) async {
    String url = '${_dio.options.baseUrl}$endpoint';
    String? token = _tokenService.accessToken.value;

    _log('📤 POST Request URL: $url');
    _log('🔑 POST Request Token: ${token ?? "No Token"}');
    _log('📦 POST Request Body: $requestBody');

    try {
      final response = await _dio.post(endpoint, data: requestBody);
      _log('✅ POST Status Code: ${response.statusCode}');
      _log('✅ POST Response: ${response.data}');
      return response;
    } catch (e) {
      _log('❌ POST Request Error: $e');
      rethrow;
    }
  }
}
