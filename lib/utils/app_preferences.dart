import 'package:pos/model/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyName = 'user_name';
  static const String keyEmail = 'user_email';
  static const String keyRole = 'user_role';
  static const String keyStatus = 'user_status';
  static const String keyPhone = 'user_phone';
  static const String keyAddress = 'user_address';

  static late SharedPreferences _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token getter
  static String? getToken() {
    return _prefs.getString(keyToken);
  }

  // Token setter
  static Future<bool> setToken(String token) {
    return _prefs.setString(keyToken, token);
  }

  // Clear token (for logout)
  static Future<bool> clearToken() {
    return _prefs.remove(keyToken);
  }

  // Save only essential user data
  static Future<void> saveUserData(UserData userData) async {
    await Future.wait([
      _prefs.setString(keyUserId, userData.id),
      _prefs.setString(keyName, userData.name),
      _prefs.setString(keyEmail, userData.email),
      _prefs.setString(keyRole, userData.role),
      _prefs.setBool(keyStatus, userData.status),
      _prefs.setString(keyPhone, userData.phone),
      _prefs.setString(keyAddress, userData.address),
    ]);
  }

  // Only essential getters
  static String? getUserId() => _prefs.getString(keyUserId);
  static String? getName() => _prefs.getString(keyName);
  static String? getEmail() => _prefs.getString(keyEmail);
  static String? getRole() => _prefs.getString(keyRole);
  static bool? getStatus() => _prefs.getBool(keyStatus);
  static String? getPhone() => _prefs.getString(keyPhone);
  static String? getAddress() => _prefs.getString(keyAddress);

  // Clear only essential user data
  static Future<void> clearUserData() async {
    await Future.wait([
      _prefs.remove(keyToken),
      _prefs.remove(keyUserId),
      _prefs.remove(keyName),
      _prefs.remove(keyEmail),
      _prefs.remove(keyRole),
      _prefs.remove(keyStatus),
      _prefs.remove(keyPhone),
      _prefs.remove(keyAddress),
    ]);
  }
}
