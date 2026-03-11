class PurchasedEbookModel {
  PurchasedEbookModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final PurchasedEbookDataModel? data;

  factory PurchasedEbookModel.fromJson(Map<String, dynamic> json){
    return PurchasedEbookModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : PurchasedEbookDataModel.fromJson(json["data"]),
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

class PurchasedEbookDataModel {
  PurchasedEbookDataModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.attachment,
    required this.price,
    required this.status,
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
    required this.allChapters,
  });

  final int id;
  final String userId;
  final String title;
  final String description;
  final String coverImage;
  final String attachment;
  final String price;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String authorName;
  final String isSaved;
  final String isRating;
  final num totalRating;
  final num totalReview;
  final String pages;
  final String audio;
  final String preview;
  final List<AllChapter> allChapters;

  factory PurchasedEbookDataModel.fromJson(Map<String, dynamic> json){
    return PurchasedEbookDataModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      coverImage: json["cover_image"] ?? "",
      attachment: json["attachment"] ?? "",
      price: json["price"] ?? "",
      status: json["status"] ?? 0,
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
      // allChapters: (json['allChapters'] as List?)?.map((chapter) => AllChapter.fromJson(chapter)).toList() ?? [],

     allChapters: json["all_chapters"] == null ? [] : List<AllChapter>.from(json["all_chapters"]!.map((x) => AllChapter.fromJson(x))),
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
    "status": status,
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
    "all_chapters": allChapters.map((x) => x.toJson()).toList(),
  };

  @override
  String toString(){
    return "$id, $userId, $title, $description, $coverImage, $attachment, $price, $status, $createdAt, $updatedAt, $authorName, $isSaved, $isRating, $totalRating, $totalReview, $pages, $audio, $preview, $allChapters, ";
  }
}

class AllChapter {
  AllChapter({
    required this.id,
    required this.ebookId,
    required this.chapterName,
    required this.attachment,
    required this.audio,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String ebookId;
  final String chapterName;
  final String attachment;
  final String audio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AllChapter.fromJson(Map<String, dynamic> json){
    return AllChapter(
      id: json["id"] ?? 0,
      ebookId: json["ebook_id"] ?? "",
      chapterName: json["chapter_name"] ?? "",
      attachment: json["attachment"] ?? "",
      audio: json["audio"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "ebook_id": ebookId,
    "chapter_name": chapterName,
    "attachment": attachment,
    "audio": audio,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $ebookId, $chapterName, $attachment, $audio, $createdAt, $updatedAt, ";
  }
}
