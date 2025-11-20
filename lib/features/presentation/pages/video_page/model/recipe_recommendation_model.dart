class RecipeRecommendationModel {
  RecipeRecommendationModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<RecipeRecommendationDataModel> data;

  factory RecipeRecommendationModel.fromJson(Map<String, dynamic> json){
    return RecipeRecommendationModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<RecipeRecommendationDataModel>.from(json["data"]!.map((x) => RecipeRecommendationDataModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString(){
    return "$status, $message, $data, ";
  }
}

class RecipeRecommendationDataModel {
  RecipeRecommendationDataModel({
    required this.id,
    required this.type,
    required this.title,
    required this.videoId,
    required this.playlistId,
    required this.thumbnail,
    required this.name,
    required this.playlistThumbnail,
    required this.priceType,
    required this.mainPrice,
    required this.price,
    required this.playlistMainPrice,
    required this.playlistPrice,
    required this.playlistPriceType,
    required this.playlistDescription,
    required this.videoDescription,
    required this.isBuy,
    required this.description,
    required this.totalVideos,
    required this.videoTitle,
    required this.videoThumbnail,
  });

  final String id;
  final String type;
  final String title;
  final String videoId;
  final String playlistId;
  final String thumbnail;
  final String name;
  final String playlistThumbnail;
  final String priceType;
  final String mainPrice;
  final String price;
  final String playlistMainPrice;
  final String playlistPrice;
  final String playlistPriceType;
  final String playlistDescription;
  final String videoDescription;
  final String isBuy;
  final String description;
  final dynamic totalVideos;
  final String videoTitle;
  final String videoThumbnail;

  factory RecipeRecommendationDataModel.fromJson(Map<String, dynamic> json){
    return RecipeRecommendationDataModel(
      id: json["id"] ?? "",
      type: json["type"] ?? "",
      title: json["title"] ?? "",
      videoId: json["video_id"] ?? "",
      playlistId: json["playlist_id"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      name: json["name"] ?? "",
      playlistThumbnail: json["playlist_thumbnail"] ?? "",
      priceType: json["price_type"] ?? "",
      mainPrice: json["main_price"] ?? "",
      price: json["price"] ?? "",
      playlistMainPrice: json["playlist_main_price"] ?? "",
      playlistPrice: json["playlist_price"] ?? "",
      playlistPriceType: json["playlist_price_type"] ?? "",
      playlistDescription: json["playlist_description"] ?? "",
      videoDescription: json["video_description"] ?? "",
      isBuy: json["is_buy"] ?? "",
      description: json["description"] ?? "",
      totalVideos: json["total_videos"],
      videoTitle: json["video_title"] ?? "",
      videoThumbnail: json["video_thumbnail"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "title": title,
    "video_id": videoId,
    "playlist_id": playlistId,
    "thumbnail": thumbnail,
    "name": name,
    "playlist_thumbnail": playlistThumbnail,
    "price_type": priceType,
    "main_price": mainPrice,
    "price": price,
    "playlist_main_price": playlistMainPrice,
    "playlist_price": playlistPrice,
    "playlist_price_type": playlistPriceType,
    "playlist_description": playlistDescription,
    "video_description": videoDescription,
    "is_buy": isBuy,
    "description": description,
    "total_videos": totalVideos,
    "video_title": videoTitle,
    "video_thumbnail": videoThumbnail,
  };

  @override
  String toString(){
    return "$id, $type, $title, $videoId, $playlistId, $thumbnail, $name, $playlistThumbnail, $priceType, $mainPrice, $price, $playlistMainPrice, $playlistPrice, $playlistPriceType, $playlistDescription, $videoDescription, $isBuy, $description, $totalVideos, $videoTitle, $videoThumbnail, ";
  }
}
