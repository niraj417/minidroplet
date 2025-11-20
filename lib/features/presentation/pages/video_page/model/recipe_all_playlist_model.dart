class RecipeAllPlaylistModel {
  RecipeAllPlaylistModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<RecipeAllPlaylistDataModel> data;

  factory RecipeAllPlaylistModel.fromJson(Map<String, dynamic> json){
    return RecipeAllPlaylistModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<RecipeAllPlaylistDataModel>.from(json["data"]!.map((x) => RecipeAllPlaylistDataModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString(){
    return "$status, $message, $data, ";
  }
}

class RecipeAllPlaylistDataModel {
  RecipeAllPlaylistDataModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.thumbnail,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.mainPrice,
    required this.price,
    required this.priceType,
    required this.isBuy,
    required this.totalVideos,
  });

  final int id;
  final String name;
  final String userId;
  final String thumbnail;
  final String description;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String mainPrice;
  final String price;
  final String priceType;
  final String isBuy;
  final int totalVideos;

  factory RecipeAllPlaylistDataModel.fromJson(Map<String, dynamic> json){
    return RecipeAllPlaylistDataModel(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      userId: json["user_id"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      description: json["description"] ?? "",
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      mainPrice: json["main_price"] ?? "",
      price: json["price"] ?? "",
      priceType: json["price_type"] ?? "",
      isBuy: json["is_buy"] ?? "",
      totalVideos: json["total_videos"] ?? 0,
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
    "main_price": mainPrice,
    "price": price,
    "price_type": priceType,
    "is_buy": isBuy,
    "total_videos": totalVideos,
  };

  @override
  String toString(){
    return "$id, $name, $userId, $thumbnail, $description, $status, $createdAt, $updatedAt, $mainPrice, $price, $priceType, $isBuy, $totalVideos, ";
  }
}
