import 'package:pos/model/auth/login_model.dart';
import 'package:pos/utils/app_preferences.dart';
import 'package:pos/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthController {
  // login
  static Future<LoginResponse> login(
    String email,
    String password,
    String role,
  ) async {
    final url = Uri.parse("${AppUrl.baseUrl}/api/users/login");

    final body =
        jsonEncode({"email": email, "password": password, "role": role});

    // Define headers
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.post(url, body: body, headers: headers);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final loginResponse = LoginResponse.fromJson(data);
      // Save both token and user data
      await AppPreferences.setToken(loginResponse.token);
      await AppPreferences.saveUserData(loginResponse.user);
      return loginResponse;
    } else {
      throw Exception(data['message']);
    }
  }
}
