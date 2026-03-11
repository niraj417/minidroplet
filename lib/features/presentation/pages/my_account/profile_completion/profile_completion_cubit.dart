
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import '../../../../../core/services/payment_service.dart';

part 'profile_completion_state.dart';


class ProfileCompletionCubit extends Cubit<ProfileCompletionState> {
  ProfileCompletionCubit() : super(ProfileCompletionInitial());

  Future<void> getProfileCompletion() async {
    emit(ProfileCompletionLoading());

    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.userProfile);

      if (response.data['status'] == 1) {
        final percentage = response.data['data']['profile_completion'] ?? 0;
        final name = response.data['data']['name'] ?? 0;
        CommonMethods.devLog(logName: 'Profile cubit completion', message: percentage);

        emit(ProfileCompletionLoaded(percentage));
      } else {
        emit(ProfileCompletionError('Failed to fetch profile completion'));
      }
    } catch (e) {
      emit(ProfileCompletionError(e.toString()));
    }
  }
  void reset(){
    emit(ProfileCompletionInitial());
  }
}
