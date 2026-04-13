
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/network/api_controller.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../../ebook_page/model/dummy_list.dart';
import '../../model/recipe_playlist_video_model.dart';
import 'recipe_playlist_state.dart';



class RecipePlaylistCubit extends Cubit<RecipePlaylistState> {
  final DioClient _dioClient;

  RecipePlaylistCubit(this._dioClient) : super(RecipePlaylistInitial());

  void loadPlaylist(String playlistId) async {
    emit(RecipePlaylistLoading());
    try {
      final response = await _dioClient.sendPostRequest(
        ApiEndpoints.recipePlaylist,
        {'playlist_id': playlistId, 'limit': 1000},
      );

      if (response.data['status'] == 1) {
        final data = RecipePlaylistVideoModel.fromJson(response.data);
        emit(RecipePlaylistLoaded(
          playlistVideos: data.data!.playlistVideos,
          title: data.data?.playlist?.name ?? 'No title',
          description: data.data?.playlist?.description ?? 'No description',
          thumbnail: data.data?.playlist?.thumbnail ?? DummyData.avatarUrl,
        ));
      } else {
        emit(RecipePlaylistError(response.data['message'] ?? 'Unknown error'));
      }
    } catch (e) {
      emit(RecipePlaylistError(e.toString()));
    }
  }
}
