class AllRecipeVideoModel {
  AllRecipeVideoModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<AllRecipeVideoDataModel> data;

  factory AllRecipeVideoModel.fromJson(Map<String, dynamic> json) {
    return AllRecipeVideoModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? []
          : List<AllRecipeVideoDataModel>.from(
              json["data"]!.map((x) => AllRecipeVideoDataModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $message, $data, ";
  }
}

class AllRecipeVideoDataModel {
  AllRecipeVideoDataModel({
    required this.id,
    required this.userId,
    required this.series,
    required this.category,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.uploadVideo,
    required this.price,
    required this.status,
    required this.mainPrice,
    required this.priceType,
    required this.publishDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isBuy,
  });

  final int id;
  final String userId;
  final String series;
  final String category;
  final String title;
  final String thumbnail;
  final String description;
  final String uploadVideo;
  final String price;
  final String status;
  final String mainPrice;
  final String priceType;
  final String publishDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String isBuy;

  factory AllRecipeVideoDataModel.fromJson(Map<String, dynamic> json) {
    return AllRecipeVideoDataModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? "",
      series: json["series"] ?? "",
      category: json["category"] ?? "",
      title: json["title"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      description: json["description"] ?? "",
      uploadVideo: json["upload_video"] ?? "",
      price: json["price"] ?? "",
      status: json["status"] ?? "",
      mainPrice: json["main_price"] ?? "",
      priceType: json["price_type"] ?? "",
      publishDate: json["publish_date"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      isBuy: json["is_buy"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "series": series,
        "category": category,
        "title": title,
        "thumbnail": thumbnail,
        "description": description,
        "upload_video": uploadVideo,
        "price": price,
        "status": status,
        "main_price": mainPrice,
        "price_type": priceType,
        "publish_date": publishDate,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "is_buy": isBuy,
      };

  @override
  String toString() {
    return "$id, $userId, $series, $category, $title, $thumbnail, $description, $uploadVideo, $price, $status, $mainPrice, $priceType, $publishDate, $createdAt, $updatedAt, $isBuy ";
  }
}
