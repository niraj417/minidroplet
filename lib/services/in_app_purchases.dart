import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class IAPurchaseService {
  static final IAPurchaseService _instance = IAPurchaseService._internal();
  factory IAPurchaseService() => _instance;
  IAPurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs
  static const String ebookProductId = 'com.tinydroplets.ebook';
  static const String videoProductId = 'com.tinydroplets.video';
  static const String playlistProductId = 'com.tinydroplets.video.playlist';
  static const String subscriptionProductId = 'premium_subscriber';

  // Subscription products
  static const String freeTrialProductId = 'free_trial';
  static const String monthlySubProductId = 'pro_monthly';
  static const String yearlySubProductId = 'pro_yearly';


  static const Set<String> _productIds = {
    ebookProductId,
    videoProductId,
    playlistProductId,
    subscriptionProductId,
    // subscriptions
    freeTrialProductId,
    monthlySubProductId,
    yearlySubProductId,
  };

  final ValueNotifier<List<ProductDetails>> products = ValueNotifier([]);
  final ValueNotifier<List<PurchaseDetails>> purchases = ValueNotifier([]);

  Function(PurchaseDetails)? _onPurchaseSuccess;
  Function(String)? _onPurchaseError;
  Function(String)? _onPurchasePending;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('❌ In-app purchases not available');
      return false;
    }

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => debugPrint('🔁 Purchase stream done'),
      onError: (e) => debugPrint('❌ Purchase stream error: $e'),
    );

    await _loadProducts();
    _isInitialized = true;
    debugPrint('✅ UnifiedPurchaseService initialized');
    return true;
  }

  Future<void> _loadProducts() async {
    try {
      final response = await _iap.queryProductDetails(_productIds);
      debugPrint('PRODUCTS: ${response.productDetails}');
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('⚠️ Missing product IDs: ${response.notFoundIDs}');
      }

      products.value = response.productDetails.toList();
      debugPrint('✅ Products loaded: ${products.value.length}');
    } catch (e) {
      debugPrint('❌ Failed to load products: $e');
    }
  }

  Future<bool> purchaseProduct(
      String productId, {
        Function(PurchaseDetails)? onSuccess,
        Function(String)? onError,
        Function(String)? onPending,
      }) async {
    if (!_isInitialized) {
      onError?.call('In-app purchase not initialized');
      return false;
    }

    _onPurchaseSuccess = onSuccess;
    _onPurchaseError = onError;
    _onPurchasePending = onPending;

    try {
      final product = products.value.firstWhere(
            (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );

      final param = PurchaseParam(productDetails: product);

      debugPrint('🛒 Initiating purchase: ${product.id}');

      if (product.id == monthlySubProductId ||
          product.id == yearlySubProductId) {
        _onPurchasePending?.call('Processing subscription...');
        return await _iap.buyNonConsumable(purchaseParam: param);
      }

      throw Exception('Unsupported product type: $productId');

    } catch (e) {
      debugPrint('❌ Purchase failed: $e');
      onError?.call(e.toString().replaceAll('Exception:', ''));
      return false;
    }
  }

  Future<void> restorePurchases({
    Function(List<PurchaseDetails>)? onRestored,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      onError?.call('Service not initialized');
      return;
    }

    try {
      debugPrint('🔄 Restoring purchases...');
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('❌ Restore failed: $e');
      onError?.call(e.toString());
    }
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      purchases.value = [...purchases.value, purchase];
      debugPrint(
        '📦 Purchase update: ${purchase.status} - ${purchase.productID}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _onPurchasePending?.call('Pending...');
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndDeliver(purchase);
          _onPurchaseSuccess?.call(purchase);
          break;
        case PurchaseStatus.error:
          _onPurchaseError?.call(purchase.error?.message ?? 'Error occurred');
          break;
        case PurchaseStatus.canceled:
          _onPurchaseError?.call('Purchase canceled');
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    // Placeholder: send token + receipt to Laravel backend
    debugPrint('🔐 Verify & deliver for: ${purchase.productID}');
  }

  Future<bool> hasPurchased(String productId) async {
    if (!_isInitialized) return false;

    try {
      if (Platform.isIOS) {
        final transactions = await SKPaymentQueueWrapper().transactions();
        return transactions.any(
          (tx) =>
              tx.payment.productIdentifier == productId &&
              tx.transactionState == SKPaymentTransactionStateWrapper.purchased,
        );
      }
      return false; // Android not supported in same way
    } catch (e) {
      debugPrint('❌ Error checking purchase: $e');
      return false;
    }
  }

  String getProductType(String productId) {
    switch (productId) {
      case ebookProductId:
        return 'ebook';
      case videoProductId:
        return 'video';
      case playlistProductId:
        return 'playlist';
      default:
        return 'unknown';
    }
  }

  ProductDetails? getProduct(String id) =>
      products.value.firstWhere((p) => p.id == id);

  void dispose() {
    _subscription.cancel();
    _isInitialized = false;
  }
}
