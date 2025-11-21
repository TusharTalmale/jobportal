import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// A service to manage local storage using SharedPreferences.
/// This handles user data and other persistent data.
class LocalStorageService {
  static const String _userDataKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userTypeKey = 'user_type';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';

  // Private constructor
  LocalStorageService._internal();

  // Singleton instance
  static final LocalStorageService _instance = LocalStorageService._internal();

  // Factory constructor
  factory LocalStorageService() => _instance;

  late SharedPreferences _prefs;

  /// Initialize the service (must be called once at app startup)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// ============== AUTHENTICATION METHODS ==============

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Set login status
  Future<void> setLoginStatus(bool isLoggedIn) async {
    await _prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// ============== USER DATA METHODS ==============

  /// Save user data (complete user profile as JSON)
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await _prefs.setString(_userDataKey, jsonString);
  }

  /// Get user data
  Map<String, dynamic>? getUserData() {
    final jsonString = _prefs.getString(_userDataKey);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding user data: $e');
        return null;
      }
    }
    return null;
  }

  /// Save user ID
  Future<void> saveUserId(int userId) async {
    await _prefs.setInt(_userIdKey, userId);
  }

  /// Get user ID
  int? getUserId() {
    return _prefs.getInt(_userIdKey);
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    await _prefs.setString(_userEmailKey, email);
  }

  /// Get user email
  String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  /// Save user name
  Future<void> saveUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  /// Get user name
  String? getUserName() {
    return _prefs.getString(_userNameKey);
  }

  /// Save user type (e.g., 'user', 'company')
  Future<void> saveUserType(String userType) async {
    await _prefs.setString(_userTypeKey, userType);
  }

  /// Get user type
  String? getUserType() {
    return _prefs.getString(_userTypeKey);
  }

  /// ============== REMEMBER ME METHODS ==============

  /// Set remember me status
  Future<void> setRememberMe(bool rememberMe) async {
    await _prefs.setBool(_rememberMeKey, rememberMe);
  }

  /// Get remember me status
  bool getRememberMe() {
    return _prefs.getBool(_rememberMeKey) ?? false;
  }

  /// Save email for remember me
  Future<void> setSavedEmail(String email) async {
    await _prefs.setString(_savedEmailKey, email);
  }

  /// Get saved email for remember me
  String? getSavedEmail() {
    return _prefs.getString(_savedEmailKey);
  }

  /// ============== LOGOUT METHOD ==============

  /// Clear all user data on logout
  Future<void> clearAllData() async {
    await _prefs.remove(_userDataKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userTypeKey);
    await _prefs.setBool(_isLoggedInKey, false);
    // Keep remember me settings if needed
  }

  /// Clear all data including remember me
  Future<void> clearAllDataAndSettings() async {
    await _prefs.clear();
  }

  /// ============== GENERIC METHODS ==============

  /// Save a generic string value
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Get a generic string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save a generic boolean value
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Get a generic boolean value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Save a generic integer value
  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  /// Get a generic integer value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Remove a specific key
  Future<void> removeKey(String key) async {
    await _prefs.remove(key);
  }
}
