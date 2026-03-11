import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:tinydroplets/core/constant/app_export.dart';

part 'affiliate_state.dart';

class AffiliateCubit extends Cubit<AffiliateState> {
  AffiliateCubit() : super(AffiliateInitial());

  final DioClient _dio = DioClient();

  Future<void> fetchAffiliateLinks(int id) async {
    emit(AffiliateLoading());
    try {
      final response = await _dio.sendPostRequest(
          ApiEndpoints.recommendation, {'age_group': id.toString()});

      if (response.data['status'] == 1) {
        final data = response.data['data'] as List<dynamic>;
        final links = data.map((e) => Map<String, dynamic>.from(e)).toList();
        emit(AffiliateLoaded(links));
      } else {
        emit(const AffiliateError('Failed to load data'));
      }
    } catch (e) {
      emit(AffiliateError(e.toString()));
    }
  }
}
