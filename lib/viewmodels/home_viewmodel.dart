import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:poc_flutter_login/mock_user.dart';
import '../services/api_service.dart';

final logger = Logger();

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    return HomeViewModel(apiService);
  },
);

class HomeState {
  final String? authenToken;
  final String? clientToken;
  final Map<String, String>? mobileInfo;
  final String? statusPutMobileInfo;
  final List<dynamic> endpoints;
  final bool isLoading;

  HomeState({
    this.authenToken,
    this.clientToken,
    this.mobileInfo,
    this.statusPutMobileInfo,
    this.endpoints = const [],
    this.isLoading = false,
  });

  HomeState copyWith({
    String? authenToken,
    String? clientToken,
    Map<String, String>? mobileInfo,
    String? statusPutMobileInfo,
    List<dynamic>? endpoints,
    bool? isLoading,
  }) {
    return HomeState(
      authenToken: authenToken ?? this.authenToken,
      clientToken: clientToken ?? this.clientToken,
      mobileInfo: mobileInfo ?? this.mobileInfo,
      statusPutMobileInfo: statusPutMobileInfo ?? this.statusPutMobileInfo,
      endpoints: endpoints ?? this.endpoints,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  HomeViewModel(this._apiService)
      : _storage = const FlutterSecureStorage(),
        super(HomeState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);

    try {
      // Step 1: Retrieve and save mobile info
      final deviceInfo = await _apiService.getDeviceInfo();
      await _saveMobileInfo(deviceInfo);

      // Step 2: Send mobile info to backend
      final authenToken = await _storage.read(key: 'authenToken');
      if (authenToken != null) {
        await _updateMobileInfoAndFetchEndpoints(authenToken, deviceInfo);
      } else {
        logger.w('No authenToken found');
      }
    } catch (e) {
      logger.e('Error during initialization $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveMobileInfo(Map<String, String> deviceInfo) async {
    for (var entry in deviceInfo.entries) {
      await _storage.write(key: entry.key, value: entry.value);
    }
    state = state.copyWith(mobileInfo: deviceInfo);
  }

  Future<void> _updateMobileInfoAndFetchEndpoints(
      String authenToken, Map<String, String> deviceInfo) async {
    final userName = mockUsername; // Replace with actual username
    final result = await _apiService.callPutMobileInfo(
      authenToken: authenToken,
      userName: userName,
      mobileInfo: deviceInfo,
    );

    final newAuthenToken = result['authenToken'] ?? authenToken;
    final newClientToken =
        result['clientToken'] ?? await _storage.read(key: 'clientToken');

    await _storage.write(key: 'authenToken', value: newAuthenToken);
    await _storage.write(key: 'clientToken', value: newClientToken);

    state = state.copyWith(
      authenToken: newAuthenToken,
      clientToken: newClientToken,
      statusPutMobileInfo: 'Mobile info updated successfully',
    );

    await _fetchEndpoints(newAuthenToken);
  }

  Future<void> _fetchEndpoints(String authenToken) async {
    try {
      final endpointResult = await _apiService.callEndpointService(authenToken);
      state = state.copyWith(endpoints: endpointResult['listAllowEndpoint']);
    } catch (e) {
      logger.e('Error fetching endpoints $e');
    }
  }

  Future<void> fetchBankCodes() async {
    state = state.copyWith(isLoading: true);
    try {
      final authenToken = await _storage.read(key: 'authenToken');
      if (authenToken != null) {
        final bankCodes = await _apiService.callGetBankCodes(
          authenToken: authenToken,
        );
        state = state.copyWith(endpoints: bankCodes);
      }
    } catch (e) {
      logger.e('Error fetching bank codes $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    final authenToken = state.authenToken;
    if (authenToken != null) {
      try {
        await _apiService.logout(authenToken: authenToken);
        await _storage.deleteAll();
        state = HomeState(); // Reset state
      } catch (e) {
        logger.e('Error during logout $e');
      }
    }
  }
}
