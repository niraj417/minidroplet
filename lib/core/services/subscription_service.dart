import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/network/api_controller.dart';
import 'package:tinydroplets/core/network/api_endpoints.dart';
import 'package:tinydroplets/services/in_app_purchases.dart';

import '../../features/presentation/pages/feed_page/bloc/feed_bloc.dart';
import '../../features/presentation/pages/subscription/model/subscription_plan_model.dart';
import '../utils/shared_pref_key.dart';

class SubscriptionPaymentService {
  late Razorpay _razorpay;

  String? orderId;
  int? planId;
  String? amount;
  String? planName;
  BuildContext? context;

  VoidCallback? _onSuccessCallback;
  Function(String)? _onFailureCallback;

  final IAPurchaseService _iap = IAPurchaseService();

  static const String subscriptionProductId = 'premium_subscriber';

  SubscriptionPaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
  }

  // =============================================================
  // IOS – PAID SUBSCRIPTION
  // =============================================================
  Future<void> startIosPaidSubscriptionFlow({
    required SubscriptionPlan selectedPlan,
    required Function(String message) onSuccess,
    required Function(String error) onFailure,
  }) async {
    try {
      // 1️⃣ Create backend order
      await createSubscriptionOrder(plan: selectedPlan.id);

      // 2️⃣ Init IAP
      await _iap.initialize();

      // 3️⃣ Select product
      final productId = selectedPlan.planType == 'monthly'
          ? IAPurchaseService.monthlySubProductId
          : IAPurchaseService.yearlySubProductId;

      // 4️⃣ Purchase
      await _iap.purchaseProduct(
        productId,
        onSuccess: (purchase) async {
          // ✅ STEP 1: Check purchase status
          if (purchase.status != PurchaseStatus.purchased &&
              purchase.status != PurchaseStatus.restored) {

            onFailure('Purchase not completed');
            return; // 🚨 STOP HERE
          }

          // ✅ STEP 2: Handle pending explicitly
          // if (purchase.pendingCompletePurchase) {
          //   await _iap.completePurchase(purchase);
          // }

          // ✅ STEP 3: Only NOW continue
          await SharedPref.updateLoginDataForSubscription(
            expiryDate: DateTime.now().add(
              Duration(days: selectedPlan.planType == "monthly" ? 30 : 365),
            ),
            planId: selectedPlan.id,
          );

          await _confirmSubscription(purchase.purchaseID ?? '');

          onSuccess('Subscription activated successfully');
        },
        onError: onFailure,
      );
    } catch (e) {
      onFailure(e.toString().replaceAll('Exception:', ''));
    }
  }

  // =============================================================
  // IOS – FREE TRIAL
  // =============================================================
  Future<void> startIosTrialFlow({
    required Function(String message) onSuccess,
    required Function(String error) onFailure,
  }) async {
    try {
      final expiry = await startFreeTrial();

      await SharedPref.updateLoginDataForTrial();

      onSuccess(
        'Trial active till '
            '${expiry != null ? expiry.toLocal().toString().split(' ')[0] : ''}',
      );
    } catch (e) {
      onFailure(e.toString().replaceAll('Exception:', ''));
    }
  }

  // =============================================================
  // ANDROID – PAID SUBSCRIPTION (RAZORPAY)
  // =============================================================
  Future<void> startAndroidPaidSubscriptionFlow({
    required BuildContext context,
    required SubscriptionPlan selectedPlan,
    required String name,
    required String contact,
    required String email,
    required Function(String message) onSuccess,
    required Function(String error) onFailure,
  }) async {
    try {
      // 1️⃣ Create backend order
      await createSubscriptionOrder(plan: selectedPlan.id);

      this.context = context;
      _onSuccessCallback = () =>
          onSuccess('Subscription activated successfully');
      _onFailureCallback = onFailure;

      final options = {
        //'key': 'rzp_test_RsFXTYqM8J4xnC',
        'key': 'rzp_live_Rn8Kp5iMCU2xjr',
        'amount': (double.parse(amount!) * 100).round(),
        'name': name,
        'description': selectedPlan.name,
        'prefill': {
          'contact': contact,
          'email': email,
        },
      };

      planId = selectedPlan.id;
      planName = selectedPlan.name;


      _razorpay.open(options);
    } catch (e) {
      onFailure(e.toString().replaceAll('Exception:', ''));
    }
  }

  // =============================================================
  // BACKEND – CREATE ORDER
  // =============================================================
  Future<void> createSubscriptionOrder({required int plan}) async {
    final response = await dioClient.sendPostRequest(
      ApiEndpoints.createSubscriptionOrder,
      {'plan_id': plan},
    );

    if (response.data['status'] != 1) {
      throw Exception('Failed to create subscription order');
    }

    final data = response.data['data'];
    orderId = data['order_id'];
    planId = data['plan_id'];
    amount = data['amount'].toString();
  }

  // =============================================================
  // BACKEND – CONFIRM SUBSCRIPTION
  // =============================================================
  Future<void> _confirmSubscription(String transactionId) async {
    final response = await dioClient.sendPostRequest(
      ApiEndpoints.subscriptionPayment,
      {
        'transaction_id': transactionId,
        'plan_id': planId,
        'payment_method': Platform.isIOS ? 'iap' : 'razorpay',
      },
    );

    if (response.data['status'] == 1) {
      // ✅ SINGLE SOURCE OF TRUTH FOR PAID SUBSCRIPTION STATE
      await SharedPref.setBool('isSubscribed', true);
      await SharedPref.setBool('isTrial', false);
      await SharedPref.setBool('trialAvailed', true);
      await SharedPref.setString('trialExpiry', '');
      await SharedPref.setBool(
        SharedPrefKeys.hasPremiumAccess,
        true,
      );
    }

    if (context != null) {
      CommonMethods.showSnackBar(context!, 'Subscription Activated!');
    }
  }

  // =============================================================
  // RAZORPAY CALLBACKS
  // =============================================================
  void _handleSuccess(PaymentSuccessResponse response) async {
    await _confirmSubscription(response.paymentId!);
    await SharedPref.updateLoginDataForSubscription(expiryDate: DateTime.now().add(Duration(days: planName == "monthly" ? 30 : 365)), planId: planId!);
    _onSuccessCallback?.call();
  }

  void _handleError(PaymentFailureResponse response) {
    _onFailureCallback?.call('Payment Failed');
  }

  // =============================================================
  // FREE TRIAL – BACKEND + LOCAL STATE
  // =============================================================
  Future<DateTime?> startFreeTrial() async {
    final response =
    await dioClient.sendGetRequest(ApiEndpoints.startFreeTrial);

    if (response.data['status'] != 1) {
      throw Exception(response.data['message']);
    }

    final expiry =
    DateTime.tryParse(response.data['data']['expiry_date']);

    // ✅ SINGLE SOURCE OF TRUTH FOR TRIAL STATE
    await SharedPref.setBool('isSubscribed', false);
    await SharedPref.setBool('isTrial', true);
    await SharedPref.setBool('trialAvailed', true);
    await SharedPref.setString(
      'trialExpiry',
      expiry?.toIso8601String() ?? '',
    );
    await SharedPref.setBool(
      SharedPrefKeys.hasPremiumAccess,
      true,
    );

    return expiry;
  }

  // =============================================================
  // READ-ONLY HELPERS
  // =============================================================
  static Future<bool> hasActiveSubscription() async {
    try {
      final res =
      await dioClient.sendGetRequest(ApiEndpoints.checkSubscription);

      if (res.data['status'] == 1) {
        final expiry =
        DateTime.parse(res.data['data']['expiry_date']);
        return expiry.isAfter(DateTime.now());
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<List<SubscriptionPlan>> fetchSubscriptionPlans() async {
    final response =
    await dioClient.sendGetRequest(ApiEndpoints.subscriptionPlans);

    if (response.data['status'] != 1) {
      throw Exception(response.data['message']);
    }

    final List list = response.data['data'];
    return list.map((e) => SubscriptionPlan.fromJson(e)).toList();
  }

  // =============================================================
  // REFRESH / RESTORE SUBSCRIPTION STATUS
  // =============================================================
  Future<String> refreshSubscriptionStatus() async {
    try {
      final response = await dioClient.sendGetRequest(
        ApiEndpoints.getUserSubscription,
      );

      if (response.data['status'] == 1) {
        final data = response.data['data'];
        final int isActive = data['is_active'] ?? 0;
        final int isTrial = data['is_trial'] ?? 0;
        final String? expiryStr = data['expiry_date'];
        final int planId = data['plan_id'] ?? 0;

        // 🛡️ Sync Single Source of Truth
        await SharedPref.setBool('isSubscribed', isActive == 1 && isTrial == 0);
        await SharedPref.setBool('isTrial', isTrial == 1);
        await SharedPref.setBool('trialAvailed', isTrial == 1 || isActive == 1);
        await SharedPref.setString('trialExpiry', expiryStr ?? '');
        await SharedPref.setBool(
          SharedPrefKeys.hasPremiumAccess,
          isActive == 1,
        );

        // 🛡️ Also sync full LoginDataModel for consistency
        final loginData = SharedPref.getLoginData();
        if (loginData != null && loginData.data != null) {
          final updatedSubscription = SubscriptionInfo(
            isActive: isActive,
            isTrial: isTrial,
            expiryDate: expiryStr != null ? DateTime.tryParse(expiryStr) : null,
            planId: planId,
          );

          final updatedData = loginData.data!.copyWith(
            subscription: updatedSubscription,
            trialAvailed: (isTrial == 1 || isActive == 1) ? 1 : loginData.data!.trialAvailed,
          );

          final updatedLoginData = LoginDataModel(
            status: loginData.status,
            message: loginData.message,
            data: updatedData,
          );

          await SharedPref.saveLoginData(updatedLoginData);
        }

        if (isActive == 1) {
          return isTrial == 1 ? "Trial restored successfully." : "Subscription restored successfully.";
        } else {
          return "No active subscription found.";
        }
      } else {
        return response.data['message'] ?? "Failed to refresh subscription status.";
      }
    } catch (e) {
      debugPrint("Error refreshing subscription: $e");
      return "An error occurred while restoring purchase.";
    }
  }

  // =============================================================
  void dispose() {
    _razorpay.clear();
  }
}
