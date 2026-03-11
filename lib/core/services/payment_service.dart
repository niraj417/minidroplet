import 'package:get_it/get_it.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/services/payment_service/razorpay_config_service.dart';
import 'package:tinydroplets/core/utils/shared_pref.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/purchased_ebook/purchased_ebook_detail_page.dart';

final DioClient dioClient = GetIt.instance<DioClient>();

class PaymentService {
  late Razorpay _razorpay;
  String? _currentOrderId;
  int? _ebookId;
  BuildContext? _context;
  final RazorpayConfigService _configService = RazorpayConfigService();

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> initialize() async {
    await _configService.initialize();
  }

  Future<void> forceRefresh() async {
    await _configService.forceRefresh();
  }

  bool get isLiveMode => RazorpayConfigService.isLiveMode;

  bool get isTestMode => RazorpayConfigService.isTestMode;

  bool get hasKeys => RazorpayConfigService.hasKeys;

  String? get razorpayPublicKey => RazorpayConfigService.publicKey;

  String? get razorpayPrivateKey => RazorpayConfigService.privateKey;

  void openCheckout({
    required BuildContext context,
    required String amount,
    required String orderId,
    required int ebookId,
    required String name,
    required String contact,
    required String email,
  }) {
    if (!RazorpayConfigService.validateKeys()) {
      CommonMethods.showSnackBar(
        context,
        'Payment service not initialized. Please try again.',
      );
      return;
    }

    const String description = "Tiny Droplets: A Virtual baby care";
    _currentOrderId = orderId;
    _ebookId = ebookId;
    _context = context;

    print("🔐 Using Public Key: ${RazorpayConfigService.publicKey}");
    print("📱 Opening Razorpay checkout...");

    var options = {
      'key': RazorpayConfigService.publicKey!,
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("✅ Payment successful");
    print("Payment ID: ${response.paymentId}");
    print("Order ID: ${response.orderId}");

    await _sendPaymentStatus(
      transactionId: response.paymentId,
      status: 1,
      data: response.data,
    );

    if (_context != null && _ebookId != null) {
      Navigator.pushAndRemoveUntil(
        _context!,
        MaterialPageRoute(
          builder:
              (context) => PurchasedEbookBuyDetailPage(ebookId: _ebookId ?? 0),
        ),
        (route) => route.isFirst,
      );
    }

    CommonMethods.showSnackBar(_context!, 'Payment successful');
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    print("❌ Payment failed: ${response.message}");
    await _sendPaymentStatus(
      transactionId: response.message,
      status: response.code,
      data: response.error,
    );
    CommonMethods.showSnackBar(_context!, 'Payment failed. Please try again.');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("🏦 External wallet: ${response.walletName}");
    _sendPaymentStatus(
      transactionId: 'External_Wallet_Transaction',
      status: 2,
      data: response.walletName,
    );
    CommonMethods.showSnackBar(
      _context!,
      'Payment not completed. Please try again.',
    );
  }

  Future<void> _sendPaymentStatus({
    dynamic transactionId,
    dynamic status,
    dynamic data,
  }) async {
    final payload = {
      'order_id': _currentOrderId,
      'transaction_id': transactionId ?? 'DEFAULT_TRANSACTION_ID',
      'status': status ?? -1,
      'data': data ?? 'Default data',
    };

    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.paymentStatus,
        payload,
      );

      print("📊 Payment status API response: ${response.data}");
    } catch (e) {
      print("❌ Payment status API error: $e");
    }
  }

  Map<String, dynamic> getConfigStatus() {
    return RazorpayConfigService.getStatus();
  }

  void dispose() {
    _razorpay.clear();
  }
}
