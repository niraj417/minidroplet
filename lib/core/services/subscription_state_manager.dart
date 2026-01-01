import '../utils/shared_pref.dart';


enum SubscriptionStatus {
  free,
  trialActive,
  trialExpired,
  subscribed,
}

class SubscriptionStateManager {
  static Future<SubscriptionStatus> resolve() async {
    final bool isSubscribed =
        await SharedPref.getBool('isSubscribed') ?? false;

    final bool trialAvailed =
        await SharedPref.getBool('trialAvailed') ?? false;

    final String? expiryStr =
    await SharedPref.getString('trialExpiry');

    DateTime? expiry;
    if (expiryStr != null && expiryStr.isNotEmpty) {
      expiry = DateTime.tryParse(expiryStr);
    }

    if (isSubscribed) {
      return SubscriptionStatus.subscribed;
    }

    if (trialAvailed && expiry != null) {
      if (expiry.isAfter(DateTime.now())) {
        return SubscriptionStatus.trialActive;
      } else {
        return SubscriptionStatus.trialExpired;
      }
    }

    return SubscriptionStatus.free;
  }

  /// Convenience helpers (UI friendly)
  static bool canStartTrial(SubscriptionStatus s) =>
      s == SubscriptionStatus.free;

  static bool canPurchase(SubscriptionStatus s) =>
      s != SubscriptionStatus.subscribed;

  static bool hasPremiumAccess(SubscriptionStatus s) =>
      s == SubscriptionStatus.trialActive ||
          s == SubscriptionStatus.subscribed;
}
