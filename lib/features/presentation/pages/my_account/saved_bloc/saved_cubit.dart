import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_controller.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/services/payment_service.dart';
import '../model/saved_item_model.dart';

class SavedItemsState extends Equatable {
  final List<SavedItemDataModel> ebooks;
  final List<SavedItemDataModel> videos;
  final List<SavedItemDataModel> playlists;
  final ItemType selectedType;
  final bool isLoading;
  final String? error;

  const SavedItemsState({
    this.ebooks = const [],
    this.videos = const [],
    this.playlists = const [],
    this.selectedType = ItemType.all,
    this.isLoading = false,
    this.error,
  });

  List<SavedItemDataModel> get currentItems {
    switch (selectedType) {
      case ItemType.all:
        return [...ebooks, ...videos, ...playlists];
      case ItemType.ebook:
        return ebooks;
      case ItemType.video:
        return videos;
      case ItemType.playlist:
        return playlists;
    }
  }

  SavedItemsState copyWith({
    List<SavedItemDataModel>? ebooks,
    List<SavedItemDataModel>? videos,
    List<SavedItemDataModel>? playlists,
    ItemType? selectedType,
    bool? isLoading,
    String? error,
  }) {
    return SavedItemsState(
      ebooks: ebooks ?? this.ebooks,
      videos: videos ?? this.videos,
      playlists: playlists ?? this.playlists,
      selectedType: selectedType ?? this.selectedType,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [ebooks, videos, playlists, selectedType, isLoading, error];
}

class SavedItemsCubit extends Cubit<SavedItemsState> {

  SavedItemsCubit() : super(const SavedItemsState());

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await Future.wait([
        _fetchSavedEbooks(),
        _fetchSavedVideos(),
        _fetchSavedPlaylists(),
      ]);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load saved items',
      ));
    }
  }

  Future<void> _fetchSavedEbooks() async {
    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.savedEbook);
      if (response.data['status'] == 1) {
        final ebooks = SavedItemModel.fromJson(response.data)
            .data
            .map((item) => item.copyWith(type: ItemType.ebook))
            .toList();
        emit(state.copyWith(ebooks: ebooks));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load ebooks'));
    }
  }

  Future<void> _fetchSavedVideos() async {
    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.savedVideo);
      if (response.data['status'] == 1) {
        final videos = SavedItemModel.fromJson(response.data)
            .data
            .map((item) => item.copyWith(type: ItemType.video))
            .toList();
        emit(state.copyWith(videos: videos));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load videos'));
    }
  }

  Future<void> _fetchSavedPlaylists() async {
    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.savedPlaylist);
      if (response.data['status'] == 1) {
        final playlists = SavedItemModel.fromJson(response.data)
            .data
            .map((item) => item.copyWith(type: ItemType.playlist))
            .toList();
        emit(state.copyWith(playlists: playlists));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load playlists'));
    }
  }

  Future<void> removeItem(SavedItemDataModel item) async {
    try {
      String endpoint;
      switch (item.type) {
        case ItemType.ebook:
          endpoint = ApiEndpoints.removeSavedEbook;
          break;
        case ItemType.video:
          endpoint = ApiEndpoints.removeSavedVideo;
          break;
        case ItemType.playlist:
          endpoint = ApiEndpoints.removePlaylist;
          break;
        default:
          return;
      }

      final response = await dioClient.sendPostRequest(endpoint, {'id': item.id});
      if (response.data['status'] == 1) {
        switch (item.type) {
          case ItemType.ebook:
            emit(state.copyWith(
              ebooks: state.ebooks.where((e) => e.id != item.id).toList(),
            ));
            break;
          case ItemType.video:
            emit(state.copyWith(
              videos: state.videos.where((e) => e.id != item.id).toList(),
            ));
            break;
          case ItemType.playlist:
            emit(state.copyWith(
              playlists: state.playlists.where((e) => e.id != item.id).toList(),
            ));
            break;
          default:
            break;
        }
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to remove item'));
    }
  }

  void changeTab(ItemType type) {
    emit(state.copyWith(selectedType: type));
  }
}
