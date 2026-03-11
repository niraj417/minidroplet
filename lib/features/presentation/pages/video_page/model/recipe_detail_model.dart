// class RecipeDetailModel {
//   RecipeDetailModel({
//     required this.status,
//     required this.message,
//     required this.data,
//   });
//
//   final int status;
//   final String message;
//   final RecipeDetailDataModel? data;
//
//   factory RecipeDetailModel.fromJson(Map<String, dynamic> json) {
//     return RecipeDetailModel(
//       status: json["status"] ?? 0,
//       message: json["message"] ?? "",
//       data: json["data"] == null
//           ? null
//           : RecipeDetailDataModel.fromJson(json["data"]),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "data": data?.toJson(),
//       };
//
//   @override
//   String toString() {
//     return "$status, $message, $data, ";
//   }
// }
//
// class RecipeDetailDataModel {
//   RecipeDetailDataModel({
//     required this.video,
//     required this.ingrediants,
//   });
//
//   final Video? video;
//   final List<Ingrediant> ingrediants;
//
//   factory RecipeDetailDataModel.fromJson(Map<String, dynamic> json) {
//     return RecipeDetailDataModel(
//       video: json["video"] == null ? null : Video.fromJson(json["video"]),
//       ingrediants: json["ingrediants"] == null
//           ? []
//           : List<Ingrediant>.from(
//               json["ingrediants"]!.map((x) => Ingrediant.fromJson(x))),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "video": video?.toJson(),
//         "ingrediants": ingrediants.map((x) => x.toJson()).toList(),
//       };
//
//   @override
//   String toString() {
//     return "$video, $ingrediants, ";
//   }
// }
//
// class Ingrediant {
//   Ingrediant({
//     required this.id,
//     required this.videoId,
//     required this.name,
//     required this.image,
//     required this.weight,
//     required this.createdAt,
//   });
//
//   final int id;
//   final String videoId;
//   final String name;
//   final String image;
//   final String weight;
//   final DateTime? createdAt;
//
//   factory Ingrediant.fromJson(Map<String, dynamic> json) {
//     return Ingrediant(
//       id: json["id"] ?? 0,
//       videoId: json["video_id"] ?? "",
//       name: json["name"] ?? "",
//       image: json["image"] ?? "",
//       weight: json["weight"] ?? "",
//       createdAt: DateTime.tryParse(json["created_at"] ?? ""),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "video_id": videoId,
//         "name": name,
//         "image": image,
//         "weight": weight,
//         "created_at": createdAt?.toIso8601String(),
//       };
//
//   @override
//   String toString() {
//     return "$id, $videoId, $name, $image, $weight, $createdAt, ";
//   }
// }
//
// class Video {
//   Video({
//     required this.id,
//     required this.userId,
//     required this.series,
//     required this.category,
//     required this.title,
//     required this.thumbnail,
//     required this.description,
//     required this.uploadVideo,
//     required this.price,
//     required this.status,
//     required this.mainPrice,
//     required this.priceType,
//     required this.publishDate,
//     required this.priority,
//     required this.ageGroup,
//     required this.timeDuration,
//     required this.calories,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.adminName,
//     required this.ageGroupName,
//     required this.categoryName,
//     required this.avgRating,
//     required this.isSaved,
//     required this.subcatName,
//     required this.howToServe,
//     required this.videoType,
//   });
//
//   final int id;
//   final String userId;
//   final String series;
//   final String category;
//   final String title;
//   final String thumbnail;
//   final String description;
//   final String uploadVideo;
//   final String price;
//   final String status;
//   final String mainPrice;
//   final String priceType;
//   final String publishDate;
//   final String priority;
//   final String ageGroup;
//   final String timeDuration;
//   final String calories;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final String adminName;
//   final String ageGroupName;
//   final String categoryName;
//   final int avgRating;
//   final String isSaved;
//   final String subcatName;
//   final String howToServe;
//   final String? videoType;
//
//   factory Video.fromJson(Map<String, dynamic> json) {
//     return Video(
//       id: json["id"] ?? 0,
//       userId: json["user_id"] ?? "",
//       series: json["series"] ?? "",
//       category: json["category"] ?? "",
//       title: json["title"] ?? "",
//       thumbnail: json["thumbnail"] ?? "",
//       description: json["description"] ?? "",
//       uploadVideo: json["upload_video"] ?? "",
//       price: json["price"] ?? "",
//       status: json["status"] ?? "",
//       mainPrice: json["main_price"] ?? "",
//       priceType: json["price_type"] ?? "",
//       publishDate: json["publish_date"] ?? "",
//       priority: json["priority"] ?? "",
//       ageGroup: json["age_group"] ?? "",
//       timeDuration: json["time_duration"] ?? "",
//       calories: json["calories"] ?? "",
//       createdAt: DateTime.tryParse(json["created_at"] ?? ""),
//       updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
//       adminName: json["admin_name"] ?? "",
//       ageGroupName: json["age_group_name"] ?? "",
//       categoryName: json["category_name"] ?? "",
//       avgRating: json["avg_rating"] ?? 0,
//       isSaved: json["is_saved"] ?? "",
//       subcatName: json["subcat_name"] ?? "",
//       howToServe: json["how_to_serve"] ?? "",
//       videoType: json["video_type"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "user_id": userId,
//         "series": series,
//         "category": category,
//         "title": title,
//         "thumbnail": thumbnail,
//         "description": description,
//         "upload_video": uploadVideo,
//         "price": price,
//         "status": status,
//         "main_price": mainPrice,
//         "price_type": priceType,
//         "publish_date": publishDate,
//         "priority": priority,
//         "age_group": ageGroup,
//         "time_duration": timeDuration,
//         "calories": calories,
//         "created_at": createdAt?.toIso8601String(),
//         "updated_at": updatedAt?.toIso8601String(),
//         "admin_name": adminName,
//         "age_group_name": ageGroupName,
//         "category_name": categoryName,
//         "avg_rating": avgRating,
//         "is_saved": isSaved,
//         "subcat_name": subcatName,
//         "how_to_serve": howToServe,
//         "video_type": videoType,
//       };
//
//   @override
//   String toString() {
//     return "$id, $userId, $series, $category, $title, $thumbnail, $description,"
//         " $uploadVideo, $price, $status, $mainPrice, $priceType, $publishDate, $priority, $ageGroup, "
//         "$timeDuration, $calories, $createdAt, $updatedAt, $adminName, $ageGroupName, $categoryName, "
//         "$avgRating, $isSaved, $subcatName, $howToServe, $videoType";
//   }
// }


