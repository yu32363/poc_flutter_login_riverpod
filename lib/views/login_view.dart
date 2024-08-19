import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc_flutter_login/mock_user.dart';

import '../viewmodels/login_viewmodel.dart';

class LoginView extends ConsumerWidget {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isLoading = ref.watch(loginViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      try {
                        await ref.read(loginViewModelProvider.notifier).login(
                              userNameController.text = mockUsername,
                              passwordController.text = mockPassword,
                            );
                        // Check if the widget is still mounted before navigating
                        if (context.mounted) {
                          navigator.pushReplacementNamed('/home');
                        }
                      } catch (e) {
                        // Check if the widget is still mounted before showing a SnackBar
                        if (context.mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Login failed: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
