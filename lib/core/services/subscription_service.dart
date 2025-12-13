import 'dart:io';
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
  Function()? _onSuccessCallback;
  Function(String)? _onFailureCallback;

  final IAPurchaseService _iap = IAPurchaseService();

  static const String subscriptionProductId = 'premium_subscriber';

  SubscriptionPaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
  }

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

      // 3️⃣ Decide product
      final productId = selectedPlan.planType == 'monthly'
          ? IAPurchaseService.monthlySubProductId
          : IAPurchaseService.yearlySubProductId;

      // 4️⃣ Start IAP
      await _iap.purchaseProduct(
        productId,
        onSuccess: (purchase) async {
          await _confirmSubscription(purchase.purchaseID ?? '');

          await SharedPref.setBool("isSubscribed", true);

          onSuccess('Subscription activated successfully');
        },
        onError: onFailure,
      );
    } catch (e) {
      onFailure(e.toString().replaceAll('Exception:', ''));
    }
  }


  Future<void> startIosTrialFlow({
    required Function(String message) onSuccess,
    required Function(String error) onFailure,
  }) async {
    try {
      final expiry = await startFreeTrial();

      await SharedPref.setString("trialExpiry", expiry.toString());

      onSuccess(
        'Trial active till '
            '${expiry != null ? expiry.toLocal().toString().split(' ')[0] : ''}',
      );
    } catch (e) {
      onFailure(e.toString().replaceAll('Exception:', ''));
    }
  }

  Future<void> createSubscriptionOrder({required int plan}) async {
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.createSubscriptionOrder,
        {'plan_id': plan},
      );

      if (response.data['status'] == 1) {
        final data = response.data['data'];

        orderId = data['order_id'];
        planId = data['plan_id'];
        amount = data['amount'].toString();
      } else {
        throw Exception('Failed to create subscription order');
      }
    } catch (e) {
      throw Exception('Order creation failed: $e');
    }
  }

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

      // 2️⃣ Razorpay options
      final options = {
        'key': 'rzp_live_Rn8Kp5iMCU2xjr',
        //'key': 'rzp_test_RnBHpHeyiVglH8',
        'amount': (double.parse(amount!)).toStringAsFixed(0),
        'name': name,
        'description': selectedPlan.name,
        'order_id': orderId, // 🔴 IMPORTANT: Razorpay uses order_id
        'prefill': {
          'contact': contact,
          'email': email,
        },
      };

      // 3️⃣ Open Razorpay
      _razorpay.open(options);
    } catch (e) {
      onFailure(e.toString().replaceAll('Exception:', ''));
    }
  }


  Future<void> makePayment({
    required BuildContext context,
    required String amount,
    required String orderId,
    required int planId,
    required String name,
    required String contact,
    required String email,
    required Function() onSuccess,
    required Function(String error) onFailure,
  }) async {
    this.context = context;
    this.orderId = orderId;
    this.planId = planId;

    // iOS – IAP
    if (Platform.isIOS) {
      await _iap.initialize();
      await _iap.purchaseProduct(
        subscriptionProductId,
        onSuccess: (purchase) async {
          await _confirmSubscription(purchase.purchaseID ?? '');
          await SharedPref.setBool("isSubscribed", true);
          onSuccess(); // 🔥 Notify UI
        },
        onError: (err) {
          onFailure(err); // 🔥 Notify UI
        },
      );
      return;
    }

    // Android – Razorpay
    var options = {
      'key': 'rzp_test_RnBHpHeyiVglH8',
      'amount': (double.parse(amount) * 100).toStringAsFixed(0),
      'name': name,
      'description': 'Premium Subscription',
      'orderId': orderId,
      'prefill': {'contact': contact, 'email': email},
    };

    _onSuccessCallback = onSuccess;
    _onFailureCallback = onFailure;

    _razorpay.open(options);
  }


  Future<void> _confirmSubscription(String transactionId) async {
    await dioClient.sendPostRequest(
      ApiEndpoints.subscriptionPayment,
      {
        'transaction_id': transactionId,
        'plan_id': planId,
        'payment_method': Platform.isIOS ? 'iap' : 'razorpay'
      },
    );

    CommonMethods.showSnackBar(context!, 'Subscription Activated!');
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    await _confirmSubscription(response.paymentId!);
    await SharedPref.setBool("isSubscribed", true);
    _onSuccessCallback?.call();   // 🔥 UI notified
  }

  void _handleError(PaymentFailureResponse response) {
    _onFailureCallback?.call("Payment Failed");
  }

  static Future<bool> hasActiveSubscription() async {
    try {
      final res = await dioClient.sendGetRequest(ApiEndpoints.checkSubscription);

      if (res.data['status'] == 1) {
        final expiry = DateTime.parse(res.data['data']['expiry_date']);
        print("Expiry of : $expiry");
        return expiry.isAfter(DateTime.now());
      }
      print("Expiry Status : ${res.data['status']}");
      return false;
    } catch (e) {
      print("Check Subscription Exception : ${e.toString()}");
      return false;
    }
  }

  Future<List<SubscriptionPlan>> fetchSubscriptionPlans() async {
    try {
      final response = await dioClient.sendGetRequest(
        ApiEndpoints.subscriptionPlans, // <-- API endpoint
      );

      if (response.data['status'] != 1) {
        throw Exception(response.data['message']);
      }

      final List list = response.data['data'];

      return list
          .map((e) => SubscriptionPlan.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch subscription plans: $e');
    }
  }


  Future<DateTime?> startFreeTrial() async {
    try {
      final response = await dioClient.sendGetRequest(
        ApiEndpoints.startFreeTrial,
      );

      if (response.data['status'] == 1) {
        final expiry =
        DateTime.tryParse(response.data['data']['expiry_date']);

        // ✅ persist locally for instant UI
        await SharedPref.setBool('isSubscribed', true);
        await SharedPref.setBool('isTrial', true);
        await SharedPref.setBool('trialAvailed', true);
        await SharedPref.setString(
          'trialExpiry',
          expiry?.toIso8601String() ?? '',
        );
        await SharedPref.setBool(SharedPrefKeys.hasPremiumAccess, true);
        return expiry;
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}