import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';

import '../../features/presentation/pages/auth/login_page/model/login_data_model.dart';
import '../../injections/dependency_injection.dart';

class SharedPref {
  // Use static instance to ensure consistency
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences once
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // 🛡️ Ensure SharedPreferences is synchronized with disk on Android
    await _prefs?.reload();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
          "SharedPref not initialized. Call SharedPref.init() in main().");
    }
    return _prefs!;
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  static Future<bool> setBool(String key, bool value) async {
    await init(); // Ensure initialization
    return await prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  static Future<bool> setInt(String key, int value) async {
    await init(); // Ensure initialization
    return await prefs.setInt(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  static Future<bool> remove(String key) async {
    await init(); // Ensure initialization
    return await prefs.remove(key);
  }

  static Future<void> clear() async {
    await init(); // Ensure initialization
    await prefs.clear();
  }

  static Future<void> setTheme(bool isDark) async {
    await setBool('isDarkTheme', isDark);
  }

  static bool getTheme() {
    return getBool('isDarkTheme') ?? false;
  }

  static Future<void> setOnboardingViewed(bool value) async {
    await setBool('onboardingViewed', value);
  }

  static bool getOnboardingViewed() {
    return getBool('onboardingViewed') ?? false;
  }

  // FIXED: Use the same prefs instance
  static Future<void> setKeepLoggedIn(bool isChecked) async {
    await setBool(SharedPrefKeys.keepLoggedIn, isChecked);
  }

  static bool getKeepLoggedIn() {
    return _prefs?.getBool(SharedPrefKeys.keepLoggedIn) ?? true;
  }

  static Future<bool> saveLoginData(dynamic data) async {
    try {
      final jsonString = jsonEncode(data.toJson());
      debugPrint("Saving loginData: $jsonString");
      return await setString('loginData', jsonString);
    } catch (e) {
      debugPrint("Error saving login data: $e");
      return false;
    }
  }

  static LoginDataModel? getLoginData() {
    try {
      final jsonString = getString('loginData');
      if (jsonString != null && jsonString.isNotEmpty) {
        return LoginDataModel.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      debugPrint("Error parsing login data: $e");
      // If data is corrupted, clear it to avoid repeated crashes
      remove('loginData');
    }
    return null;
  }

  static Future<bool> removeLoginData() async {
    final exists = prefs.containsKey('loginData');
    if (exists) {
      return await remove('loginData');
    }
    return false;
  }

  static Future<void> resetAllDataExceptSettings() async {
    await init(); // Ensure initialization
    final isDarkTheme = getTheme();
    final onboardingViewed = getOnboardingViewed();

    await remove(SharedPrefKeys.hasPremiumAccess);
    await remove(SharedPrefKeys.isGuestUser);

    await clear();

    if (onboardingViewed) {
      await setOnboardingViewed(true);
    }
    await setTheme(isDarkTheme);
  }

  // Add this method to ensure initialization at app start
  static Future<void> initializeApp() async {
    await init();
  }

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

  static bool hasRazorpayKeys() {
    final publicKey = getRazorpayPublicKey();
    final privateKey = getRazorpayPrivateKey();
    return publicKey != null &&
        privateKey != null &&
        publicKey.isNotEmpty &&
        privateKey.isNotEmpty;
  }

  static bool isGuestUser() {
    final jsonString = getString('loginData');
    if(jsonString!=null){
      final user = LoginDataModel.fromJson(jsonDecode(jsonString));
      return user.data?.email == "guest@tinydroplets.com" || user.data?.id == 599;
    }
    return false;
  }

  static Future<void> updateLoginDataForTrial() async {
    final loginData = SharedPref.getLoginData();
    if (loginData == null || loginData.data == null) return;

    final updatedSubscription = SubscriptionInfo(
      isActive: 0,
      isTrial: 1,
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      planId: 0,
    );

    final updatedData = loginData.data!.copyWith(
      subscription: updatedSubscription,
      trialAvailed: 1,
    );

    final updatedLoginData = LoginDataModel(
      status: loginData.status,
      message: loginData.message,
      data: updatedData,
    );

    await SharedPref.saveLoginData(updatedLoginData);
  }

  static Future<void> updateLoginDataForSubscription({
    required DateTime expiryDate,
    required int planId,
  }) async {
    final loginData = SharedPref.getLoginData();
    if (loginData == null || loginData.data == null) return;

    final updatedSubscription = SubscriptionInfo(
      isActive: 1,
      isTrial: 1,
      expiryDate: expiryDate,
      planId: planId,
    );

    final updatedData = loginData.data!.copyWith(
      subscription: updatedSubscription,
    );

    final updatedLoginData = LoginDataModel(
      status: loginData.status,
      message: loginData.message,
      data: updatedData,
    );

    await SharedPref.saveLoginData(updatedLoginData);
  }
}