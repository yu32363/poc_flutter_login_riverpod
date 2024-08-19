import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bank_view.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text('Auth Token: ${homeState.authenToken ?? 'N/A'}'),
                          Text(
                              'Client Token: ${homeState.clientToken ?? 'N/A'}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Mobile Info:'),
                  Text(
                      'Device ID: ${homeState.mobileInfo?['deviceId'] ?? 'N/A'}'),
                  Text(
                      'OS Version: ${homeState.mobileInfo?['mobileOsVersion'] ?? 'N/A'}'),
                  Text('Info: ${homeState.mobileInfo?['mobileInfo'] ?? 'N/A'}'),
                  const SizedBox(height: 10),
                  Text('Status: ${homeState.statusPutMobileInfo ?? 'N/A'}'),
                  const SizedBox(height: 20),
                  const Text('Available Endpoints:'),
                  if (homeState.endpoints.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: homeState.endpoints.length,
                        itemBuilder: (context, index) {
                          final endpoint = homeState.endpoints[index];
                          return ListTile(
                            title: Text(endpoint['endpointCode']),
                            subtitle: Text(endpoint['endpointPath']),
                          );
                        },
                      ),
                    )
                  else
                    const Text('No endpoints available.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BankView()),
                      );
                    },
                    child: const Text('Go to Bank View'),
                  ),
                ],
              ),
            ),
    );
  }
}
