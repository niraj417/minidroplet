class EbookDetailModel {
  EbookDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final EbookDetailDataModel? data;

  factory EbookDetailModel.fromJson(Map<String, dynamic> json){
    return EbookDetailModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : EbookDetailDataModel.fromJson(json["data"]),
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

class EbookDetailDataModel {
  EbookDetailDataModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.attachment,
    required this.price,
    required this.mainPrice,
    required this.status,
    required this.publishDate,
    required this.createdAt,
    required this.updatedAt,
    required this.authorName,
    required this.isSaved,
    required this.isRating,
    required this.totalRating,
    required this.totalReview,
    required this.pages,
    required this.audio,
    required this.preview,
  });

  final int id;
  final String userId;
  final String title;
  final String description;
  final String coverImage;
  final String attachment;
  final String price;
  final String mainPrice;
  final int status;
  final String publishDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String authorName;
  final String isSaved;
  final String isRating;
  final int totalRating;
  final int totalReview;
  final String pages;
  final String audio;
  final String preview;

  factory EbookDetailDataModel.fromJson(Map<String, dynamic> json){
    return EbookDetailDataModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      coverImage: json["cover_image"] ?? "",
      attachment: json["attachment"] ?? "",
      price: json["price"] ?? "",
      mainPrice: json["main_price"] ?? "",
      status: json["status"] ?? 0,
      publishDate: json["publish_date"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      authorName: json["author_name"] ?? "",
      isSaved: json["is_saved"] ?? "",
      isRating: json["is_rating"] ?? "",
      totalRating: json["total_rating"] ?? 0,
      totalReview: json["total_review"] ?? 0,
      pages: json["pages"] ?? "",
      audio: json["audio"] ?? "",
      preview: json["preview"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "title": title,
    "description": description,
    "cover_image": coverImage,
    "attachment": attachment,
    "price": price,
    "main_price": mainPrice,
    "status": status,
    "publish_date": publishDate,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "author_name": authorName,
    "is_saved": isSaved,
    "is_rating": isRating,
    "total_rating": totalRating,
    "total_review": totalReview,
    "pages": pages,
    "audio": audio,
    "preview": preview,
  };

  @override
  String toString(){
    return "$id, $userId, $title, $description, $coverImage, $attachment, $price, $status, $publishDate, $createdAt, $updatedAt, $authorName, $isSaved, $isRating, $totalRating, $totalReview, $pages, $audio, $preview, ";
  }
}
