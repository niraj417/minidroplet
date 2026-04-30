import 'package:tinydroplets/core/services/subscription/subscription_state.dart';
import '../../constant/app_export.dart';
import '../../network/api_controller.dart';
import '../../network/api_endpoints.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoveAdsCubit extends Cubit<SubscriptionState> {
  final DioClient dioClient;

  RemoveAdsCubit({required this.dioClient}) : super(const SubscriptionState());

  Future<void> checkUserSubscritpionStatus() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await dioClient.sendGetRequest(
        ApiEndpoints.checkSubscription,
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
          errorMessage: 'Error checking Subscription status: $e',
        ),
      );
      debugPrint('Error checking Subscription status: $e');
    }
  }

  // Get remove ads price
  Future<void> create_order() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.removeAdsPrice,
        {'plan_id': 2},
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