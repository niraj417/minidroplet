class AllReviewModel {
  AllReviewModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<AllReviewDataModel> data;

  factory AllReviewModel.fromJson(Map<String, dynamic> json){
    return AllReviewModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<AllReviewDataModel>.from(json["data"]!.map((x) => AllReviewDataModel.fromJson(x))),
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

class AllReviewDataModel {
  AllReviewDataModel({
    required this.id,
    required this.userId,
    required this.ebookId,
    required this.rating,
    required this.review,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.username,
    required this.profile,
  });

  final int id;
  final int userId;
  final int ebookId;
  final String rating;
  final String review;
  final int status;
  final String type;
  final DateTime? createdAt;
  final String username;
  final String profile;

  factory AllReviewDataModel.fromJson(Map<String, dynamic> json){
    return AllReviewDataModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? 0,
      ebookId: json["ebook_id"] ?? 0,
      rating: json["rating"] ?? "",
      review: json["review"] ?? "",
      status: json["status"] ?? 0,
      type: json["type"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      username: json["username"] ?? "",
      profile: json["profile"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "ebook_id": ebookId,
    "rating": rating,
    "review": review,
    "status": status,
    "type": type,
    "created_at": createdAt?.toIso8601String(),
    "username": username,
    "profile": profile,
  };

  @override
  String toString(){
    return "$id, $userId, $ebookId, $rating, $review, $status, $type, $createdAt, $username, $profile, ";
  }
}
