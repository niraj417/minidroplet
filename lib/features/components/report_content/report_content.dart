import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tinydroplets/core/network/api_controller.dart';
import 'package:tinydroplets/core/utils/common_methods.dart';
import 'package:tinydroplets/features/components/report_content/bloc/report_content_bloc.dart';
import 'package:tinydroplets/features/components/report_content/bloc/report_content_event.dart';
import 'package:tinydroplets/features/components/report_content/bloc/report_content_state.dart';

class ReportContentWidget extends StatelessWidget {
  final int contentId;
  final String contentType;

  const ReportContentWidget({
    super.key,
    required this.contentId,
    required this.contentType,
  });

  void _showReportDialog(BuildContext context) {
    final bloc = ReportContentBloc(GetIt.I<DioClient>());
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => BlocProvider.value(
            value: bloc,
            child: BlocConsumer<ReportContentBloc, ReportContentState>(
              listener: (context, state) {
                if (state is ReportSuccess) {
                  Navigator.of(context).pop();
                  CommonMethods.showSnackBar(context, state.message);
                } else if (state is ReportFailure) {
                  CommonMethods.showSnackBar(context, state.error);
                }
              },
              builder: (context, state) {
                return AlertDialog(
                  title: const Text('Report Content'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Do you want to report this content?'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe the issue (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed:
                          state is ReportSubmitting
                              ? null
                              : () {
                                bloc.add(
                                  SubmitReport(
                                    contentId: contentId,
                                    type: contentType,
                                     description: descriptionController.text.trim(),
                                  ),
                                );
                              },
                      child:
                          state is ReportSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.flag,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Report',
                                    // style: TextStyle(color: Colors.redAccent),
                                  ),
                                ],
                              ),
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _showReportDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.flag, color: Colors.redAccent, size: 20),
          SizedBox(width: 4),
          Text('Report Content'),
        ],
      ),
    );
  }
}
