import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8989/o2-crd-api';
  static const String _apiKey =
      'NGVjODI5MmYzNDg3NWQ1NDE2OTc0YmQxZjQzNjc2MGYzNjA2ODNhOTY1OTAyNjg3NGRkNjNmNmI2NzZiZDQ1M2FmMDgxNWNjY2U2NWI2YWYxZGZmYTVlYWNjYTk5OWFlNDk2MjRkZDU4ZTBiZDUwNTdhMGIyZmZmNTAxYTY2OGE=';

  static const String _loginRefID = 'o2-crd-api-20240805223759323';
  static const String _loginCorrelationID = 'corr-crd-api-20240805223759323';

  String _generateRefID() {
    return 'o2-crd-api-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<Map<String, String>> login(String userName, String password) async {
    final response = await _postRequest(
      path: '/authen/login',
      body: {
        "refID": _loginRefID,
        "correlationID": _loginCorrelationID,
        "data": {"userName": userName, "password": password},
      },
    );

    return _processLoginResponse(response);
  }

  Future<Map<String, dynamic>> callEndpointService(String authenToken) async {
    final response = await _getRequest(
      path: '/authorize/endpoint-path',
      authenToken: authenToken,
      requestData: {
        "refID": _generateRefID(),
        "correlationID": _loginCorrelationID,
        "authenToken": authenToken,
        "data": {"userName": "313429"},
      },
    );

    return _processResponseData(response, 'Call to endpoint service failed');
  }

  Future<Map<String, String>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    return _getPlatformSpecificDeviceInfo(deviceInfo);
  }

  Future<Map<String, dynamic>> callPutMobileInfo({
    required String authenToken,
    required String userName,
    required Map<String, String> mobileInfo,
  }) async {
    final response = await _putRequest(
      path: '/user-info/mobile-info',
      authenToken: authenToken,
      body: {
        "refID": _generateRefID(),
        "correlationID": _loginCorrelationID,
        "authenToken": authenToken,
        "data": {
          "userName": userName,
          "deviceId": mobileInfo['deviceId'],
          "pushToken": "mockPushToken${_generateRefID()}",
          "mobileOsVersion": mobileInfo['mobileOsVersion'],
          "mobileInfo": mobileInfo['mobileInfo'],
        },
      },
    );

    return _processResponseData(response, 'PUT mobile info failed');
  }

  Future<List<dynamic>> callGetBankCodes({
    required String authenToken,
  }) async {
    final headers = _buildHeaders(authenToken: authenToken);
    final response = await http.get(
      Uri.parse('$_baseUrl/master/bank-code'),
      headers: {
        ...headers,
        'req-data': json.encode({
          "refID": _generateRefID(),
          "correlationID": _loginCorrelationID,
          "authenToken": authenToken,
          "data": {"userName": "50T02002"},
        }),
      },
    );

    final responseBody = json.decode(utf8.decode(response.bodyBytes));

    return _processBankCodesResponse(responseBody);
  }

  Future<void> logout({required String authenToken}) async {
    final response = await _postRequest(
      path: '/authen/logout',
      authenToken: authenToken,
      body: {
        "refID": _generateRefID(),
        "correlationID": _loginCorrelationID,
        "authenToken": authenToken,
        "data": {"userName": "313429"},
      },
    );

    if (response['status'] != '0') {
      throw Exception('Logout failed with status: ${response['status']}');
    }
  }

  // Helper methods

  Map<String, String> _buildHeaders({String? authenToken}) {
    return {
      'API-Key': _apiKey,
      'Content-Type': 'application/json',
      if (authenToken != null) 'X-Client-Session-Token': authenToken,
    };
  }

  Future<Map<String, dynamic>> _postRequest({
    required String path,
    required Map<String, dynamic> body,
    String? authenToken,
  }) async {
    final headers = _buildHeaders(authenToken: authenToken);
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: json.encode(body),
    );
    return _processHttpResponse(response);
  }

  Future<Map<String, dynamic>> _putRequest({
    required String path,
    required Map<String, dynamic> body,
    String? authenToken,
  }) async {
    final headers = _buildHeaders(authenToken: authenToken);
    final response = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: json.encode(body),
    );
    return _processHttpResponse(response);
  }

  Future<Map<String, dynamic>> _getRequest({
    required String path,
    required Map<String, dynamic> requestData,
    String? authenToken,
  }) async {
    final headers = _buildHeaders(authenToken: authenToken);
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: {...headers, 'req-data': json.encode(requestData)},
    );
    return _processHttpResponse(response);
  }

  Map<String, dynamic> _processHttpResponse(http.Response response) {
    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(
          'Request failed with status: ${response.statusCode}, body: $responseBody');
    }
  }

  Map<String, dynamic> _processResponseData(
      Map<String, dynamic> response, String errorMessage) {
    if (response['status'] == '0') {
      return response['data'];
    } else {
      throw Exception('$errorMessage with status: ${response['status']}');
    }
  }

  List<dynamic> _processBankCodesResponse(Map<String, dynamic> response) {
    if (response['status'] == '0' &&
        response.containsKey('data') &&
        response['data'].containsKey('listBankCode')) {
      return response['data']['listBankCode'] as List<dynamic>;
    } else {
      throw Exception(
          'Failed to fetch bank codes with status: ${response['status']}');
    }
  }

  Map<String, String> _processLoginResponse(Map<String, dynamic> response) {
    if (response['status'] == '0') {
      return {
        'authenToken': response['data']['authenToken'],
        'clientToken': response['data']['clientToken'],
      };
    } else {
      throw Exception('Login failed with status: ${response['status']}');
    }
  }

  Future<Map<String, String>> _getPlatformSpecificDeviceInfo(
      DeviceInfoPlugin deviceInfo) async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'deviceId': androidInfo.id,
        'mobileInfo':
            "${androidInfo.brand}|${androidInfo.model}|${androidInfo.product}|${androidInfo.id}|${androidInfo.device}",
        'mobileOsVersion': androidInfo.version.release,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'deviceId': iosInfo.identifierForVendor ?? 'Unknown',
        'mobileInfo':
            "${iosInfo.name}|${iosInfo.systemName}|${iosInfo.model}|${iosInfo.utsname.machine}|${iosInfo.identifierForVendor}",
        'mobileOsVersion': iosInfo.systemVersion,
      };
    } else {
      throw Exception('Unsupported platform');
    }
  }
}
