import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final endpointViewModelProvider =
    StateNotifierProvider<EndpointViewModel, EndpointState>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    return EndpointViewModel(apiService);
  },
);

class EndpointState {
  final String? authenToken;
  final String? clientToken;
  final List<dynamic> endpoints;
  final bool isLoading;

  EndpointState({
    this.authenToken,
    this.clientToken,
    this.endpoints = const [],
    this.isLoading = false,
  });

  EndpointState copyWith({
    String? authenToken,
    String? clientToken,
    List<dynamic>? endpoints,
    bool? isLoading,
  }) {
    return EndpointState(
      authenToken: authenToken ?? this.authenToken,
      clientToken: clientToken ?? this.clientToken,
      endpoints: endpoints ?? this.endpoints,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EndpointViewModel extends StateNotifier<EndpointState> {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  EndpointViewModel(this._apiService) : super(EndpointState());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final authenToken = await _storage.read(key: 'authenToken');
      final clientToken = await _storage.read(key: 'clientToken');

      if (authenToken != null) {
        final result = await _apiService.callEndpointService(authenToken);

        final newAuthenToken = result['authenToken'] ?? authenToken;
        final newClientToken = result['clientToken'] ?? clientToken;

        // Store the new tokens
        await _storage.write(key: 'authenToken', value: newAuthenToken);
        await _storage.write(key: 'clientToken', value: newClientToken);

        // Update the state
        state = state.copyWith(
          authenToken: newAuthenToken,
          clientToken: newClientToken,
          endpoints: result['data']['listAllowEndpoint'],
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Error loading data: $e');
    }
  }
}
