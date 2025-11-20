import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
part 'track_milestone_state.dart';

enum MilestoneApiType { trackMilestone, activityCenter }

class TrackMilestoneCubit extends Cubit<TrackMilestoneState> {
  TrackMilestoneCubit() : super(TrackMilestoneInitial());

  final DioClient _dio = DioClient();

  Future<void> fetchMilestones(int ageGroupId,  MilestoneApiType apiType) async {
    emit(TrackMilestoneLoading());
    try {
      final String endpoint = apiType == MilestoneApiType.trackMilestone
          ? ApiEndpoints.trackMilestone
          : ApiEndpoints.activityCenter;

      final response = await _dio.sendPostRequest(endpoint, {
        'age_group': ageGroupId.toString(),
      });

      // final response = await _dio.sendPostRequest(
      //     ApiEndpoints.trackMilestone, {'age_group': id.toString()});

      if (response.data['status'] == 1) {
        final data = response.data['data'] as List<dynamic>;
        final milestones =
            data.map((e) => Map<String, dynamic>.from(e)).toList();
        emit(TrackMilestoneLoaded(milestones));
      } else {
        emit(const TrackMilestoneError('Failed to load data'));
      }
    } catch (e) {
      emit(TrackMilestoneError(e.toString()));
    }
  }
}
