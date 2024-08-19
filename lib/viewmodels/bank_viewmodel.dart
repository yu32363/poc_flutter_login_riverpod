import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final bankViewModelProvider = StateNotifierProvider<BankViewModel, BankState>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    const storage = FlutterSecureStorage();
    return BankViewModel(apiService, storage);
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
  final FlutterSecureStorage _storage;

  BankViewModel(this._apiService, this._storage) : super(BankState());

  Future<void> fetchBankCodes() async {
    state = state.copyWith(isLoading: true);
    try {
      final authenToken = await _storage.read(key: 'authenToken');
      if (authenToken == null) {
        throw Exception('No authenToken found');
      }

      final bankCodes =
          await _apiService.callGetBankCodes(authenToken: authenToken);

      state = state.copyWith(
        bankCodes: bankCodes,
      );
    } catch (e) {
      print('Error fetching bank codes: $e');
    } finally {
      state = state.copyWith(isLoading: false);
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
      await _storage.deleteAll();

      state = BankState(); // Reset state
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
