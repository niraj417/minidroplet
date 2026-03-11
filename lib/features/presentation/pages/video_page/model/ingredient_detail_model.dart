// Create a file at models/ingredient_detail_model.dart with the model classes

// Paste your model classes here:
class IngredientDetailModel {
  IngredientDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final IngredientDetailDataModel? data;

  factory IngredientDetailModel.fromJson(Map<String, dynamic> json){
    return IngredientDetailModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : IngredientDetailDataModel.fromJson(json["data"]),
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

class IngredientDetailDataModel {
  IngredientDetailDataModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.name,
    required this.image,
    required this.status,
    required this.description,
    required this.description1,
    required this.description2,
    required this.description3,
    required this.description4,
    required this.description5,
    required this.createdAt,
    required this.ingrediantsSteps,
  });

  final int id;
  final String userId;
  final String category;
  final String name;
  final String image;
  final int status;
  final String description;
  final String description1;
  final String description2;
  final String description3;
  final String description4;
  final String description5;
  final DateTime? createdAt;
  final List<IngrediantsStep> ingrediantsSteps;

  factory IngredientDetailDataModel.fromJson(Map<String, dynamic> json){
    return IngredientDetailDataModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? "",
      category: json["category"] ?? "",
      name: json["name"] ?? "",
      image: json["image"] ?? "",
      status: json["status"] ?? 0,
      description: json["description"] ?? "",
      description1: json["description_1"] ?? "",
      description2: json["description_2"] ?? "",
      description3: json["description_3"] ?? "",
      description4: json["description_4"] ?? "",
      description5: json["description_5"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      ingrediantsSteps: json["ingrediants_steps"] == null ? [] : List<IngrediantsStep>.from(json["ingrediants_steps"]!.map((x) => IngrediantsStep.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "category": category,
    "name": name,
    "image": image,
    "status": status,
    "description": description,
    "description_1": description1,
    "description_2": description2,
    "description_3": description3,
    "description_4": description4,
    "description_5": description5,
    "created_at": createdAt?.toIso8601String(),
    "ingrediants_steps": ingrediantsSteps.map((x) => x.toJson()).toList(),
  };

  @override
  String toString(){
    return "$id, $userId, $category, $name, $image, $status, $description, $description1, $description2, $description3, $description4, $description5, $createdAt, $ingrediantsSteps, ";
  }
}

class IngrediantsStep {
  IngrediantsStep({
    required this.id,
    required this.ingrediantId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  final int id;
  final String ingrediantId;
  final String title;
  final String description;
  final DateTime? createdAt;

  factory IngrediantsStep.fromJson(Map<String, dynamic> json){
    return IngrediantsStep(
      id: json["id"] ?? 0,
      ingrediantId: json["ingrediant_id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "ingrediant_id": ingrediantId,
    "title": title,
    "description": description,
    "created_at": createdAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $ingrediantId, $title, $description, $createdAt, ";
  }
}