class RecipeDetailModel {
  RecipeDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int? status;
  final String? message;
  final RecipeDetailDataModel? data;

  factory RecipeDetailModel.fromJson(Map<String, dynamic> json){
    return RecipeDetailModel(
      status: json["status"],
      message: json["message"],
      data: json["data"] == null ? null : RecipeDetailDataModel.fromJson(json["data"]),
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

class RecipeDetailDataModel {
  RecipeDetailDataModel({
    required this.video,
    required this.ingrediants,
    required this.videoSteps,
  });

  final Video? video;
  final List<Ingrediant> ingrediants;
  final List<VideoStep> videoSteps;

  factory RecipeDetailDataModel.fromJson(Map<String, dynamic> json){
    return RecipeDetailDataModel(
      video: json["video"] == null ? null : Video.fromJson(json["video"]),
      ingrediants: json["ingrediants"] == null ? [] : List<Ingrediant>.from(json["ingrediants"]!.map((x) => Ingrediant.fromJson(x))),
      videoSteps: json["video_steps"] == null ? [] : List<VideoStep>.from(json["video_steps"]!.map((x) => VideoStep.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "video": video?.toJson(),
    "ingrediants": ingrediants.map((x) => x?.toJson()).toList(),
    "video_steps": videoSteps.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString(){
    return "$video, $ingrediants, $videoSteps, ";
  }
}

class Ingrediant {
  Ingrediant({
    required this.id,
    required this.videoId,
    required this.name,
    required this.image,
    required this.weight,
    required this.createdAt,
  });

  final int? id;
  final String? videoId;
  final String? name;
  final String? image;
  final String? weight;
  final DateTime? createdAt;

  factory Ingrediant.fromJson(Map<String, dynamic> json){
    return Ingrediant(
      id: json["id"],
      videoId: json["video_id"],
      name: json["name"],
      image: json["image"],
      weight: json["weight"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "video_id": videoId,
    "name": name,
    "image": image,
    "weight": weight,
    "created_at": createdAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $videoId, $name, $image, $weight, $createdAt, ";
  }
}

class Video {
  Video({
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
    required this.videoType,
    required this.createdAt,
    required this.updatedAt,
    required this.adminName,
    required this.ageGroupName,
    required this.categoryName,
    required this.avgRating,
    required this.isSaved,
    required this.subcatName,
  });

  final int? id;
  final String? userId;
  final dynamic series;
  final String? category;
  final String? title;
  final String? thumbnail;
  final String? description;
  final String? howToServe;
  final String? uploadVideo;
  final String? price;
  final String? status;
  final String? mainPrice;
  final String? priceType;
  final String? publishDate;
  final String? priority;
  final String? ageGroup;
  final String? timeDuration;
  final String? calories;
  final int? videoHide;
  final String? videoType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? adminName;
  final String? ageGroupName;
  final String? categoryName;
  final int? avgRating;
  final String? isSaved;
  final String? subcatName;

  factory Video.fromJson(Map<String, dynamic> json){
    return Video(
      id: json["id"],
      userId: json["user_id"],
      series: json["series"],
      category: json["category"],
      title: json["title"],
      thumbnail: json["thumbnail"],
      description: json["description"],
      howToServe: json["how_to_serve"],
      uploadVideo: json["upload_video"],
      price: json["price"],
      status: json["status"],
      mainPrice: json["main_price"],
      priceType: json["price_type"],
      publishDate: json["publish_date"],
      priority: json["priority"],
      ageGroup: json["age_group"],
      timeDuration: json["time_duration"],
      calories: json["calories"],
      videoHide: json["video_hide"],
      videoType: json["video_type"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      adminName: json["admin_name"],
      ageGroupName: json["age_group_name"],
      categoryName: json["category_name"],
      avgRating: json["avg_rating"],
      isSaved: json["is_saved"],
      subcatName: json["subcat_name"],
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
    "video_type": videoType,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "admin_name": adminName,
    "age_group_name": ageGroupName,
    "category_name": categoryName,
    "avg_rating": avgRating,
    "is_saved": isSaved,
    "subcat_name": subcatName,
  };

  @override
  String toString(){
    return "$id, $userId, $series, $category, $title, $thumbnail, $description, $howToServe, $uploadVideo, $price, $status, $mainPrice, $priceType, $publishDate, $priority, $ageGroup, $timeDuration, $calories, $videoHide, $videoType, $createdAt, $updatedAt, $adminName, $ageGroupName, $categoryName, $avgRating, $isSaved, $subcatName, ";
  }
}

class VideoStep {
  VideoStep({
    required this.id,
    required this.videoId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final int? id;
  final String? videoId;
  final String? title;
  final String? description;
  final int? status;
  final DateTime? createdAt;

  factory VideoStep.fromJson(Map<String, dynamic> json){
    return VideoStep(
      id: json["id"],
      videoId: json["video_id"],
      title: json["title"],
      description: json["description"],
      status: json["status"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "video_id": videoId,
    "title": title,
    "description": description,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $videoId, $title, $description, $status, $createdAt, ";
  }
}
