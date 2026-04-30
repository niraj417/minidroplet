abstract class ReportContentState {}

class ReportInitial extends ReportContentState {}

class ReportSubmitting extends ReportContentState {}

class ReportSuccess extends ReportContentState {
  final String message;
  ReportSuccess(this.message);
}

class ReportFailure extends ReportContentState {
  final String error;
  ReportFailure(this.error);
}
