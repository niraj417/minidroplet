import 'package:image_picker/image_picker.dart';

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

  final bool isLoading;          // For profile update
  final bool isProfileLoading;   // For initial profile load ⚡
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
    this.isProfileLoading = true,   // Start as loading
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
    isProfileLoading: true, // 🔥 Important
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
    bool? isProfileLoading, // Add this
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
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}
