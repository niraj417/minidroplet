import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/remove_ads/bloc/remove_ads_cubit.dart';
import 'package:tinydroplets/services/in_app_purchases.dart';

class RemoveAdsPaymentService {
  late Razorpay _razorpay;
  String? _currentOrderId;
  BuildContext? _context;
  final IAPurchaseService _iapService = IAPurchaseService();

  static const String removeAdsProductId = 'remove_ads_subscription';

  RemoveAdsPaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> makePayment({
    required BuildContext context,
    required String amount,
    required String orderId,
    required String name,
    required String contact,
    required String email,
    String productId = removeAdsProductId,
  }) async {
    _context = context;
    _currentOrderId = orderId;

    if (Platform.isIOS) {
      await _handleIAPPurchase(productId);
    } else {
      _handleRazorpayPurchase(context, amount, orderId, name, contact, email);
    }
  }

  /// Razorpay Payment Flow for Android
  void _handleRazorpayPurchase(
    BuildContext context,
    String amount,
    String orderId,
    String name,
    String contact,
    String email,
  ) {
    const String description =
        "Remove Ads - Tiny Droplets: A Virtual baby care";

    var options = {
      'key': 'rzp_test_49eKLVBErOrmyk',
      'amount': (double.parse(amount) * 100).toStringAsFixed(0),
      'name': name,
      'description': description,
      'orderId': orderId,
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      CommonMethods.showSnackBar(context, e.toString());
    }
  }

  /// IAP Flow for iOS
  Future<void> _handleIAPPurchase(String productId) async {
    try {
      await _iapService
          .initialize(); // Optional if already initialized globally
      await _iapService.purchaseProduct(
        productId,
        onSuccess: (details) {
          if (_context != null) {
            BlocProvider.of<RemoveAdsCubit>(
              _context!,
            ).submitRemoveAdsPayment(details.purchaseID ?? '');

            CommonMethods.showSnackBar(
              _context!,
              'Purchase successful! Ads removed.',
            );
          }
        },
        onError: (error) {
          if (_context != null) {
            CommonMethods.showSnackBar(_context!, 'IAP Error: $error');
          }
        },
        onPending: (message) {
          if (_context != null) {
            CommonMethods.showSnackBar(_context!, 'IAP Pending: $message');
          }
        },
      );
    } catch (e) {
      if (_context != null) {
        CommonMethods.showSnackBar(_context!, 'IAP Failed: ${e.toString()}');
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_context != null) {
      final cubit = BlocProvider.of<RemoveAdsCubit>(_context!);
      await cubit.submitRemoveAdsPayment(response.paymentId!);

      CommonMethods.showSnackBar(_context!, 'Payment successful! Ads removed.');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_context != null) {
      BlocProvider.of<RemoveAdsCubit>(_context!).resetError();
      CommonMethods.showSnackBar(
        _context!,
        'Payment failed. Please try again.',
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_context != null) {
      CommonMethods.showSnackBar(
        _context!,
        'External wallet used: ${response.walletName}',
      );
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
