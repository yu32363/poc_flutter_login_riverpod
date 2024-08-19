import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final mobileInfoViewModelProvider =
    StateNotifierProvider<MobileInfoViewModel, MobileInfoState>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    return MobileInfoViewModel(apiService);
  },
);

class MobileInfoState {
  final bool isLoading;
  final String? authenToken;
  final String? clientToken;
  final Map<String, String>? mobileInfo;

  MobileInfoState({
    this.isLoading = false,
    this.authenToken,
    this.clientToken,
    this.mobileInfo,
  });

  MobileInfoState copyWith({
    bool? isLoading,
    String? authenToken,
    String? clientToken,
    Map<String, String>? mobileInfo,
  }) {
    return MobileInfoState(
      isLoading: isLoading ?? this.isLoading,
      authenToken: authenToken ?? this.authenToken,
      clientToken: clientToken ?? this.clientToken,
      mobileInfo: mobileInfo ?? this.mobileInfo,
    );
  }
}

class MobileInfoViewModel extends StateNotifier<MobileInfoState> {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  MobileInfoViewModel(this._apiService) : super(MobileInfoState());

  // Step 1: Retrieve and save mobile info to secure storage
  Future<void> retrieveAndSaveMobileInfo() async {
    state = state.copyWith(isLoading: true);
    try {
      final deviceInfo = await _apiService.getDeviceInfo();

      // Save the mobile info to secure storage
      for (var entry in deviceInfo.entries) {
        await _storage.write(key: entry.key, value: entry.value);
      }

      state = state.copyWith(mobileInfo: deviceInfo, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Failed to retrieve and save mobile info: $e');
    }
  }

  // Step 2: Send saved mobile info to the backend via PUT API
  Future<void> sendSavedMobileInfo(String userName) async {
    state = state.copyWith(isLoading: true);
    try {
      final authenToken = await _storage.read(key: 'authenToken');
      if (authenToken == null) {
        throw Exception('No authenToken found');
      }

      final mobileInfo = {
        'deviceId': await _storage.read(key: 'deviceId') ?? '',
        'mobileInfo': await _storage.read(key: 'mobileInfo') ?? '',
        'mobileOsVersion': await _storage.read(key: 'mobileOsVersion') ?? '',
      };

      final result = await _apiService.callPutMobileInfo(
        authenToken: authenToken,
        userName: userName,
        mobileInfo: mobileInfo,
      );

      // Check if the result contains the tokens and update them
      final newAuthenToken = result['authenToken'] ?? authenToken;
      final newClientToken =
          result['clientToken'] ?? await _storage.read(key: 'clientToken');

      // Save tokens to secure storage
      await _storage.write(key: 'authenToken', value: newAuthenToken);
      await _storage.write(key: 'clientToken', value: newClientToken);

      state = state.copyWith(
        authenToken: newAuthenToken,
        clientToken: newClientToken,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Failed to send mobile info: $e');
    }
  }

  // Load the stored mobile info from secure storage
  Future<void> loadStoredMobileInfo() async {
    state = state.copyWith(isLoading: true);
    try {
      final mobileInfo = {
        'deviceId': await _storage.read(key: 'deviceId') ?? 'N/A',
        'mobileInfo': await _storage.read(key: 'mobileInfo') ?? 'N/A',
        'mobileOsVersion': await _storage.read(key: 'mobileOsVersion') ?? 'N/A',
      };

      final authenToken = await _storage.read(key: 'authenToken');
      final clientToken = await _storage.read(key: 'clientToken');

      state = state.copyWith(
        mobileInfo: mobileInfo,
        authenToken: authenToken,
        clientToken: clientToken,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Failed to load mobile info: $e');
    }
  }
}
