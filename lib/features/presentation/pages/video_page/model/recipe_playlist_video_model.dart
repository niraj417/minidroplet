import 'package:tinydroplets/features/presentation/pages/video_page/model/playlist_video_model.dart';

class RecipePlaylistVideoModel {
  RecipePlaylistVideoModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final RecipePlaylistVideoDataModel? data;

  factory RecipePlaylistVideoModel.fromJson(Map<String, dynamic> json){
    return RecipePlaylistVideoModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : RecipePlaylistVideoDataModel.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };

  @override
  String toString(){
    return "$status, $message, $data, ";
  }
}

class RecipePlaylistVideoDataModel {
  RecipePlaylistVideoDataModel({
    required this.playlist,
    required this.playlistVideos,
  });

  final Playlist? playlist;
  final List<PlaylistVideo> playlistVideos;

  factory RecipePlaylistVideoDataModel.fromJson(Map<String, dynamic> json){
    return RecipePlaylistVideoDataModel(
      playlist: json["playlist"] == null ? null : Playlist.fromJson(json["playlist"]),
      playlistVideos: json["playlist_videos"] == null ? [] : List<PlaylistVideo>.from(json["playlist_videos"]!.map((x) => PlaylistVideo.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "playlist": playlist?.toJson(),
    "playlist_videos": playlistVideos.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString(){
    return "$playlist, $playlistVideos, ";
  }
}

class Playlist {
  Playlist({
    required this.id,
    required this.name,
    required this.userId,
    required this.thumbnail,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String userId;
  final String thumbnail;
  final String description;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Playlist.fromJson(Map<String, dynamic> json){
    return Playlist(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      userId: json["user_id"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      description: json["description"] ?? "",
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "user_id": userId,
    "thumbnail": thumbnail,
    "description": description,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $name, $userId, $thumbnail, $description, $status, $createdAt, $updatedAt, ";
  }
}
