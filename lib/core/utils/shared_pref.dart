import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';

import '../../features/presentation/pages/auth/login_page/model/login_data_model.dart';
import '../../injections/dependency_injection.dart';

class SharedPref {
  static SharedPreferences get _prefs => sl<SharedPreferences>();

  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }

  static Future<void> setTheme(bool isDark) async {
    await _prefs.setBool('isDarkTheme', isDark);
  }

  static bool getTheme() {
    return _prefs.getBool('isDarkTheme') ?? false;
  }

  static Future<void> setOnboardingViewed(bool value) async {
    await _prefs.setBool('onboardingViewed', value);
  }

  static bool getOnboardingViewed() {
    return _prefs.getBool('onboardingViewed') ?? false;
  }

  static Future<void> setKeepLoggedIn(bool isChecked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepLoggedIn', isChecked);
  }

  static Future<bool> getKeepLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('keepLoggedIn') ?? false;
  }

  static Future<bool> saveLoginData(dynamic data) async {
    final jsonString = jsonEncode(data.toJson());
    return await _prefs.setString('loginData', jsonString);
  }

  static LoginDataModel? getLoginData() {
    final jsonString = _prefs.getString('loginData');
    if (jsonString != null) {
      return LoginDataModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  // static Future<bool> removeLoginData() async {
  //   return await _prefs.remove('loginData');
  // }

  static Future<void> resetAllData() async {
    await _prefs.clear();
  }

  static Future<bool> removeLoginData() async {
    // First check if login data exists
    final exists = _prefs.containsKey('loginData');
    if (exists) {
      final result = await _prefs.remove('loginData');
      return result;
    }
    return false; // Return false if login data doesn't exist
  }

  static Future<void> resetAllDataExceptSettings() async {
    // Get values you want to preserve
    final isDarkTheme = getTheme();
    final onboardingViewed = getOnboardingViewed();

    await _prefs.remove(SharedPrefKeys.hasPremiumAccess);
    await _prefs.remove(SharedPrefKeys.isGuestUser);
    // Clear all data
    await _prefs.clear();

    // Restore preserved settings
    if (onboardingViewed) {
      await setOnboardingViewed(true);
    }
    await setTheme(isDarkTheme);
  }

  // Add these methods to your existing SharedPref class

  // Razorpay Keys Management
  static Future<bool> setRazorpayPublicKey(String key) async {
    return await setString('razorpay_public_key', key);
  }

  static String? getRazorpayPublicKey() {
    return getString('razorpay_public_key');
  }

  static Future<bool> setRazorpayPrivateKey(String key) async {
    return await setString('razorpay_private_key', key);
  }

  static String? getRazorpayPrivateKey() {
    return getString('razorpay_private_key');
  }

  static Future<bool> removeRazorpayKeys() async {
    final publicKeyRemoved = await remove('razorpay_public_key');
    final privateKeyRemoved = await remove('razorpay_private_key');
    return publicKeyRemoved && privateKeyRemoved;
  }

  static bool hasRazorpayKeys() {
    final publicKey = getRazorpayPublicKey();
    final privateKey = getRazorpayPrivateKey();
    return publicKey != null &&
        privateKey != null &&
        publicKey.isNotEmpty &&
        privateKey.isNotEmpty;
  }

  static bool isGuestUser() {
    final jsonString = _prefs.getString('loginData');
    if(jsonString!=null){
      final user = LoginDataModel.fromJson(jsonDecode(jsonString));
      return user.data?.email == "guest@tinydroplets.com" || user.data?.id == 599;
    }
    return false;
  }
}
