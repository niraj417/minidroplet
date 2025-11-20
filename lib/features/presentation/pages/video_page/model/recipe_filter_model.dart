class RecipeFilterModel {
  RecipeFilterModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final RecipeFilterDataModel? data;

  factory RecipeFilterModel.fromJson(Map<String, dynamic> json){
    return RecipeFilterModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : RecipeFilterDataModel.fromJson(json["data"]),
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

class RecipeFilterDataModel {
  RecipeFilterDataModel({
    required this.category,
    required this.subCategory,
    required this.ingrediants,
    required this.ageGroup,
  });

  final List<Category> category;
  final List<SubCategory> subCategory;
  final List<Category> ingrediants;
  final List<AgeGroup> ageGroup;

  factory RecipeFilterDataModel.fromJson(Map<String, dynamic> json){
    return RecipeFilterDataModel(
      category: json["category"] == null ? [] : List<Category>.from(json["category"]!.map((x) => Category.fromJson(x))),
      subCategory: json["sub_category"] == null ? [] : List<SubCategory>.from(json["sub_category"]!.map((x) => SubCategory.fromJson(x))),
      ingrediants: json["ingrediants"] == null ? [] : List<Category>.from(json["ingrediants"]!.map((x) => Category.fromJson(x))),
      ageGroup: json["age_group"] == null ? [] : List<AgeGroup>.from(json["age_group"]!.map((x) => AgeGroup.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "category": category.map((x) => x?.toJson()).toList(),
    "sub_category": subCategory.map((x) => x?.toJson()).toList(),
    "ingrediants": ingrediants.map((x) => x?.toJson()).toList(),
    "age_group": ageGroup.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString(){
    return "$category, $subCategory, $ingrediants, $ageGroup, ";
  }
}

class AgeGroup {
  AgeGroup({
    required this.id,
    required this.ageGroup,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String ageGroup;
  final int status;
  final DateTime? createdAt;

  factory AgeGroup.fromJson(Map<String, dynamic> json){
    return AgeGroup(
      id: json["id"] ?? 0,
      ageGroup: json["age_group"] ?? "",
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "age_group": ageGroup,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $ageGroup, $status, $createdAt, ";
  }
}

class Category {
  Category({
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

  factory Category.fromJson(Map<String, dynamic> json){
    return Category(
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

class SubCategory {
  SubCategory({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory SubCategory.fromJson(Map<String, dynamic> json){
    return SubCategory(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };

  @override
  String toString(){
    return "$id, $name, ";
  }
}
