import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../../core/network/api_controller.dart';
import '../../../../../core/network/api_endpoints.dart';
import 'remove_ads_state.dart';

class RemoveAdsCubit extends Cubit<RemoveAdsState> {
  final DioClient dioClient;

  RemoveAdsCubit({required this.dioClient}) : super(const RemoveAdsState());

  Future<void> checkUserRemovedAds() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await dioClient.sendGetRequest(
        ApiEndpoints.checkUserRemovedAds,
      );

      if (response.data['status'] == 1) {
        final data = response.data['data'];
        emit(
          state.copyWith(
            isLoading: false,
            isPurchased: true,
            transactionId: data['transaction_id'],
            expiryDate: data['expiry_date'],
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false, isPurchased: false));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error checking ad removal status: $e',
        ),
      );
      debugPrint('Error checking ad removal status: $e');
    }
  }

  // Get remove ads price
  Future<void> getRemoveAdsPrice() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await dioClient.sendGetRequest(
        ApiEndpoints.removeAdsPrice,
      );

      if (response.data['status'] == 1) {
        final data = response.data['data'];
        emit(
          state.copyWith(
            isLoading: false,
            orderId: data['order_id'],
            amount: data['amount'],
            description: data['description'],
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: response.data['message'],
          ),
        );
        debugPrint(
          'Failed to load remove ads price: ${response.data['message']}',
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error fetching remove ads price: $e',
        ),
      );
      debugPrint('Error fetching remove ads price: $e');
    }
  }

  // Submit payment transaction
  Future<void> submitRemoveAdsPayment(String transactionId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.removeAdsPayment,
        {'transaction_id': transactionId},
      );

      if (response.data['status'] == 1) {
        final data = response.data['data'];
        emit(
          state.copyWith(
            isLoading: false,
            isPurchased: true,
            transactionId: transactionId,
            expiryDate: data['expiry_date'],
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: response.data['message'],
          ),
        );
        debugPrint('Failed to process payment: ${response.data['message']}');
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error processing payment: $e',
        ),
      );
      debugPrint('Error processing payment: $e');
    }
  }

  // Reset error state
  void resetError() {
    emit(state.copyWith(errorMessage: null));
  }
}
