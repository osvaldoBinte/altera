class LoginResponse {
  final bool success;
  final String token;
  final String message;

  LoginResponse({
    required this.success,
    required this.token,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return LoginResponse(
      success: json['message'] == 'Accesos correctos',
      token: data['token'] ?? '',
      message: json['message'] ?? '',
    );
  }

  factory LoginResponse.error(String errorMessage) {
    return LoginResponse(
      success: false,
      token: '',
      message: errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': {
        'token': token,
      },
    };
  }
}
