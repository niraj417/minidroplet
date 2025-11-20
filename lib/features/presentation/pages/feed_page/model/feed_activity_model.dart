class FeedActivityModel {
  FeedActivityModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int? status;
  final String? message;
  final List<FeedActivityDataModel> data;

  factory FeedActivityModel.fromJson(Map<String, dynamic> json){
    return FeedActivityModel(
      status: json["status"],
      message: json["message"],
      data: json["data"] == null ? [] : List<FeedActivityDataModel>.from(json["data"]!.map((x) => FeedActivityDataModel.fromJson(x))),
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

class FeedActivityDataModel {
  FeedActivityDataModel({
    required this.id,
    required this.type,
    required this.name,
    required this.image,
    required this.dataId,
    required this.status,
    required this.createdAt,
    required this.isBuy,  
  });

  final int? id;
  final String? type;
  final String? name;
  final dynamic image;
  final String? dataId;
  final int? status;
  final DateTime? createdAt;
  final String? isBuy;  

  factory FeedActivityDataModel.fromJson(Map<String, dynamic> json) {
    return FeedActivityDataModel(
      id: json["id"],
      type: json["type"],
      name: json["name"],
      image: json["image"],
      dataId: json["data_id"],
      status: json["status"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      isBuy: json["is_buy"],  
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "name": name,
    "image": image,
    "data_id": dataId,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "is_buy": isBuy,  
  };

  @override
  String toString() {
    return "$id, $type, $name, $image, $status, $createdAt, $dataId, $isBuy";  
  }
}
