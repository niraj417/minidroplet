class FeedSliderModel {
  FeedSliderModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<FeedSliderDataModel> data;

  factory FeedSliderModel.fromJson(Map<String, dynamic> json) {
    return FeedSliderModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data:
          json["data"] == null
              ? []
              : List<FeedSliderDataModel>.from(
                json["data"]!.map((x) => FeedSliderDataModel.fromJson(x)),
              ),
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

class FeedSliderDataModel {
  FeedSliderDataModel({
    required this.id,
    required this.type,
    required this.image,
    required this.status,
    this.openId,
    required this.link,
    required this.createdAt,
    required this.updatedAt,
    this.isBuy,
    this.title,
    this.thumbnail,
    this.price,
    this.mainPrice,
  });

  final int id;
  final String type;
  final String image;
  final int status;
  final String? openId;
  final String link;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? isBuy;
  final String? title;
  final String? thumbnail;
  final String? price;
  final String? mainPrice;

  factory FeedSliderDataModel.fromJson(Map<String, dynamic> json) {
    return FeedSliderDataModel(
      id: json["id"] ?? 0,
      type: json["type"] ?? "",
      image: json["image"] ?? "",
      status: json["status"] ?? 0,
      openId: json["open_id"],
      link: json["link"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      isBuy: json["is_buy"],
      title: json["title"],
      thumbnail: json["thumbnail"],
      price: json["price"],
      mainPrice: json["main_price"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "image": image,
    "status": status,
    "open_id": openId,
    "link": link,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "is_buy": isBuy,
    "title": title,
    "thumbnail": thumbnail,
    "price": price,
    "main_price": mainPrice,
  };

  @override
  String toString() {
    return "ID: $id, Type: $type, Image: $image, Status: $status, OpenId: $openId, Link: $link, CreatedAt: $createdAt, UpdatedAt: $updatedAt, IsBuy: $isBuy, Title: $title, Thumbnail: $thumbnail, Price: $price, MainPrice: $mainPrice";
  }
}
