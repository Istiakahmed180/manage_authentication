import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService extends GetxService {
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';

  final Rx<String?> accessToken = Rx<String?>(null);
  final Rx<String?> refreshToken = Rx<String?>(null);
  final Rx<DateTime?> tokenExpiry = Rx<DateTime?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTokens();
  }

  Future<void> loadTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken.value = prefs.getString(accessTokenKey);
    refreshToken.value = prefs.getString(refreshTokenKey);
    String? expiryString = prefs.getString(tokenExpiryKey);
    if (expiryString != null) {
      tokenExpiry.value = DateTime.parse(expiryString);
    }
    updateLoginStatus();
  }

  void updateLoginStatus() {
    bool hasValidToken = accessToken.value != null &&
        accessToken.value!.isNotEmpty &&
        !isTokenExpired();
    isLoggedIn.value = hasValidToken;
  }

  Future<bool> saveAccessToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken.value = token;
    bool result = await prefs.setString(accessTokenKey, token);
    updateLoginStatus();
    return result;
  }

  Future<bool> saveRefreshToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    refreshToken.value = token;
    return prefs.setString(refreshTokenKey, token);
  }

  Future<bool> saveTokenExpiry(DateTime expiryTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tokenExpiry.value = expiryTime;
    bool result = await prefs.setString(tokenExpiryKey, expiryTime.toIso8601String());
    updateLoginStatus();
    return result;
  }

  Future<bool> saveAllTokenInfo(String accessToken, String refreshToken, DateTime expiryTime) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    await saveTokenExpiry(expiryTime);
    return true;
  }

  bool isTokenExpired() {
    if (tokenExpiry.value == null) return true;
    return DateTime.now().isAfter(tokenExpiry.value!);
  }

  Future<bool> clearTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken.value = null;
    refreshToken.value = null;
    tokenExpiry.value = null;
    isLoggedIn.value = false;
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(tokenExpiryKey);
    return true;
  }
}