class EbookSliderModel {
  EbookSliderModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<EbookSliderDataModel> data;

  factory EbookSliderModel.fromJson(Map<String, dynamic> json) {
    return EbookSliderModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? []
          : List<EbookSliderDataModel>.from(json["data"]!.map((x) => EbookSliderDataModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "Status: $status, Message: $message, Data: ${data.length} items";
  }
}

class EbookSliderDataModel {
  EbookSliderDataModel({
    required this.id,
    required this.type,
    required this.image,
    required this.status,
    this.openId,
    this.link,
    required this.isBuy,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String type;
  final String image;
  final int status;
  final String? openId;
  final String? link;
  final String isBuy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory EbookSliderDataModel.fromJson(Map<String, dynamic> json) {
    return EbookSliderDataModel(
      id: json["id"] ?? 0,
      type: json["type"] ?? "",
      image: json["image"] ?? "",
      status: json["status"] ?? 0,
      openId: json["open_id"],
      link: json["link"],
      isBuy: json["is_buy"] ?? "0",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "image": image,
    "status": status,
    "open_id": openId,
    "link": link,
    "is_buy": isBuy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "ID: $id, Type: $type, Image: $image, Status: $status, OpenId: $openId, Link: $link, IsBuy: $isBuy, CreatedAt: $createdAt, UpdatedAt: $updatedAt";
  }
}
