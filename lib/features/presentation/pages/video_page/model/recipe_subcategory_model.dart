
class RecipeSubcategoryModel {
  RecipeSubcategoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int? status;
  final String? message;
  final List<RecipeSubcategoryDataModel> data;

  factory RecipeSubcategoryModel.fromJson(Map<String, dynamic> json){
    return RecipeSubcategoryModel(
      status: json["status"],
      message: json["message"],
      data: json["data"] == null ? [] : List<RecipeSubcategoryDataModel>.from(json["data"]!.map((x) => RecipeSubcategoryDataModel.fromJson(x))),
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

class RecipeSubcategoryDataModel {
  RecipeSubcategoryDataModel({
    required this.id,
    required this.name,
  });

  final int? id;
  final String? name;

  factory RecipeSubcategoryDataModel.fromJson(Map<String, dynamic> json){
    return RecipeSubcategoryDataModel(
      id: json["id"],
      name: json["name"],
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
