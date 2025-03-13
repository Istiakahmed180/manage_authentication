import 'package:get/get.dart';
import 'package:manage_authentication/src/api/api_client.dart';
import 'package:manage_authentication/src/controllers/auth_controller.dart';
import 'package:manage_authentication/src/controllers/user_controller.dart';
import 'package:manage_authentication/src/services/token_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TokenService>(TokenService());
    Get.put<ApiClient>(ApiClient());
    Get.put<AuthController>(AuthController());
  }
}


class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController());
  }
}

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    // Add dependencies if needed
  }
}