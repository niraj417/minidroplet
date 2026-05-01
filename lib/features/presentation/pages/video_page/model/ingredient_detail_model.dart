class IngredientDetailModel {
  IngredientDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final IngredientDetailDataModel? data;

  factory IngredientDetailModel.fromJson(Map<String, dynamic>? json) {
    final payload = json ?? const <String, dynamic>{};
    return IngredientDetailModel(
      status: _asInt(payload["status"]),
      message: _asString(payload["message"]),
      data: payload["data"] is Map<String, dynamic>
          ? IngredientDetailDataModel.fromJson(
              payload["data"] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };

  @override
  String toString() {
    return "$status, $message, $data";
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

  factory IngredientDetailDataModel.fromJson(Map<String, dynamic>? json) {
    final payload = json ?? const <String, dynamic>{};
    return IngredientDetailDataModel(
      id: _asInt(payload["id"]),
      userId: _asString(payload["user_id"]),
      category: _asString(payload["category"]),
      name: _asString(payload["name"]),
      image: _asString(payload["image"]),
      status: _asInt(payload["status"]),
      description: _asString(payload["description"]),
      description1: _asString(payload["description_1"]),
      description2: _asString(payload["description_2"]),
      description3: _asString(payload["description_3"]),
      description4: _asString(payload["description_4"]),
      description5: _asString(payload["description_5"]),
      createdAt: _asDateTime(payload["created_at"]),
      ingrediantsSteps: _asMapList(payload["ingrediants_steps"])
          .map(IngrediantsStep.fromJson)
          .toList(growable: false),
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
  String toString() {
    return "$id, $userId, $category, $name, $image, $status, $description, "
        "$description1, $description2, $description3, $description4, "
        "$description5, $createdAt, $ingrediantsSteps";
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

  factory IngrediantsStep.fromJson(Map<String, dynamic>? json) {
    final payload = json ?? const <String, dynamic>{};
    return IngrediantsStep(
      id: _asInt(payload["id"]),
      ingrediantId: _asString(payload["ingrediant_id"]),
      title: _asString(payload["title"]),
      description: _asString(payload["description"]),
      createdAt: _asDateTime(payload["created_at"]),
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
  String toString() {
    return "$id, $ingrediantId, $title, $description, $createdAt";
  }
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? fallback;
  }
  return fallback;
}

String _asString(dynamic value, {String fallback = ""}) {
  if (value == null) {
    return fallback;
  }
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

DateTime? _asDateTime(dynamic value) {
  final raw = _asString(value);
  if (raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => item.map(
            (key, val) => MapEntry(key.toString(), val),
          ))
      .toList(growable: false);
}
