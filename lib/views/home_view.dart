import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/home_viewmodel.dart';
import 'endpoint_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    // Retrieve tokens when HomeView is first built
    viewModel.retrieveTokens();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stored Tokens:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Authen Token: ${homeState.authenToken ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Client Token: ${homeState.clientToken ?? 'N/A'}'),
            const SizedBox(height: 20),
            homeState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EndpointView()),
                      );
                    },
                    child: const Text('Call Next Service'),
                  ),
          ],
        ),
      ),
    );
  }
}
