import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static SharedPreferences? _prefs;

  /// Call this once in `main()` before `runApp()`
  static Future<void> initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    // Ensure address storage consistency on app start
    await _synchronizeAddressOnInit();
  }

  /// Private method to synchronize address storage on app initialization
  static Future<void> _synchronizeAddressOnInit() async {
    if (_prefs == null) return;

    // Get address from all possible sources


    // Sync the address to all storage methods if we found one

  }

  // ==================== User Data Management ====================

  /// Save user data from login response
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    if (_prefs == null) return;

    try {
      // Save complete user data as JSON string
      await _prefs!.setString('user_data', json.encode(userData));

      // Save individual fields
      if (userData.containsKey('id')) {
        await _prefs!.setString('user_id', userData['id'].toString());
      }
      if (userData.containsKey('name')) {
        await _prefs!.setString('user_name', userData['name']);
      }
      if (userData.containsKey('email')) {
        await _prefs!.setString('user_email', userData['email']);
      }
      if (userData.containsKey('phone')) {
        await _prefs!.setString('user_phone', userData['phone']);
      }
      if (userData.containsKey('role')) {
        await _prefs!.setString('user_role', userData['role']);
      }

      // Mark user as logged in
      await _prefs!.setBool('is_logged_in', true);

      developer.log('✅ User data saved to SharedPreferences', name: 'Prefs');
      developer.log('📝 Saved user: ${userData['name']} (${userData['phone']})', name: 'Prefs');
    } catch (e) {
      developer.log('❌ Error saving user data: $e', name: 'Prefs');
    }
  }

  /// Get current user ID
  static String? get userId => _prefs?.getString('user_id');
  
  /// Set user ID explicitly
  static Future<void> setUserId(String userId) async {
    if (_prefs == null) return;
    await _prefs!.setString('user_id', userId);
    developer.log('✅ User ID saved: $userId', name: 'Prefs');
  }

  /// Get current user name
  static String? get userName => _prefs?.getString('user_name');

  /// Get current user email
  static String? get userEmail => _prefs?.getString('user_email');

  /// Get current user phone
  static String? get userPhone => _prefs?.getString('user_phone');

  /// Get current user role
  static String? get userRole => _prefs?.getString('user_role');

  /// Check if user is logged in
  static bool get isLoggedIn => _prefs?.getBool('is_logged_in') ?? false;

  /// Get complete user data as Map
  static Map<String, dynamic>? get userData {
    final data = _prefs?.getString('user_data');
    if (data != null && data.isNotEmpty) {
      try {
        return json.decode(data);
      } catch (e) {
        developer.log('❌ Error parsing user data: $e', name: 'Prefs');
        return null;
      }
    }
    return null;
  }

  /// Clear user data (logout)
  static Future<void> clearUserData() async {
    if (_prefs == null) return;

    await _prefs!.remove('user_data');
    await _prefs!.remove('user_id');
    await _prefs!.remove('user_name');
    await _prefs!.remove('user_email');
    await _prefs!.remove('user_phone');
    await _prefs!.remove('user_role');
    await _prefs!.setBool('is_logged_in', false);

    developer.log('✅ User data cleared', name: 'Prefs');
  }
}