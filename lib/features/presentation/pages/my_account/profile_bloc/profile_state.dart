import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/model/update_profile_model.dart';

class ProfileState {
  final String name;
  final String email;
  final String image;
  final String mobile;
  final String address;
  final String aboutUs;
  final String token;

  // new fields
  final String parentsGender;
  final String parentName;
  final bool babyBorned;
  final String babyAge;

  final XFile? temporaryImage;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ProfileState({
    required this.name,
    required this.email,
    required this.image,
    required this.mobile,
    required this.address,
    required this.aboutUs,
    required this.token,
    this.parentsGender = 'Mother',
    this.parentName = '',
    this.babyBorned = false,
    this.babyAge = '',
    this.temporaryImage,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  factory ProfileState.initial() => const ProfileState(
    name: '',
    email: '',
    image: '',
    mobile: '',
    address: '',
    aboutUs: '',
    token: '',
  );

  ProfileState copyWith({
    String? name,
    String? email,
    String? image,
    String? mobile,
    String? address,
    String? aboutUs,
    String? token,
    String? parentsGender,
    String? parentName,
    bool? babyBorned,
    String? babyAge,
    XFile? temporaryImage,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      aboutUs: aboutUs ?? this.aboutUs,
      token: token ?? this.token,
      parentsGender: parentsGender ?? this.parentsGender,
      parentName: parentName ?? this.parentName,
      babyBorned: babyBorned ?? this.babyBorned,
      babyAge: babyAge ?? this.babyAge,
      temporaryImage: temporaryImage ?? this.temporaryImage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}


/*import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/model/update_profile_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final Dio _dio;
  final ImagePicker _imagePicker = ImagePicker();

  ProfileCubit({Dio? dio})
      : _dio = dio ?? Dio(),
        super(ProfileState.initial()) {
    loadProfile();
  }

  void loadProfile() {
    final data = SharedPref.getLoginData();
    if (data != null) {
      emit(state.copyWith(
        name: data.data!.name,
        email: data.data!.email,
        image: data.data!.profile,
        mobile: data.data!.mobile,
        address: data.data!.address ?? '',
        aboutUs: data.data!.aboutUs ?? '',
        token: data.data!.apiToken ?? '',
      ));
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      emit(state.copyWith(temporaryImage: pickedFile));
    }
  }
  Future<void> updateProfile({
    required String name,
    required String email,
    required String mobile,
    required String address,
    required String aboutUs,
  }) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));

    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'mobile': mobile,
        'address': address,
        'about_us': aboutUs,
        if (state.temporaryImage != null)
          'profile': await MultipartFile.fromFile(
            state.temporaryImage!.path,
            filename: state.temporaryImage!.path.split('/').last,
          ),
      });

      final response = await _dio.post(
        ApiEndpoints.editProfile,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer ${state.token}',
          },
        ),
      );

      if (response.data['status'] == 1) {
        final loginData = UpdateProfileModel.fromJson(response.data);
        await SharedPref.saveLoginData(loginData);

        emit(state.copyWith(
          name: loginData.data!.name,
          email: loginData.data!.email,
          mobile: loginData.data!.mobile,
          address: loginData.data!.address ?? '',
          aboutUs: loginData.data!.aboutUs ?? '',
          image: loginData.data!.profile,
          temporaryImage: null,
          isLoading: false,
          successMessage: 'Profile updated successfully', // Add success message
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: response.data['message'],
          successMessage: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        successMessage: null,
      ));
    }
  }

// Add a method to clear success message
  void clearSuccessMessage() => emit(state.copyWith(successMessage: null));
}
class ProfileState {
  final String name;
  final String email;
  final String image;
  final String mobile;
  final String address;
  final String aboutUs;
  final String token;
  final XFile? temporaryImage;
  final bool isLoading;
  final String? error;
  final String? successMessage; // Add this field

  const ProfileState({
    required this.name,
    required this.email,
    required this.image,
    required this.mobile,
    required this.address,
    required this.aboutUs,
    required this.token,
    this.temporaryImage,
    this.isLoading = false,
    this.error,
    this.successMessage, // Add this parameter
  });

  factory ProfileState.initial() => const ProfileState(
    name: '',
    email: '',
    image: '',
    mobile: '',
    address: '',
    aboutUs: '',
    token: '',
  );

  ProfileState copyWith({
    String? name,
    String? email,
    String? image,
    String? mobile,
    String? address,
    String? aboutUs,
    String? token,
    XFile? temporaryImage,
    bool? isLoading,
    String? error,
    String? successMessage, // Add this parameter
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      aboutUs: aboutUs ?? this.aboutUs,
      token: token ?? this.token,
      temporaryImage: temporaryImage ?? this.temporaryImage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}*/