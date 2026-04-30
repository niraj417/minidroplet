import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/core/network/api_controller.dart';
import 'package:tinydroplets/core/network/api_endpoints.dart';
import 'package:tinydroplets/features/components/report_content/bloc/report_content_event.dart';
import 'package:tinydroplets/features/components/report_content/bloc/report_content_state.dart';

class ReportContentBloc extends Bloc<ReportContentEvent, ReportContentState> {
  final DioClient dioClient;

  ReportContentBloc(this.dioClient) : super(ReportInitial()) {
    on<SubmitReport>(_onSubmitReport);
  }

  Future<void> _onSubmitReport(
    SubmitReport event,
    Emitter<ReportContentState> emit,
  ) async {
    emit(ReportSubmitting());

    try {
      final response = await dioClient
          .sendPostRequest(ApiEndpoints.reportContentUrl, {
            'content_id': event.contentId,
            'type': event.type,
            'description': event.description,
          });

      if (response.data['status'] == 1) {
        emit(
          ReportSuccess(response.data['message'] ?? 'Reported successfully.'),
        );
      } else {
        emit(ReportFailure(response.data['message'] ?? 'Failed to report.'));
      }
    } catch (e) {
      emit(ReportFailure('Error: ${e.toString()}'));
    }
  }
}
