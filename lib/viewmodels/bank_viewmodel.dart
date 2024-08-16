import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final bankViewModelProvider = StateNotifierProvider<BankViewModel, BankState>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    return BankViewModel(apiService);
  },
);

class BankState {
  final bool isLoading;
  final String? authenToken;
  final String? clientToken;
  final List<dynamic>? bankCodes;

  BankState({
    this.isLoading = false,
    this.authenToken,
    this.clientToken,
    this.bankCodes,
  });

  BankState copyWith({
    bool? isLoading,
    String? authenToken,
    String? clientToken,
    List<dynamic>? bankCodes,
  }) {
    return BankState(
      isLoading: isLoading ?? this.isLoading,
      authenToken: authenToken ?? this.authenToken,
      clientToken: clientToken ?? this.clientToken,
      bankCodes: bankCodes ?? this.bankCodes,
    );
  }
}

class BankViewModel extends StateNotifier<BankState> {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  BankViewModel(this._apiService) : super(BankState());

  Future<void> fetchBankCodes() async {
    state = state.copyWith(isLoading: true);
    try {
      final authenToken = await _storage.read(key: 'authenToken');
      if (authenToken == null) {
        throw Exception('No authenToken found');
      }

      final result =
          await _apiService.callGetBankCodes(authenToken: authenToken);

      await _storage.write(key: 'authenToken', value: result['authenToken']);
      await _storage.write(key: 'clientToken', value: result['clientToken']);

      state = state.copyWith(
        authenToken: result['authenToken'],
        clientToken: result['clientToken'],
        bankCodes: result['bankCodes'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Failed to fetch bank codes: $e');
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      final authenToken = await _storage.read(key: 'authenToken');
      if (authenToken == null) {
        throw Exception('No authenToken found');
      }

      await _apiService.logout(authenToken: authenToken);

      // Clear the stored tokens on logout
      await _storage.deleteAll();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Failed to logout: $e');
    }
  }
}
