
class PlaylistVideo {
  PlaylistVideo({
    required this.id,
    required this.userId,
    required this.series,
    required this.category,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.howToServe,
    required this.uploadVideo,
    required this.price,
    required this.status,
    required this.mainPrice,
    required this.priceType,
    required this.publishDate,
    required this.priority,
    required this.ageGroup,
    required this.timeDuration,
    required this.calories,
    required this.videoHide,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String userId;
  final String series;
  final String category;
  final String title;
  final String thumbnail;
  final String description;
  final dynamic howToServe;
  final String uploadVideo;
  final String price;
  final String status;
  final String mainPrice;
  final String priceType;
  final String publishDate;
  final String priority;
  final String ageGroup;
  final String timeDuration;
  final String calories;
  final int videoHide;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PlaylistVideo.fromJson(Map<String, dynamic> json){
    return PlaylistVideo(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? "",
      series: json["series"] ?? "",
      category: json["category"] ?? "",
      title: json["title"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      description: json["description"] ?? "",
      howToServe: json["how_to_serve"],
      uploadVideo: json["upload_video"] ?? "",
      price: json["price"] ?? "",
      status: json["status"] ?? "",
      mainPrice: json["main_price"] ?? "",
      priceType: json["price_type"] ?? "",
      publishDate: json["publish_date"] ?? "",
      priority: json["priority"] ?? "",
      ageGroup: json["age_group"] ?? "",
      timeDuration: json["time_duration"] ?? "",
      calories: json["calories"] ?? "",
      videoHide: json["video_hide"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
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
    "how_to_serve": howToServe,
    "upload_video": uploadVideo,
    "price": price,
    "status": status,
    "main_price": mainPrice,
    "price_type": priceType,
    "publish_date": publishDate,
    "priority": priority,
    "age_group": ageGroup,
    "time_duration": timeDuration,
    "calories": calories,
    "video_hide": videoHide,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $userId, $series, $category, $title, $thumbnail, $description, $howToServe, $uploadVideo, $price, $status, $mainPrice, $priceType, $publishDate, $priority, $ageGroup, $timeDuration, $calories, $videoHide, $createdAt, $updatedAt, ";
  }
}
