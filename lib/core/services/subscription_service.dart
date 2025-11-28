import 'dart:io';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/network/api_controller.dart';
import 'package:tinydroplets/core/network/api_endpoints.dart';
import 'package:tinydroplets/services/in_app_purchases.dart';

import '../../features/presentation/pages/feed_page/bloc/feed_bloc.dart';

class SubscriptionPaymentService {
  late Razorpay _razorpay;
  String? orderId;
  int? planId;
  String? amount;
  BuildContext? context;

  final IAPurchaseService _iap = IAPurchaseService();

  static const String subscriptionProductId = 'premium_subscriber';

  SubscriptionPaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
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

  Future<void> makePayment({
    required BuildContext context,
    required String amount,
    required String orderId,
    required int planId,
    required String name,
    required String contact,
    required String email,
  }) async {
    this.context = context;
    this.orderId = orderId;
    this.planId = planId;

    if (!Platform.isIOS) {
      await _iap.initialize();
      await _iap.purchaseProduct(
        subscriptionProductId,
        onSuccess: (purchase) async {
          await SharedPref.setBool("isSubscribed", true);
          await _confirmSubscription(purchase.purchaseID ?? '');
        },
        onError: (err) {
          CommonMethods.showSnackBar(context, err);
        },
      );
    } else {
      var options = {
        'key': 'rzp_test_49eKLVBErOrmyk',
        'amount': (double.parse(amount) * 100).toStringAsFixed(0),
        'name': name,
        'description': 'Premium Subscription',
        'orderId': orderId,
        'prefill': {'contact': contact, 'email': email},
      };
      _razorpay.open(options);
    }
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
  }

  void _handleError(PaymentFailureResponse response) {
    CommonMethods.showSnackBar(context!, 'Payment Failed');
  }

  static Future<bool> hasActiveSubscription() async {
    try {
      final res = await dioClient.sendGetRequest(ApiEndpoints.checkSubscription);

      if (res.data['status'] == 1) {
        final expiry = DateTime.parse(res.data['data']['expiry_date']);
        return expiry.isAfter(DateTime.now());
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}