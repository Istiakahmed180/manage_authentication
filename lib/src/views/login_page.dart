import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manage_authentication/src/controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => _authController.errorMessage.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _authController.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            )
                : const SizedBox.shrink()),
            Obx(() => ElevatedButton(
              onPressed: _authController.isLoading.value
                  ? null
                  : _login,
              child: _authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    bool success = await _authController.login(
      _usernameController.text,
      _passwordController.text,
    );
    if (success) {
      Get.offAllNamed('/home');
    }
  }
}