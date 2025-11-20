import 'package:bloc/bloc.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/services/payment_service.dart';
import 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit() : super(ForgetPasswordInitial());

  Future<void> forgetPassword(String email) async {
    emit(ForgetPasswordLoading());
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.forgetPassword,
        {'email': email},
      );

      final data = response.data['data'];
      final int otp = data['otp'];
      final int id = data['id'];

      emit(ForgetPasswordSuccess(otp: otp.toString(), id: id.toString()));
    } catch (e) {
      emit(ForgetPasswordError(e.toString()));
    }
  }
}
