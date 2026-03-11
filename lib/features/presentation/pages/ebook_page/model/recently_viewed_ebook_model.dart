class RecentlyViewedEbookModel {
  RecentlyViewedEbookModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<RecentlyViewedEbookDataModel> data;

  factory RecentlyViewedEbookModel.fromJson(Map<String, dynamic> json){
    return RecentlyViewedEbookModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<RecentlyViewedEbookDataModel>.from(json["data"]!.map((x) => RecentlyViewedEbookDataModel.fromJson(x))),
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

class RecentlyViewedEbookDataModel {
  RecentlyViewedEbookDataModel({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.priceType,
    required this.adminName,
    required this.isBuy,
  });

  final int id;
  final String title;
  final String coverImage;
  final String priceType;
  final String adminName;
  final String isBuy;

  factory RecentlyViewedEbookDataModel.fromJson(Map<String, dynamic> json){
    return RecentlyViewedEbookDataModel(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      coverImage: json["cover_image"] ?? "",
      priceType: json["price_type"] ?? "",
      adminName: json["admin_name"] ?? "",
      isBuy: json["is_buy"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "cover_image": coverImage,
    "price_type": priceType,
    "admin_name": adminName,
    "is_buy": isBuy,
  };

  @override
  String toString(){
    return "$id, $title, $coverImage, $priceType, $adminName, $isBuy, ";
  }
}
