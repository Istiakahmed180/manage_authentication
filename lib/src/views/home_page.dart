import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manage_authentication/src/controllers/auth_controller.dart';
import 'package:manage_authentication/src/controllers/user_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _authController.logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome! You are logged in.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            const Text(
              'User Data:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (_userController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_userController.errorMessage.isNotEmpty) {
                return Text(
                  _userController.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                );
              }
              if (_userController.userData.isEmpty) {
                return const Text('No data found');
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: _userController.userData.length,
                  itemBuilder: (context, index) {
                    String key = _userController.userData.keys.elementAt(index);
                    dynamic value = _userController.userData[key];
                    return ListTile(
                      title: Text(key),
                      subtitle: Text(value.toString()),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
            Obx(() => ElevatedButton(
              onPressed: _userController.isLoading.value
                  ? null
                  : _userController.fetchUserData,
              child: const Text('Refresh Data'),
            )),
          ],
        ),
      ),
    );
  }
}