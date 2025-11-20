class FeedPostModel {
  FeedPostModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<FeedPostDataModel> data;

  FeedPostModel copyWith({
    int? status,
    String? message,
    List<FeedPostDataModel>? data,
  }) {
    return FeedPostModel(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  factory FeedPostModel.fromJson(Map<String, dynamic> json) {
    return FeedPostModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? []
          : List<FeedPostDataModel>.from(
          json["data"]!.map((x) => FeedPostDataModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString() {
    return "$status, $message, $data, ";
  }
}

class FeedPostDataModel {
  FeedPostDataModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.firstname,
    required this.lastname,
    required this.profile,
    required this.name,
    required this.postDate,
    required this.isLike,
    required this.likeCount,
    required this.commentCount,
    required this.shareLink,
    required this.allComments,
  });

  final int id;
  final int userId;
  final String title;
  final String description;
  final String type;
  final String image;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String firstname;
  final String lastname;
  final String profile;
  final String name;
  final String postDate;
  final String isLike;
  final int likeCount;
  final int commentCount;
  final int shareLink;
  final List<Comment> allComments;

  FeedPostDataModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? type,
    String? image,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstname,
    String? lastname,
    String? profile,
    String? name,
    String? postDate,
    String? isLike,
    int? likeCount,
    int? commentCount,
    int? shareLink,
    List<Comment>? allComments,
  }) {
    return FeedPostDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      image: image ?? this.image,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      profile: profile ?? this.profile,
      name: name ?? this.name,
      postDate: postDate ?? this.postDate,
      isLike: isLike ?? this.isLike,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareLink: shareLink ?? this.shareLink,
      allComments: allComments ?? this.allComments,
    );
  }

  factory FeedPostDataModel.fromJson(Map<String, dynamic> json) {
    // Debug the incoming JSON
    print('🔍 Parsing FeedPostDataModel JSON:');
    print('   - id: ${json["id"]} (type: ${json["id"]?.runtimeType})');
    print('   - is_like: ${json["is_like"]} (type: ${json["is_like"]?.runtimeType})');
    print('   - like_count: ${json["like_count"]} (type: ${json["like_count"]?.runtimeType})');
    print('   - comment_count: ${json["comment_count"]} (type: ${json["comment_count"]?.runtimeType})');

    return FeedPostDataModel(
      id: (json["id"] is int) ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
      userId: (json["user_id"] is int) ? json["user_id"] : int.tryParse(json["user_id"]?.toString() ?? '0') ?? 0,
      title: json["title"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "",
      image: json["image"]?.toString() ?? "",
      status: (json["status"] is int) ? json["status"] : int.tryParse(json["status"]?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"]?.toString() ?? ""),
      firstname: json["firstname"]?.toString() ?? "",
      lastname: json["lastname"]?.toString() ?? "",
      profile: json["profile"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      postDate: json["post_date"]?.toString() ?? "",

      // FIX: Handle is_like field - it might be coming as int (0/1) but you expect String
      isLike: (json["is_like"] is int)
          ? (json["is_like"] == 1 ? "1" : "0")
          : json["is_like"]?.toString() ?? "0",

      likeCount: (json["like_count"] is int)
          ? json["like_count"]
          : int.tryParse(json["like_count"]?.toString() ?? '0') ?? 0,

      commentCount: (json["comment_count"] is int)
          ? json["comment_count"]
          : int.tryParse(json["comment_count"]?.toString() ?? '0') ?? 0,

      shareLink: (json["share_link"] is int)
          ? json["share_link"]
          : int.tryParse(json["share_link"]?.toString() ?? '0') ?? 0,

      allComments: json["all_comments"] == null
          ? []
          : List<Comment>.from(
          json["all_comments"]!.map((x) => Comment.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "title": title,
    "description": description,
    "type": type,
    "image": image,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "firstname": firstname,
    "lastname": lastname,
    "profile": profile,
    "name": name,
    "post_date": postDate,
    "is_like": isLike,
    "like_count": likeCount,
    "comment_count": commentCount,
    "share_link": shareLink,
    "all_comments": allComments.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $userId, $title, $description,$type, $image, $status, $createdAt, $updatedAt, $firstname, $lastname, $profile, $name, $postDate, $isLike, $likeCount, $commentCount, $shareLink, $allComments, ";
  }
}

class Comment {
  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.replyId,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.profile,
    required this.commentDate,
    required this.replyComments,
  });

  final int id;
  final int postId;
  final int userId;
  final int replyId;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String name;
  final String profile;
  final String commentDate;
  final List<Comment> replyComments;

  Comment copyWith({
    int? id,
    int? postId,
    int? userId,
    int? replyId,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? profile,
    String? commentDate,
    List<Comment>? replyComments,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      replyId: replyId ?? this.replyId,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      profile: profile ?? this.profile,
      commentDate: commentDate ?? this.commentDate,
      replyComments: replyComments ?? this.replyComments,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing Comment JSON:');
    print('   - id: ${json["id"]} (type: ${json["id"]?.runtimeType})');
    print('   - user_id: ${json["user_id"]} (type: ${json["user_id"]?.runtimeType})');

    return Comment(
      id: (json["id"] is int) ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
      postId: (json["post_id"] is int) ? json["post_id"] : int.tryParse(json["post_id"]?.toString() ?? '0') ?? 0,
      userId: (json["user_id"] is int) ? json["user_id"] : int.tryParse(json["user_id"]?.toString() ?? '0') ?? 0,
      replyId: (json["reply_id"] is int) ? json["reply_id"] : int.tryParse(json["reply_id"]?.toString() ?? '0') ?? 0,
      comment: json["comment"]?.toString() ?? "",
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"]?.toString() ?? ""),
      name: json["name"]?.toString() ?? "",
      profile: json["profile"]?.toString() ?? "",
      commentDate: json["comment_date"]?.toString() ?? "",
      replyComments: json["reply_comments"] == null
          ? []
          : List<Comment>.from(
          json["reply_comments"]!.map((x) => Comment.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "post_id": postId,
    "user_id": userId,
    "reply_id": replyId,
    "comment": comment,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "name": name,
    "profile": profile,
    "comment_date": commentDate,
    "reply_comments": replyComments.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $postId, $userId, $replyId, $comment, $createdAt, $updatedAt, $name, $profile, $commentDate, $replyComments, ";
  }
}