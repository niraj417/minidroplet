abstract class ReportContentEvent {}

class SubmitReport extends ReportContentEvent {
  final int contentId;
  final String type;
  final String description;

  SubmitReport({
    required this.description,
    required this.contentId,
    required this.type,
  });
}
