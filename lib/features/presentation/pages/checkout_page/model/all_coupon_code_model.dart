class AllCouponCodeModel {
  AllCouponCodeModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<AllCouponCodeDataModel> data;

  factory AllCouponCodeModel.fromJson(Map<String, dynamic> json) {
    return AllCouponCodeModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? []
          : List<AllCouponCodeDataModel>.from(
          json["data"].map((x) => AllCouponCodeDataModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "Status: $status, Message: $message, Data: $data";
  }
}

class AllCouponCodeDataModel {
  AllCouponCodeDataModel({
    required this.id,
    required this.name,
    required this.discount,
    required this.status,
    required this.limit,
    required this.expiryDate,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String discount;
  final int status;
  final int limit;
  final DateTime? expiryDate;
  final DateTime? createdAt;

  factory AllCouponCodeDataModel.fromJson(Map<String, dynamic> json) {
    return AllCouponCodeDataModel(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      discount: json["discount"] ?? "",
      status: json["status"] ?? 0,
      limit: json["limit"] ?? 0,
      expiryDate: json["expiry_date"] != null
          ? DateTime.tryParse(json["expiry_date"])
          : null,
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "discount": discount,
    "status": status,
    "limit": limit,
    "expiry_date": expiryDate?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "ID: $id, Name: $name, Discount: $discount, Status: $status, Limit: $limit, ExpiryDate: $expiryDate, CreatedAt: $createdAt";
  }
}
