import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';

class ApiService {
  final String _baseUrl = 'http://127.0.0.1:8989/o2-crd-api';
  final String _apiKey =
      'NGVjODI5MmYzNDg3NWQ1NDE2OTc0YmQxZjQzNjc2MGYzNjA2ODNhOTY1OTAyNjg3NGRkNjNmNmI2NzZiZDQ1M2FmMDgxNWNjY2U2NWI2YWYxZGZmYTVlYWNjYTk5OWFlNDk2MjRkZDU4ZTBiZDUwNTdhMGIyZmZmNTAxYTY2OGE=';

  String _generateRefID() {
    final String refID = 'o2-crd-api-${DateTime.now().millisecondsSinceEpoch}';
    return refID;
  }

  final String _loginRefID = 'o2-crd-api-20240805223759323';
  final String _loginCorrelationID = 'corr-crd-api-20240805223759323';

  // Login method
  Future<Map<String, String>> login(String userName, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/authen/login'),
      headers: {
        'API-Key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "refID": _loginRefID,
        "correlationID": _loginCorrelationID,
        "data": {
          "userName": userName,
          "password": password,
        },
      }),
    );

    dynamic responseBody;
    if (response.statusCode == 200) {
      responseBody = json.decode(response.body);
      if (responseBody['status'] == '0') {
        final authenToken = responseBody['data']['authenToken'];
        final clientToken = responseBody['data']['clientToken'];
        return {
          'authenToken': authenToken,
          'clientToken': clientToken,
        };
      }
    } else {
      responseBody = json.decode(response.body);
    }
    throw Exception(
        'Failed to login Status Code: ${response.statusCode} Error Code: ${responseBody['errorCode']}');
  }

  // Endpoint service method
  Future<Map<String, dynamic>> callEndpointService(String authenToken) async {
    final String refID = _generateRefID();

    final response = await http.get(
      Uri.parse('$_baseUrl/authorize/endpoint-path'),
      headers: {
        'API-Key': _apiKey,
        'Content-Type': 'application/json',
        'X-Client-Session-Token': authenToken,
        'req-data': json.encode({
          "refID": refID,
          "correlationID": _loginCorrelationID,
          "data": {"userName": "313429"},
        }),
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final newAuthenToken = response.headers['x-client-session-token'];
      final newClientToken = response.headers['x-client-token'];
      return {
        'data': responseBody['data'],
        'authenToken': newAuthenToken,
        'clientToken': newClientToken,
      };
    } else {
      throw Exception(
          'Failed to call endpoint service: ${response.statusCode}');
    }
  }

  // Get Device Info method
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

  // Put Device Info method
  Future<Map<String, dynamic>> callPutMobileInfo({
    required String authenToken,
    required String userName,
    required Map<String, String> mobileInfo,
  }) async {
    final String refID = _generateRefID();

    final response = await http.put(
      Uri.parse('$_baseUrl/user-info/mobile-info'),
      headers: {
        'API-Key': _apiKey,
        'Content-Type': 'application/json',
        'X-Client-Session-Token': authenToken,
      },
      body: json.encode({
        "refID": refID,
        "correlationID": _loginCorrelationID,
        "data": {
          "userName": userName,
          "deviceId": mobileInfo['deviceId'],
          "pushToken":
              "mockPushToken$refID", // Replace with actual push token if available
          "mobileOsVersion": mobileInfo['mobileOsVersion'],
          "mobileInfo": mobileInfo['mobileInfo'],
        },
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final newAuthenToken = response.headers['x-client-session-token'];
      final newClientToken = response.headers['x-client-token'];

      return {
        'authenToken': newAuthenToken,
        'clientToken': newClientToken,
        'data': responseBody['data'],
      };
    } else {
      throw Exception('Failed to call put mobile info: ${response.statusCode}');
    }
  }

  // Get Bank Code method
  Future<Map<String, dynamic>> callGetBankCodes(
      {required String authenToken}) async {
    final String refID = 'o2-crd-api-${DateTime.now().millisecondsSinceEpoch}';

    final response = await http.get(
      Uri.parse('$_baseUrl/master/bank-code'),
      headers: {
        'API-Key': _apiKey,
        'req-data': json.encode({
          "refID": refID,
          "correlationID": _loginCorrelationID,
          "data": {"userName": "50T02002"},
        }),
        'X-Client-Session-Token': authenToken,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(utf8.decode(response.bodyBytes));
      final newAuthenToken = response.headers['x-client-session-token'];
      final newClientToken = response.headers['x-client-token'];

      return {
        'authenToken': newAuthenToken,
        'clientToken': newClientToken,
        'bankCodes': responseBody['data']['listBankCode'],
      };
    } else {
      throw Exception('Failed to fetch bank codes: ${response.statusCode}');
    }
  }

  // Logout method
  Future<void> logout({required String authenToken}) async {
    final String refID = 'o2-crd-api-${DateTime.now().millisecondsSinceEpoch}';

    final response = await http.post(
      Uri.parse('$_baseUrl/authen/logout'),
      headers: {
        'API-Key': _apiKey,
        'X-Client-Session-Token': authenToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "refID": refID,
        "correlationID": _loginCorrelationID,
        "data": {"userName": "313429"},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout: ${response.statusCode}');
    }
  }
}
