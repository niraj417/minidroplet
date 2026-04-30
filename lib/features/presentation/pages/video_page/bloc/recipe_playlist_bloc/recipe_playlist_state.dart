
import '../../model/playlist_video_model.dart';
import '../../model/recipe_playlist_model.dart';

abstract class RecipePlaylistState {}

class RecipePlaylistInitial extends RecipePlaylistState {}

class RecipePlaylistLoading extends RecipePlaylistState {}

class RecipePlaylistLoaded extends RecipePlaylistState {
  final List<PlaylistVideo> playlistVideos;
  final String title;
  final String description;
  final String thumbnail;

  RecipePlaylistLoaded({
    required this.playlistVideos,
    required this.title,
    required this.description,
    required this.thumbnail,
  });
}

class RecipePlaylistError extends RecipePlaylistState {
  final String message;

  RecipePlaylistError(this.message);
}
