class NotificationModel {
  NotificationModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<NotificationDataModel> data;

  factory NotificationModel.fromJson(Map<String, dynamic> json){
    return NotificationModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? [] : List<NotificationDataModel>.from(json["data"]!.map((x) => NotificationDataModel.fromJson(x))),
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

class NotificationDataModel {
  NotificationDataModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.notificationId,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final String userId;
  final String type;
  final String notificationId;
  final String title;
  final String message;
  final DateTime? createdAt;

  factory NotificationDataModel.fromJson(Map<String, dynamic> json){
    return NotificationDataModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? "",
      type: json["type"] ?? "",
      notificationId: json["notification_id"] ?? "",
      title: json["title"] ?? "",
      message: json["message"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "type": type,
    "notification_id": notificationId,
    "title": title,
    "message": message,
    "created_at": createdAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $userId, $type, $notificationId, $title, $message, $createdAt, ";
  }
}
