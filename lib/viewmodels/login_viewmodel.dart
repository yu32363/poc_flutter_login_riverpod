import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, bool>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    return LoginViewModel(apiService);
  },
);

class LoginViewModel extends StateNotifier<bool> {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  LoginViewModel(this._apiService) : super(false);

  Future<void> login(String userName, String password) async {
    state = true; // Set loading state to true
    try {
      final tokens = await _apiService.login(userName, password);

      // Store tokens in secure storage
      await _storage.write(key: 'authenToken', value: tokens['authenToken']);
      await _storage.write(key: 'clientToken', value: tokens['clientToken']);

      state = false; // Set loading state to false after successful login
    } catch (e) {
      state =
          false; // Set loading state to false in case of an error// Log the error
      throw Exception('Login failed');
    }
  }
}
