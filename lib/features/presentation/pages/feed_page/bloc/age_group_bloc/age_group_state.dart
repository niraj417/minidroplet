part of 'age_group_cubit.dart';

abstract class AgeGroupState {}

class AgeGroupInitial extends AgeGroupState {}

class AgeGroupLoading extends AgeGroupState {}

class AgeGroupLoaded extends AgeGroupState {
  final List<Map<String, dynamic>> ageGroupList;

  AgeGroupLoaded(this.ageGroupList);
}

class AgeGroupError extends AgeGroupState {
  final String message;

  AgeGroupError(this.message);
}
