import 'package:dio/dio.dart' as dio;
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
              print('Token refresh failed: $e');
              await _tokenService.clearTokens();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      String? refreshToken = _tokenService.refreshToken.value;
      if (refreshToken == null) return false;
      final response = await dio.Dio().post(
        '$baseUrl/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      if (response.statusCode == 200) {
        String newAccessToken = response.data['accessToken'];
        String newRefreshToken = response.data['refreshToken'];
        DateTime expiryTime = DateTime.now().add(const Duration(hours: 1));
        await _tokenService.saveAllTokenInfo(
          newAccessToken,
          newRefreshToken,
          expiryTime,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  }

  Future<dio.Response<dynamic>> _retry(dio.RequestOptions requestOptions) async {
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
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        String accessToken = response.data['accessToken'];
        String refreshToken = response.data['refreshToken'];
        DateTime expiryTime = DateTime.now().add(const Duration(hours: 1));
        await _tokenService.saveAllTokenInfo(
          accessToken,
          refreshToken,
          expiryTime,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _tokenService.clearTokens();
      return true;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  Future<dio.Response> getData(String endpoint) async {
    return await _dio.get(endpoint);
  }

  Future<dio.Response> postData(String endpoint, Map<String, dynamic> data) async {
    return await _dio.post(endpoint, data: data);
  }
}