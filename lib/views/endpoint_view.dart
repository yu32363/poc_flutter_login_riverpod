import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mobile_info_view.dart';
import '../viewmodels/endpoint_viewmodel.dart';

class EndpointView extends ConsumerWidget {
  const EndpointView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endpointState = ref.watch(endpointViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Endpoint Page'),
      ),
      body: endpointState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Updated Tokens:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Authen Token: ${endpointState.authenToken}'),
                  const SizedBox(height: 10),
                  Text('Client Token: ${endpointState.clientToken}'),
                  const SizedBox(height: 20),
                  const Text(
                    'Available Endpoints:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: endpointState.endpoints.length,
                      itemBuilder: (context, index) {
                        final endpoint = endpointState.endpoints[index];
                        return ListTile(
                          title: Text(endpoint['endpointCode']),
                          subtitle: Text(endpoint['endpointPath']),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MobileInfoView(),
                        ),
                      );
                    },
                    child: const Text('Go to Mobile Info'),
                  ),
                ],
              ),
            ),
    );
  }
}
