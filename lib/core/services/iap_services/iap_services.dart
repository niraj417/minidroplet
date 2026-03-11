import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs
  static const String ebookProductId = 'com.tinydroplets.ebook';
  static const String videoProductId = 'com.tinydroplets.video';
  static const String playlistProductId = 'com.tinydroplets.video.playlist';
  static const String subscriptionProductId = 'com.tinydroplets.subscription.yearly';

  static const Set<String> _productIds = {
    ebookProductId,
    videoProductId,
    playlistProductId,
    subscriptionProductId, // ✅ subscription unified product
  };


  // Available products
  List<ProductDetails> _products = [];

  // Callbacks
  Function(PurchaseDetails)? _onPurchaseSuccess;
  Function(String)? _onPurchaseError;
  Function(String)? _onPurchasePending;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<ProductDetails> get products => _products;

  /// Initialize the IAP service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Check if IAP is available
      bool isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        debugPrint('❌ In-app purchases not available');
        return false;
      }

      // Set up purchase listener
      _setupPurchaseListener();

      // Load products
      await _loadProducts();

      _isInitialized = true;
      debugPrint('✅ IAP Service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ IAP initialization failed: $e');
      return false;
    }
  }

  /// Setup purchase stream listener
  void _setupPurchaseListener() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _handlePurchaseUpdates,
      onDone: () => debugPrint('🔄 Purchase stream done'),
      onError: (error) => debugPrint('❌ Purchase stream error: $error'),
    );
  }

  /// Load available products
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('⚠️ Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      debugPrint('✅ Loaded ${_products.length} products');

      for (var product in _products) {
        debugPrint('📦 Product: ${product.id} - ${product.title} - ${product.price}');
      }
    } catch (e) {
      debugPrint('❌ Failed to load products: $e');
    }
  }

  /// Handle purchase updates
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('🔄 Purchase update: ${purchaseDetails.status} for ${purchaseDetails.productID}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePending(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccess(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handleError(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceled(purchaseDetails);
          break;
      }
    }
  }

  /// Handle successful purchase
  void _handleSuccess(PurchaseDetails purchaseDetails) async {
    debugPrint('✅ Purchase successful: ${purchaseDetails.productID}');

    try {
      // Verify purchase on your server here if needed
      // await _verifyPurchaseOnServer(purchaseDetails);

      _onPurchaseSuccess?.call(purchaseDetails);

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (e) {
      debugPrint('❌ Error handling successful purchase: $e');
      _onPurchaseError?.call('Failed to complete purchase: $e');
    }
  }

  /// Handle purchase error
  void _handleError(PurchaseDetails purchaseDetails) {
    debugPrint('❌ Purchase error: ${purchaseDetails.error}');
    String errorMessage = purchaseDetails.error?.message ?? 'Purchase failed';
    _onPurchaseError?.call(errorMessage);

    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  /// Handle pending purchase
  void _handlePending(PurchaseDetails purchaseDetails) {
    debugPrint('⏳ Purchase pending: ${purchaseDetails.productID}');
    _onPurchasePending?.call('Payment is being processed...');
  }

  /// Handle canceled purchase
  void _handleCanceled(PurchaseDetails purchaseDetails) {
    debugPrint('❌ Purchase canceled: ${purchaseDetails.productID}');
    _onPurchaseError?.call('Purchase was canceled');

    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  /// Purchase a product
  Future<bool> purchaseProduct(String productId, {
    Function(PurchaseDetails)? onSuccess,
    Function(String)? onError,
    Function(String)? onPending,
  }) async {
    if (!_isInitialized) {
      debugPrint('❌ IAP not initialized');
      onError?.call('In-app purchase not initialized');
      return false;
    }

    // Set callbacks
    _onPurchaseSuccess = onSuccess;
    _onPurchaseError = onError;
    _onPurchasePending = onPending;

    try {
      // Find the product
      ProductDetails? product = _products.firstWhere(
            (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );

      // Create purchase param
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

      debugPrint('🛒 Initiating purchase for: ${product.id}');

      // Start the purchase
      bool result = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!result) {
        onError?.call('Failed to initiate purchase');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Purchase failed: $e');
      onError?.call(e.toString());
      return false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases({
    Function(List<PurchaseDetails>)? onRestored,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      onError?.call('In-app purchase not initialized');
      return;
    }

    try {
      debugPrint('🔄 Restoring purchases...');
      await _inAppPurchase.restorePurchases();
      debugPrint('✅ Restore purchases completed');
    } catch (e) {
      debugPrint('❌ Restore purchases failed: $e');
      onError?.call(e.toString());
    }
  }

  /// Get product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has purchased a product
  Future<bool> hasPurchased(String productId) async {
    if (!_isInitialized) return false;

    try {
      // For iOS, we can check with StoreKit
      if (Platform.isIOS) {
        final transactions = await SKPaymentQueueWrapper().transactions();
        return transactions.any((transaction) =>
        transaction.payment.productIdentifier == productId &&
            transaction.transactionState == SKPaymentTransactionStateWrapper.purchased
        );
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error checking purchase status: $e');
      return false;
    }
  }

  /// Get product type from product ID
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

  /// Dispose resources
  void dispose() {
    _subscription.cancel();
    _isInitialized = false;
  }
}