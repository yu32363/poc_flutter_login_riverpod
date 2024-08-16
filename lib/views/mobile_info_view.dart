import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc_flutter_login/views/bank_view.dart';
import '../viewmodels/mobile_info_viewmodel.dart';

class MobileInfoView extends ConsumerWidget {
  const MobileInfoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobileInfoState = ref.watch(mobileInfoViewModelProvider);
    final viewModel = ref.read(mobileInfoViewModelProvider.notifier);

    // Load stored mobile info when this view is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadStoredMobileInfo();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Info Page'),
      ),
      body: mobileInfoState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Retrieve and Save Mobile Info',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await viewModel.retrieveAndSaveMobileInfo();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Mobile info retrieved and saved successfully')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to retrieve and save mobile info: $e')),
                            );
                          }
                        },
                        child: const Text('Get Mobile Info'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BankView()),
                          );
                        },
                        child: const Text('Go to Bank Codes'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (mobileInfoState.mobileInfo != null) ...[
                    const Text(
                      'Stored Mobile Info:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                        'Device Info: ${mobileInfoState.mobileInfo!['mobileInfo']}'),
                    const SizedBox(height: 10),
                    Text(
                        'Mobile OS Version: ${mobileInfoState.mobileInfo!['mobileOsVersion']}'),
                    const SizedBox(height: 10),
                    Text(
                        'Device ID: ${mobileInfoState.mobileInfo!['deviceId']}'),
                    const SizedBox(height: 20),
                  ],
                  const Text(
                    'Send Mobile Info to Backend',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await viewModel.sendSavedMobileInfo("313429");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Mobile info sent to backend successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to send mobile info: $e')),
                        );
                      }
                    },
                    child: const Text('Send to Backend'),
                  ),
                  const SizedBox(height: 20),
                  if (mobileInfoState.authenToken != null) ...[
                    const Text(
                      'Updated Tokens:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                                'Authen Token: ${mobileInfoState.authenToken}'),
                            const SizedBox(height: 10),
                            Text(
                                'Client Token: ${mobileInfoState.clientToken}'),
                          ],
                        ),
                      ),
                    )
                  ],
                ],
              ),
            ),
    );
  }
}
