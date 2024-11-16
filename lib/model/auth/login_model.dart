class LoginResponse {
  final String token;
  final UserData user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: UserData.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

class UserData {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool status;
  final String phone;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      phone: json['phone'],
      address: json['address'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
