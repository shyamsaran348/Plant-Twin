class User {
  final String email;
  final int? id;
  final String? fullName;
  final String? gardenType;

  User({required this.email, this.id, this.fullName, this.gardenType});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      id: json['id'],
      fullName: json['full_name'],
      gardenType: json['garden_type'],
    );
  }
}



class AuthResponse {
  final String accessToken;
  final String tokenType;

  AuthResponse({required this.accessToken, required this.tokenType});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}
