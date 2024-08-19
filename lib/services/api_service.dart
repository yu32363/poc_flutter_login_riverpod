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
      headers: _buildHeaders(),
      body: {
        "refID": _loginRefID,
        "correlationID": _loginCorrelationID,
        "data": {
          "userName": userName,
          "password": password,
        },
      },
    );

    if (response['status'] == '0') {
      return {
        'authenToken': response['data']['authenToken'],
        'clientToken': response['data']['clientToken'],
      };
    } else {
      throw Exception('Login failed with status: ${response['status']}');
    }
  }

  Future<Map<String, dynamic>> callEndpointService(String authenToken) async {
    return await _getRequest(
      path: '/authorize/endpoint-path',
      headers: _buildHeaders(authenToken: authenToken),
      requestData: {
        "refID": _generateRefID(),
        "correlationID": _loginCorrelationID,
        "authenToken":
            authenToken, // Include token in request data if necessary
        "data": {"userName": "313429"},
      },
    );
  }

  Future<Map<String, String>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    String mobileInfo = '';
    String mobileOsVersion = '';

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
      mobileInfo =
          "${androidInfo.brand}|${androidInfo.model}|${androidInfo.product}|${androidInfo.id}|${androidInfo.device}";
      mobileOsVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'Unknown';
      mobileInfo =
          "${iosInfo.name}|${iosInfo.systemName}|${iosInfo.model}|${iosInfo.utsname.machine}|${iosInfo.identifierForVendor}";
      mobileOsVersion = iosInfo.systemVersion;
    } else {
      throw Exception('Unsupported platform');
    }

    return {
      'deviceId': deviceId,
      'mobileInfo': mobileInfo,
      'mobileOsVersion': mobileOsVersion,
    };
  }

  Future<Map<String, dynamic>> callPutMobileInfo({
    required String authenToken,
    required String userName,
    required Map<String, String> mobileInfo,
  }) async {
    return await _putRequest(
      path: '/user-info/mobile-info',
      headers: _buildHeaders(authenToken: authenToken),
      body: {
        "refID": _generateRefID(),
        "correlationID": _loginCorrelationID,
        "authenToken":
            authenToken, // Include token in request body if necessary
        "data": {
          "userName": userName,
          "deviceId": mobileInfo['deviceId'],
          "pushToken": "mockPushToken${_generateRefID()}",
          "mobileOsVersion": mobileInfo['mobileOsVersion'],
          "mobileInfo": mobileInfo['mobileInfo'],
        },
      },
    );
  }

  Future<List<dynamic>> callGetBankCodes({
    required String authenToken,
  }) async {
    final response = await _getRequest(
      path: '/master/bank-code',
      headers: _buildHeaders(authenToken: authenToken),
      requestData: {
        "refID": _generateRefID(),
        "correlationID": _loginCorrelationID,
        "authenToken":
            authenToken, // Include token in request data if necessary
        "data": {"userName": "50T02002"},
      },
    );

    if (response.containsKey('data') &&
        response['data'].containsKey('listBankCode')) {
      return response['data']['listBankCode'] as List<dynamic>;
    } else {
      throw Exception('Invalid response format: ${response.toString()}');
    }
  }

  Future<void> logout({required String authenToken}) async {
    await _postRequest(
      path: '/authen/logout',
      headers: _buildHeaders(authenToken: authenToken),
      body: {
        "refID": _generateRefID(),
        "correlationID": _loginCorrelationID,
        "authenToken":
            authenToken, // Include token in request body if necessary
        "data": {"userName": "313429"},
      },
    );
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
    required Map<String, String> headers,
    required Map<String, dynamic> body,
    Function(dynamic responseBody)? responseProcessor,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: json.encode(body),
    );
    return _processResponse(response, responseProcessor);
  }

  Future<Map<String, dynamic>> _putRequest({
    required String path,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
    Function(dynamic responseBody)? responseProcessor,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: json.encode(body),
    );
    return _processResponse(response, responseProcessor);
  }

  Future<Map<String, dynamic>> _getRequest({
    required String path,
    required Map<String, String> headers,
    required Map<String, dynamic> requestData,
    Function(dynamic responseBody)? responseProcessor,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: {
        ...headers,
        'req-data': json.encode(requestData),
      },
    );
    return _processResponse(response, responseProcessor);
  }

  Map<String, dynamic> _processResponse(http.Response response,
      Function(dynamic responseBody)? responseProcessor) {
    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseProcessor != null) {
        return responseProcessor(responseBody);
      } else {
        return responseBody;
      }
    } else {
      throw Exception(
          'Request failed with status: ${response.statusCode}, body: $responseBody');
    }
  }
}
