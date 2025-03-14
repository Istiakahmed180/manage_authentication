import 'package:get/get.dart';
import 'package:manage_authentication/src/api/api_client.dart';
import 'package:manage_authentication/src/services/token_service.dart';

class AuthController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final TokenService _tokenService = Get.find<TokenService>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      bool success = await _apiClient.login(username, password);
      if (!success) {
        errorMessage.value = 'Login failed! Incorrect username or password.';
      }
      return success;
    } catch (e) {
      errorMessage.value = 'Login error: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> logout() async {
    isLoading.value = true;
    try {
      bool success = await _apiClient.logout();
      if (success) {
        Get.offAllNamed('/login');
      }
      return success;
    } catch (e) {
      errorMessage.value = 'Logout error: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool get isLoggedIn => _tokenService.isLoggedIn.value;

  Worker? _authStateWorker;

  @override
  void onInit() {
    super.onInit();
    _authStateWorker = ever(_tokenService.isLoggedIn, (isLoggedIn) {
    });
  }

  @override
  void onClose() {
    _authStateWorker?.dispose();
    super.onClose();
  }
}