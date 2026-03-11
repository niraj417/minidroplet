import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart' hide IAPError;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tinydroplets/core/services/payment_service/payment_event.dart';
import 'package:tinydroplets/core/services/payment_service/payment_state.dart';
import 'package:tinydroplets/core/services/payment_service/razorpay_config_service.dart';
import 'package:tinydroplets/services/in_app_purchases.dart';

import '../../network/api_controller.dart';
import '../../network/api_endpoints.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final Razorpay _razorpay;
  final DioClient _dioClient;
  final IAPurchaseService _iaPurchaseService;

  String? _itemType;
  String? _currentOrderId;
  int? _dataId;
  String? _amount;

  PaymentBloc({
    required Razorpay razorpay,
    required DioClient dioClient,
    IAPurchaseService? iapService,
  }) : _razorpay = razorpay,
       _dioClient = dioClient,
       _iaPurchaseService = iapService ?? IAPurchaseService(),
       super(PaymentInitial()) {
    if (Platform.isAndroid) {
      _setupRazorpayHandlers();
    }

    if (Platform.isIOS) {
      _initializeIAP();
    }

    // Register event handlers
    on<InitiatePurchase>(_handleInitiatePurchase);
    on<InitiateIAPurchase>(_handleInitiateIAPurchase);
    on<RestoreIAPurchases>(_handleRestoreIAPurchases);
    on<IAPurchaseCompleted>(_handleIAPurchaseCompleted);
  }

  /// Initialize IAP service
  Future<void> _initializeIAP() async {
    if (Platform.isIOS) {
      await _iaPurchaseService.initialize();
    }
  }

  void _setupRazorpayHandlers() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _handleInitiatePurchase(
    InitiatePurchase event,
    Emitter<PaymentState> emit,
  ) async {
    _itemType = event.itemType;
    _dataId = event.dataId;
    _currentOrderId = event.orderId;
    _amount = event.amount;

    if (Platform.isIOS) {
      try {
        emit(IAPLoading());

        _itemType = event.itemType;
        _dataId = event.dataId;
        _currentOrderId = event.orderId;

        final productId = _getProductId(event.itemType);

        await _iaPurchaseService.purchaseProduct(
          productId,
          onSuccess: (details) {
            add(
              IAPurchaseCompleted(
                productId: details.productID,
                transactionId: details.purchaseID ?? '',
                dataId: event.dataId,
                itemType: event.itemType,
              ),
            );
          },
          onError: (error) => emit(IAPError(error)),
          onPending: (msg) => emit(IAPPending(msg)),
        );
      } catch (e) {
        emit(IAPError(e.toString()));
      }
    } else {
      try {
        emit(PaymentLoading());

        // Ensure Razorpay config is initialized and keys are available
        if (!RazorpayConfigService.isInitialized ||
            !RazorpayConfigService.hasKeys) {
          print('🔄 Initializing Razorpay config...');
          await RazorpayConfigService().initialize();
        }

        // Validate keys before proceeding
        if (!RazorpayConfigService.validateKeys()) {
          throw Exception(
            'Razorpay keys not available. Please check your configuration.',
          );
        }

        var options = {
          'key': RazorpayConfigService.publicKey!,
          'amount': (double.parse(event.amount) * 100).toStringAsFixed(0),
          'name': event.name,
          'description': "Tiny Droplets: A Virtual baby care",
          'orderId': event.orderId,
          'prefill': {'contact': event.contact, 'email': event.email},
          'external': {
            'wallets': ['paytm'],
          },
        };

        print(
          '💳 Initiating payment with key: ${RazorpayConfigService.publicKey}',
        );
        print(
          '🏷️ Payment mode: ${RazorpayConfigService.isLiveMode ? 'LIVE' : 'TEST'}',
        );

        _razorpay.open(options);
      } catch (e) {
        print('❌ Payment initiation failed: $e');
        emit(PaymentError(e.toString()));
      }
    }
  }

  /// Handle IAP purchase initiation
  Future<void> _handleInitiateIAPurchase(
    InitiateIAPurchase event,
    Emitter<PaymentState> emit,
  ) async {
    if (!Platform.isIOS) {
      emit(IAPError('In-app purchases are only available on iOS'));
      return;
    }

    try {
      emit(IAPLoading());

      _currentOrderId = event.orderId;
      _dataId = event.dataId;
      _itemType = event.itemType;

      await _iaPurchaseService.purchaseProduct(
        event.productId,
        onSuccess: (purchaseDetails) {
          add(
            IAPurchaseCompleted(
              productId: purchaseDetails.productID,
              transactionId: purchaseDetails.purchaseID ?? '',
              dataId: event.dataId,
              itemType: event.itemType,
            ),
          );
        },
        onError: (error) {
          emit(IAPError(error));
        },
        onPending: (message) {
          emit(IAPPending(message));
        },
      );
    } catch (e) {
      emit(IAPError(e.toString()));
    }
  }

  /// Handle IAP purchase completion
  Future<void> _handleIAPurchaseCompleted(
    IAPurchaseCompleted event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // Send purchase details to your server for verification
      await _sendIAPPaymentStatus(
        transactionId: event.transactionId,
        productId: event.productId,
        status: 1,
      );

      emit(IAPSuccess(dataId: event.dataId, productId: event.productId));
    } catch (e) {
      emit(IAPError('Failed to verify purchase: $e'));
    }
  }

  /// Handle restore IAP purchases
  Future<void> _handleRestoreIAPurchases(
    RestoreIAPurchases event,
    Emitter<PaymentState> emit,
  ) async {
    if (!Platform.isIOS) {
      emit(IAPError('Restore purchases is only available on iOS'));
      return;
    }

    try {
      emit(IAPLoading());

      await _iaPurchaseService.restorePurchases(
        onRestored: (purchases) {
          List<String> restoredProducts =
              purchases
                  .where((p) => p.status == PurchaseStatus.restored)
                  .map((p) => p.productID)
                  .toList();

          emit(IAPRestored(restoredProducts));
        },
        onError: (error) {
          emit(IAPError(error));
        },
      );
    } catch (e) {
      emit(IAPError(e.toString()));
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await _sendPaymentStatus(
        transactionId: response.paymentId,
        status: 1,
        data: response.data,
      );

      emit(PaymentSuccess(dataId: _dataId ?? 0));
      _razorpay.clear();
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    await _sendPaymentStatus(
      transactionId: response.message,
      status: response.code,
      data: response.error,
    );
    emit(PaymentError(response.message ?? 'Payment failed'));
  }

  Future<void> _handleExternalWallet(ExternalWalletResponse response) async {
    await _sendPaymentStatus(
      transactionId: 'External_Wallet_Transaction',
      status: 2,
      data: response.walletName,
    );
    emit(PaymentError('Payment not done, Please try again'));
  }

  /// Send regular payment status to server
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
      'amount': _amount,
    };

    try {
      final response = await _dioClient.sendPostRequest(
        _itemType == 'ebook'
            ? ApiEndpoints.paymentStatus
            : _itemType == 'video'
            ? ApiEndpoints.sendVideoTransaction
            : ApiEndpoints.sendPlaylistTransaction,
        payload,
      );

      if (response.data['status'] != 1) {
        throw Exception('Payment status API error: ${response.data}');
      }
    } catch (e) {
      throw Exception('Payment status failed: $e');
    }
  }

  /// Send IAP payment status to server
  Future<void> _sendIAPPaymentStatus({
    required String transactionId,
    required String productId,
    required int status,
  }) async {
    final payload = {
      'order_id': _currentOrderId,
      'transaction_id': transactionId,
      'product_id': productId,
      'status': status,
      'platform': 'ios',
      'payment_method': 'in_app_purchase',
    };

    try {
      final response = await _dioClient.sendPostRequest(
        _itemType == 'ebook'
            ? ApiEndpoints.paymentStatus
            : _itemType == 'video'
            ? ApiEndpoints.sendVideoTransaction
            : ApiEndpoints.sendPlaylistTransaction,
        payload,
      );

      if (response.data['status'] != 1) {
        throw Exception('IAP payment status API error: ${response.data}');
      }
    } catch (e) {
      throw Exception('IAP payment status failed: $e');
    }
  }

  /// Get product ID based on item type
  String _getProductId(String itemType) {
    switch (itemType) {
      case 'ebook':
        return IAPurchaseService.ebookProductId;
      case 'video':
        return IAPurchaseService.videoProductId;
      case 'playlist':
        return IAPurchaseService.playlistProductId;
      default:
        throw Exception('Unknown item type: $itemType');
    }
  }

  @override
  Future<void> close() {
    if (Platform.isAndroid) {
      _razorpay.clear();
    }
    return super.close();
  }
}
