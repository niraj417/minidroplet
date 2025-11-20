enum ItemType { all, ebook, video, playlist }

class SavedItemModel {
  SavedItemModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<SavedItemDataModel> data;

  factory SavedItemModel.fromJson(Map<String, dynamic> json) {
    return SavedItemModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<SavedItemDataModel>.from(json["data"]!.map((x) => SavedItemDataModel.fromJson(x))),
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

class SavedItemDataModel {
  SavedItemDataModel({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.priceType,
    required this.isBuy,
    this.type = ItemType.all,  // Default value
  });

  final int id;
  final String title;
  final String coverImage;
  final String priceType;
  final String isBuy;
  final ItemType type;

  factory SavedItemDataModel.fromJson(Map<String, dynamic> json) {
    return SavedItemDataModel(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      coverImage: json["cover_image"] ?? "",
      priceType: json["price_type"] ?? "",
      isBuy: json["is_buy"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "cover_image": coverImage,
    "price_type": priceType,
    "is_buy": isBuy,
  };

  // Add copyWith method to help with type assignment
  SavedItemDataModel copyWith({
    int? id,
    String? title,
    String? coverImage,
    String? priceType,
    String? isBuy,
    ItemType? type,
  }) {
    return SavedItemDataModel(
      id: id ?? this.id,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      priceType: priceType ?? this.priceType,
      isBuy: isBuy ?? this.isBuy,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return "$id, $title, $coverImage, $priceType, $isBuy, $type";
  }
}