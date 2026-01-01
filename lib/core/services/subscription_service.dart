import 'dart:io';

import 'package:flutter/material.dart';
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
        'key': 'rzp_live_Rn8Kp5iMCU2xjr',
        'amount': (double.parse(amount!) * 100).round(),
        'name': name,
        'description': selectedPlan.name,
        'prefill': {
          'contact': contact,
          'email': email,
        },
      };

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
  void dispose() {
    _razorpay.clear();
  }
}
