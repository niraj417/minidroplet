abstract class ForgetPasswordState {}

class ForgetPasswordInitial extends ForgetPasswordState {}

class ForgetPasswordLoading extends ForgetPasswordState {}

class ForgetPasswordSuccess extends ForgetPasswordState {
  final String otp;
  final String id;

  ForgetPasswordSuccess({required this.otp, required this.id});
}

class ForgetPasswordError extends ForgetPasswordState {
  final String message;

  ForgetPasswordError(this.message);
}
