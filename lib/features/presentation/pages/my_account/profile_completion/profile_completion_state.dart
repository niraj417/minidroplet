// profile_completion_state.dart
part of 'profile_completion_cubit.dart';

abstract class ProfileCompletionState {}

class ProfileCompletionInitial extends ProfileCompletionState {}

class ProfileCompletionLoading extends ProfileCompletionState {}

class ProfileCompletionLoaded extends ProfileCompletionState {
  final int percentage;

  ProfileCompletionLoaded(this.percentage);
}

class ProfileCompletionError extends ProfileCompletionState {
  final String message;

  ProfileCompletionError(this.message);
}
