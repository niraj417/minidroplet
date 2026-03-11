class RecipeCouponModel {
  RecipeCouponModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final RecipeCouponDataModel? data;

  factory RecipeCouponModel.fromJson(Map<String, dynamic> json){
    return RecipeCouponModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : RecipeCouponDataModel.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };

  @override
  String toString(){
    return "$status, $message, $data, ";
  }
}

class RecipeCouponDataModel {
  RecipeCouponDataModel({
    required this.id,
    required this.orderId,
    required this.videoId,
    required this.userId,
    required this.amount,
    required this.transactionId,
    required this.actualAmount,
    required this.couponId,
    required this.cuponCode,
    required this.discountPercentage,
    required this.discountAmount,
    required this.status,
    required this.response,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String orderId;
  final String videoId;
  final String userId;
  final String amount;
  final dynamic transactionId;
  final String actualAmount;
  final String couponId;
  final String cuponCode;
  final String discountPercentage;
  final String discountAmount;
  final String status;
  final dynamic response;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RecipeCouponDataModel.fromJson(Map<String, dynamic> json){
    return RecipeCouponDataModel(
      id: json["id"] ?? 0,
      orderId: json["order_id"] ?? "",
      videoId: json["video_id"] ?? "",
      userId: json["user_id"] ?? "",
      amount: json["amount"] ?? "",
      transactionId: json["transaction_id"],
      actualAmount: json["actual_amount"] ?? "",
      couponId: json["coupon_id"] ?? "",
      cuponCode: json["cupon_code"] ?? "",
      discountPercentage: json["discount_percentage"] ?? "",
      discountAmount: json["discount_amount"] ?? "",
      status: json["status"] ?? "",
      response: json["response"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "video_id": videoId,
    "user_id": userId,
    "amount": amount,
    "transaction_id": transactionId,
    "actual_amount": actualAmount,
    "coupon_id": couponId,
    "cupon_code": cuponCode,
    "discount_percentage": discountPercentage,
    "discount_amount": discountAmount,
    "status": status,
    "response": response,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $orderId, $videoId, $userId, $amount, $transactionId, $actualAmount, $couponId, $cuponCode, $discountPercentage, $discountAmount, $status, $response, $createdAt, $updatedAt, ";
  }
}
