import 'package:equatable/equatable.dart';

class RemoveAdsState extends Equatable {
  final bool isLoading;
  final bool isPurchased;
  final String? orderId;
  final String? amount;
  final String? description;
  final String? transactionId;
  final String? expiryDate;
  final String? errorMessage;

  const RemoveAdsState({
    this.isLoading = false,
    this.isPurchased = false,
    this.orderId,
    this.amount,
    this.description,
    this.transactionId,
    this.expiryDate,
    this.errorMessage,
  });

  RemoveAdsState copyWith({
    bool? isLoading,
    bool? isPurchased,
    String? orderId,
    String? amount,
    String? description,
    String? transactionId,
    String? expiryDate,
    String? errorMessage,
  }) {
    return RemoveAdsState(
      isLoading: isLoading ?? this.isLoading,
      isPurchased: isPurchased ?? this.isPurchased,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionId: transactionId ?? this.transactionId,
      expiryDate: expiryDate ?? this.expiryDate,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isPurchased,
    orderId,
    amount,
    description,
    transactionId,
    expiryDate,
    errorMessage,
  ];
}
