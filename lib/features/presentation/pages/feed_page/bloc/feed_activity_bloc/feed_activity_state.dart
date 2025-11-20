
import 'package:equatable/equatable.dart';

import '../../model/feed_activity_model.dart';

abstract class FeedActivityState extends Equatable {
  const FeedActivityState();

  @override
  List<Object> get props => [];
}

class FeedActivityInitial extends FeedActivityState {}

class FeedActivityLoading extends FeedActivityState {}

class FeedActivityLoaded extends FeedActivityState {
  final List<FeedActivityDataModel> feedActivityDataList;

  const FeedActivityLoaded(this.feedActivityDataList);

  @override
  List<Object> get props => [feedActivityDataList];
}

class FeedActivityError extends FeedActivityState {
  final String message;

  const FeedActivityError(this.message);

  @override
  List<Object> get props => [message];
}
