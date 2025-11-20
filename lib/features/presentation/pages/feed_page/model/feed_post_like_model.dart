class FeedPostLikeModel {
  FeedPostLikeModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final dynamic data;

  factory FeedPostLikeModel.fromJson(Map<String, dynamic> json){
    return FeedPostLikeModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"],
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data,
  };

  @override
  String toString(){
    return "$status, $message, $data, ";
  }
}
