import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/model/update_profile_model.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_bloc/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final Dio _dio;
  final ImagePicker _imagePicker = ImagePicker();

  ProfileCubit({DioClient? dioClient})
      : _dio = (dioClient ?? DioClient()).dio,
        super(ProfileState.initial()) {
    loadProfile();
  }

  /// Loads saved user profile from SharedPref
  Future<void> loadProfile() async {
    emit(state.copyWith(isProfileLoading: true));

    await Future.delayed(Duration(milliseconds: 200)); // 🔥 ensures SharedPref is ready

    final data = await SharedPref.getLoginData();

    print("Fetching Data for profile");

    if (data!.data!.name == null) {
      print("data is nulll for profile");
      emit(state.copyWith(isProfileLoading: false));
      return;
    }

    final profile = data.data!;

    emit(state.copyWith(
      name: profile.name,
      email: profile.email,
      image: profile.profile,
      mobile: profile.mobile,
      address: profile.address ?? '',
      aboutUs: profile.aboutUs ?? '',
      token: profile.apiToken ?? '',
      parentsGender: profile.parentsGender ?? state.parentsGender,
      parentName: profile.parentName ?? '',
      babyBorned: profile.babyBorned == 1,
      babyAge: profile.babyAge ?? '',
      isProfileLoading: false,
    ));
  }


  Future<void> pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      emit(state.copyWith(temporaryImage: picked));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String mobile,
    // required String address,
    // required String aboutUs,
    required String parentsGender,
    String? parentName,
    required bool babyBorned,
    String? babyAge,
  }) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));

    try {
      final form = FormData.fromMap({
        'name': name,
        'email': email,
        'mobile': mobile,
        // 'address': address,
        // 'about_us': aboutUs,
        'parents_gender': parentsGender,
        if (parentName != null && parentName.isNotEmpty)
          'parent_name': parentName,
        'baby_borned': babyBorned ? 1 : 0,
        if (babyAge != null && babyAge.isNotEmpty) 'baby_age': babyAge,
        if (state.temporaryImage != null)
          'profile': await MultipartFile.fromFile(
            state.temporaryImage!.path,
            filename: state.temporaryImage!.path.split('/').last,
          ),
      });

      final resp = await _dio.post(
        ApiEndpoints.editProfile,
        data: form,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (resp.data['status'] == 1) {
        final updated = UpdateProfileModel.fromJson(resp.data).data!;
        await SharedPref.saveLoginData(UpdateProfileModel.fromJson(resp.data));

        emit(state.copyWith(
          name: updated.name,
          email: updated.email,
          mobile: updated.mobile,
          address: updated.address ?? '',
          aboutUs: updated.aboutUs ?? '',
          image: updated.profile,
          temporaryImage: null,
          parentsGender: updated.parentsGender ?? state.parentsGender,
          parentName: updated.parentName ?? '',
          babyBorned: updated.babyBorned == 1,
          babyAge: updated.babyAge ?? '',
          isLoading: false,
          successMessage: 'Profile updated successfully',
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: resp.data['message'],
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void clearSuccessMessage() => emit(state.copyWith(successMessage: null));

  void reset() {
    emit(ProfileState.initial());
  }
}
