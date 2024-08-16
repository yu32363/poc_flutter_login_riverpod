import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>(
  (ref) {
    return HomeViewModel();
  },
);

class HomeState {
  final String? authenToken;
  final String? clientToken;
  final List<dynamic> endpoints;
  final bool isLoading;

  HomeState({
    this.authenToken,
    this.clientToken,
    this.endpoints = const [],
    this.isLoading = false,
  });

  HomeState copyWith({
    String? authenToken,
    String? clientToken,
    List<dynamic>? endpoints,
    bool? isLoading,
  }) {
    return HomeState(
      authenToken: authenToken ?? this.authenToken,
      clientToken: clientToken ?? this.clientToken,
      endpoints: endpoints ?? this.endpoints,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final _storage = const FlutterSecureStorage();

  HomeViewModel() : super(HomeState());

  Future<void> retrieveTokens() async {
    final authenToken = await _storage.read(key: 'authenToken');
    final clientToken = await _storage.read(key: 'clientToken');
    state = state.copyWith(authenToken: authenToken, clientToken: clientToken);
  }
}
