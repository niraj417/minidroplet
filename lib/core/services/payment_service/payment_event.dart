// Events
abstract class PaymentEvent {}

class InitiatePayment extends PaymentEvent {
  final String amount;
  final String orderId;
  final int dataId;
  final String name;
  final String itemType;
  final String contact;
  final String email;

  InitiatePayment({
    required this.amount,
    required this.orderId,
    required this.dataId,
    required this.name,
    required this.itemType,
    required this.contact,
    required this.email,
  });
}

// New IAP Events
class InitiateIAPurchase extends PaymentEvent {
  final String productId;
  final int dataId;
  final String itemType;
  final String orderId;

  InitiateIAPurchase({
    required this.productId,
    required this.dataId,
    required this.itemType,
    required this.orderId,
  });
}

class RestoreIAPurchases extends PaymentEvent {}

class IAPurchaseCompleted extends PaymentEvent {
  final String productId;
  final String transactionId;
  final int dataId;
  final String itemType;

  IAPurchaseCompleted({
    required this.productId,
    required this.transactionId,
    required this.dataId,
    required this.itemType,
  });
}

class InitiatePurchase extends PaymentEvent {
  final String amount;
  final String orderId;
  final int dataId;
  final String name;
  final String itemType;
  final String contact;
  final String email;

  InitiatePurchase({
    required this.amount,
    required this.orderId,
    required this.dataId,
    required this.name,
    required this.itemType,
    required this.contact,
    required this.email,
  });
}
