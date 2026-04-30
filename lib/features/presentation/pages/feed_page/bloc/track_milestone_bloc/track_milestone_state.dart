part of 'track_milestone_cubit.dart';

abstract class TrackMilestoneState extends Equatable {
  const TrackMilestoneState();

  @override
  List<Object> get props => [];
}

class TrackMilestoneInitial extends TrackMilestoneState {}

class TrackMilestoneLoading extends TrackMilestoneState {}

class TrackMilestoneLoaded extends TrackMilestoneState {
  final List<Map<String, dynamic>> milestones;
  const TrackMilestoneLoaded(this.milestones);

  @override
  List<Object> get props => [milestones];
}

class TrackMilestoneError extends TrackMilestoneState {
  final String message;
  const TrackMilestoneError(this.message);

  @override
  List<Object> get props => [message];
}
