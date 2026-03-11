// States
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final int dataId;
  PaymentSuccess({required this.dataId});
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}

// New IAP States
class IAPLoading extends PaymentState {}

class IAPSuccess extends PaymentState {
  final int dataId;
  final String productId;
  IAPSuccess({required this.dataId, required this.productId});
}

class IAPError extends PaymentState {
  final String message;
  IAPError(this.message);
}

class IAPPending extends PaymentState {
  final String message;
  IAPPending(this.message);
}

class IAPRestored extends PaymentState {
  final List<String> restoredProducts;
  IAPRestored(this.restoredProducts);
}