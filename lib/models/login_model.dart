class LoginRequest {
  final String refID;
  final String correlationID;
  final String userName;
  final String password;

  LoginRequest({
    required this.refID,
    required this.correlationID,
    required this.userName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'refID': refID,
      'correlationID': correlationID,
      'data': {
        'userName': userName,
        'password': password,
      },
    };
  }
}

class LoginResponse {
  final String authenToken;
  final String clientToken;

  LoginResponse({
    required this.authenToken,
    required this.clientToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      authenToken: json['data']['authenToken'],
      clientToken: json['data']['clientToken'],
    );
  }
}
