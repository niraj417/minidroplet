class AllRecipeVideoModel {
  AllRecipeVideoModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<AllRecipeVideoDataModel> data;

  factory AllRecipeVideoModel.fromJson(Map<String, dynamic>? json) {
    final payload = json ?? const <String, dynamic>{};
    return AllRecipeVideoModel(
      status: _asInt(payload["status"]),
      message: _asString(payload["message"]),
      data: _asMapList(payload["data"])
          .map(AllRecipeVideoDataModel.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $message, $data";
  }
}

class AllRecipeVideoDataModel {
  AllRecipeVideoDataModel({
    required this.id,
    required this.userId,
    required this.series,
    required this.category,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.uploadVideo,
    required this.price,
    required this.status,
    required this.mainPrice,
    required this.priceType,
    required this.publishDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isBuy,
  });

  final int id;
  final String userId;
  final String series;
  final String category;
  final String title;
  final String thumbnail;
  final String description;
  final String uploadVideo;
  final String price;
  final String status;
  final String mainPrice;
  final String priceType;
  final String publishDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String isBuy;

  factory AllRecipeVideoDataModel.fromJson(Map<String, dynamic>? json) {
    final payload = json ?? const <String, dynamic>{};
    return AllRecipeVideoDataModel(
      id: _asInt(payload["id"]),
      userId: _asString(payload["user_id"]),
      series: _asString(payload["series"]),
      category: _asString(payload["category"]),
      title: _asString(payload["title"]),
      thumbnail: _asString(payload["thumbnail"]),
      description: _asString(payload["description"]),
      uploadVideo: _asString(payload["upload_video"]),
      price: _asString(payload["price"], fallback: "0"),
      status: _asString(payload["status"], fallback: "0"),
      mainPrice: _asString(payload["main_price"], fallback: "0"),
      priceType: _asString(payload["price_type"]),
      publishDate: _asString(payload["publish_date"]),
      createdAt: _asDateTime(payload["created_at"]),
      updatedAt: _asDateTime(payload["updated_at"]),
      isBuy: _asString(payload["is_buy"], fallback: "0"),
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
        "upload_video": uploadVideo,
        "price": price,
        "status": status,
        "main_price": mainPrice,
        "price_type": priceType,
        "publish_date": publishDate,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "is_buy": isBuy,
      };

  @override
  String toString() {
    return "$id, $userId, $series, $category, $title, $thumbnail, "
        "$description, $uploadVideo, $price, $status, $mainPrice, "
        "$priceType, $publishDate, $createdAt, $updatedAt, $isBuy";
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
