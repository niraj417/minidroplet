import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/recently_viewed_ebook_model.dart';

import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/services/payment_service.dart';
import '../../../../../../core/utils/common_methods.dart';
import '../../model/all_ebook_model.dart';
import '../../model/ebook_slider_model.dart';
import 'ebook_event.dart';
import 'ebook_state.dart';
class EbookBloc extends Bloc<EbookEvent, EbookState> {
  EbookBloc() : super(EbookInitial()) {
    on<FetchEbookCarouselData>(_onFetchEbookCarouselData);
    on<FetchAllEbookData>(_onFetchAllEbookData);
    on<FetchRecentlyViewedEbookData>(_onFetchRecentlyEbook);
    on<RefreshEbookData>(_onRefreshEbookData);
  }

  Future<void> _onFetchEbookCarouselData(
      FetchEbookCarouselData event,
      Emitter<EbookState> emit,
      ) async {
    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.ebookSlider);

      if (response.data['status'] == 1) {
        final data = EbookSliderModel.fromJson(response.data);
        CommonMethods.devLog(logName: 'Ebook slider', message: data.data);

        emit(EbookLoaded(
          ebookItems: data.data,
          allEbookItems: state.allEbookItems,
          recentlyViewedItem: state.recentlyViewedItem,
          isCarouselLoading: false,
          isAllEbookLoading: state.isAllEbookLoading,
          recentlyViewedItemLoading: state.recentlyViewedItemLoading,
        ));
      } else {
        emit(EbookLoaded(
          ebookItems: state.ebookItems,
          allEbookItems: state.allEbookItems,
          recentlyViewedItem: state.recentlyViewedItem,
          isCarouselLoading: false,
          isAllEbookLoading: state.isAllEbookLoading,
          recentlyViewedItemLoading: state.recentlyViewedItemLoading,
        ));
        print('Failed to load carousel data: ${response.data['message']}');
      }
    } catch (e) {
      emit(state);
      print('Error fetching carousel data: $e');
    }
  }

  Future<void> _onFetchAllEbookData(
      FetchAllEbookData event,
      Emitter<EbookState> emit,
      ) async {
    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.allEbooks);

      if (response.data['status'] == 1) {
        final data = AllEbookModel.fromJson(response.data);
        CommonMethods.devLog(logName: 'All Ebook', message: data.data);

        emit(EbookLoaded(
          ebookItems: state.ebookItems,
          allEbookItems: data.data,
          recentlyViewedItem: state.recentlyViewedItem,
          isCarouselLoading: state.isCarouselLoading,
          isAllEbookLoading: false,
          recentlyViewedItemLoading: state.recentlyViewedItemLoading,
        ));
      } else {
        emit(EbookLoaded(
          ebookItems: state.ebookItems,
          allEbookItems: state.allEbookItems,
          recentlyViewedItem: state.recentlyViewedItem,
          isCarouselLoading: state.isCarouselLoading,
          isAllEbookLoading: false,
          recentlyViewedItemLoading: state.recentlyViewedItemLoading,
        ));
        print('Failed to load all ebooks: ${response.data['message']}');
      }
    } catch (e) {
      emit(state);
      print('Error fetching all ebooks: $e');
    }
  }

  Future<void> _onFetchRecentlyEbook(
      FetchRecentlyViewedEbookData event,
      Emitter<EbookState> emit,
      ) async {
    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.recentViewedEbook);

      if (response.data['status'] == 1) {
        final data = RecentlyViewedEbookModel.fromJson(response.data);
        CommonMethods.devLog(logName: 'Recently Viewed', message: data.data);

        emit(EbookLoaded(
          ebookItems: state.ebookItems,
          allEbookItems: state.allEbookItems,
          recentlyViewedItem: data.data,
          isCarouselLoading: state.isCarouselLoading,
          isAllEbookLoading: state.isAllEbookLoading,
          recentlyViewedItemLoading: false,
        ));
      } else {
        emit(EbookLoaded(
          ebookItems: state.ebookItems,
          allEbookItems: state.allEbookItems,
          recentlyViewedItem: state.recentlyViewedItem,
          isCarouselLoading: state.isCarouselLoading,
          isAllEbookLoading: state.isAllEbookLoading,
          recentlyViewedItemLoading: false,
        ));
        print('Failed to load recent ebooks: ${response.data['message']}');
      }
    } catch (e) {
      emit(state);
      print('Error fetching recent ebooks: $e');
    }
  }

  Future<void> _onRefreshEbookData(
      RefreshEbookData event,
      Emitter<EbookState> emit,
      ) async {
    add(FetchEbookCarouselData());
    add(FetchAllEbookData());
    add(FetchRecentlyViewedEbookData());
  }
}