part of 'affiliate_cubit.dart';

abstract class AffiliateState extends Equatable {
  const AffiliateState();

  @override
  List<Object> get props => [];
}

class AffiliateInitial extends AffiliateState {}

class AffiliateLoading extends AffiliateState {}

class AffiliateLoaded extends AffiliateState {
  final List<Map<String, dynamic>> links;

  const AffiliateLoaded(this.links);

  @override
  List<Object> get props => [links];
}

class AffiliateError extends AffiliateState {
  final String message;

  const AffiliateError(this.message);

  @override
  List<Object> get props => [message];
}
