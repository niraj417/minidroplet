class AllEbookModel {
  AllEbookModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<AllEbookDataModel> data;

  factory AllEbookModel.fromJson(Map<String, dynamic> json) {
    return AllEbookModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? []
          : List<AllEbookDataModel>.from(
          json["data"]!.map((x) => AllEbookDataModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$status, $message, $data, ";
  }
}

class AllEbookDataModel {
  AllEbookDataModel({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.adminName,
    required this.isBuy,
    required this.priceType,
  });

  final int id;
  final String title;
  final String coverImage;
  final String adminName;
  final String isBuy;
  final String priceType; // New field

  factory AllEbookDataModel.fromJson(Map<String, dynamic> json) {
    return AllEbookDataModel(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      coverImage: json["cover_image"] ?? "",
      adminName: json["admin_name"] ?? "",
      isBuy: json["is_buy"] ?? "",
      priceType: json["price_type"] ?? "", // New field parsing
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "cover_image": coverImage,
    "admin_name": adminName,
    "is_buy": isBuy,
    "price_type": priceType, // New field serialization
  };

  @override
  String toString() {
    return "$id, $title, $coverImage, $adminName, $isBuy, $priceType";
  }
}
