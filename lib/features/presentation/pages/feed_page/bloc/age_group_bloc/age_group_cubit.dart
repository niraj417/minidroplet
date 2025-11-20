import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:tinydroplets/core/constant/app_export.dart';

part 'age_group_state.dart';

class AgeGroupCubit extends Cubit<AgeGroupState> {
  final DioClient _dioClient = DioClient();

  AgeGroupCubit() : super(AgeGroupInitial());

  Future<void> fetchAgeGroup() async {
    emit(AgeGroupLoading());
    try {
      final response = await _dioClient.sendPostRequest(ApiEndpoints.ebookAgeGroup, {});
      if (response.data['status'] == 1) {
        List<Map<String, dynamic>> ageGroupList = [];
        if (response.data['data'] is String) {
          ageGroupList = List<Map<String, dynamic>>.from(jsonDecode(response.data['data']));
        } else if (response.data['data'] is List) {
          ageGroupList = List<Map<String, dynamic>>.from(response.data['data']);
        }

        emit(AgeGroupLoaded(ageGroupList));
      } else {
        emit(AgeGroupError("Failed to load age groups"));
      }
    } catch (e) {
      emit(AgeGroupError(e.toString()));
    }
  }
}

