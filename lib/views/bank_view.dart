import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc_flutter_login/views/login_view.dart';
import '../viewmodels/bank_viewmodel.dart';

class BankView extends ConsumerWidget {
  const BankView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankState = ref.watch(bankViewModelProvider);
    final viewModel = ref.read(bankViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Codes'),
      ),
      body: bankState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      try {
                        await viewModel.fetchBankCodes();
                        if (context.mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Bank codes fetched successfully')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed to fetch bank codes: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Fetch Bank Codes'),
                  ),
                  const SizedBox(height: 20),
                  if (bankState.bankCodes != null &&
                      bankState.bankCodes!.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: bankState.bankCodes!.length,
                        itemBuilder: (context, index) {
                          final bank = bankState.bankCodes![index]
                              as Map<String, dynamic>;
                          return ListTile(
                            title:
                                Text(bank['bankNameEN'] ?? 'No English Name'),
                            subtitle:
                                Text(bank['bankNameTH'] ?? 'No Thai Name'),
                          );
                        },
                      ),
                    )
                  else
                    const Text('No bank codes available.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      try {
                        await viewModel.logout();
                        if (context.mounted) {
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginView()),
                            ModalRoute.withName('/'),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Failed to logout: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
}
