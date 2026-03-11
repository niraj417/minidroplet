class RecipeCategoryModel {
  RecipeCategoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<RecipeCategoryDataModel> data;

  factory RecipeCategoryModel.fromJson(Map<String, dynamic> json){
    return RecipeCategoryModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<RecipeCategoryDataModel>.from(json["data"]!.map((x) => RecipeCategoryDataModel.fromJson(x))),
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

class RecipeCategoryDataModel {
  RecipeCategoryDataModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.image,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String userId;
  final String name;
  final String image;
  final int status;
  final DateTime? createdAt;

  factory RecipeCategoryDataModel.fromJson(Map<String, dynamic> json){
    return RecipeCategoryDataModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? "",
      name: json["name"] ?? "",
      image: json["image"] ?? "",
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "name": name,
    "image": image,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $userId, $name, $image, $status, $createdAt, ";
  }
}
