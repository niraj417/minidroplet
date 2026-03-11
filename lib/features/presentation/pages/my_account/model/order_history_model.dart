class OrderHistoryModel {
  OrderHistoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int? status;
  final String? message;
  final OrderHistoryDataModel? data;

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      status: json["status"],
      message: json["message"],
      data: json["data"] == null ? null : OrderHistoryDataModel.fromJson(json["data"]),
    );
  }
}

class OrderHistoryDataModel {
  OrderHistoryDataModel({
    required this.ebook,
    required this.video,
    required this.playlist,
  });

  final List<Ebook> ebook;
  final List<Ebook> video;
  final List<Ebook> playlist;

  factory OrderHistoryDataModel.fromJson(Map<String, dynamic> json) {

    final ebookList = json["ebook"] == null
        ? <Ebook>[]
        : List<Ebook>.from(json["ebook"].map((x) => Ebook.fromJson(x)));

    final videoList = json["video"] == null
        ? <Ebook>[]
        : List<Ebook>.from(json["video"].map((x) => Ebook.fromJson(x)));

    final playlistList = json["playlist"] == null
        ? <Ebook>[]
        : List<Ebook>.from(json["playlist"].map((x) => Ebook.fromJson(x)));


    return OrderHistoryDataModel(
      ebook: ebookList,
      video: videoList,
      playlist: playlistList,
    );
  }
}

class Ebook {
  Ebook({
    required this.id,
    required this.orderId,
    required this.ebookId,
    required this.videoId,
    required this.playlistId,
    required this.amount,
    required this.transactionId,
    required this.createdAt,
    required this.title,
    required this.coverImage,
    required this.invoiceLink,
  });

  final int? id;
  final String? orderId;
  final String? ebookId;
  final String? videoId;
  final String? playlistId;
  final String? amount;
  final String? transactionId;
  final String? createdAt;
  final String? title;
  final String? coverImage;
  final String? invoiceLink;

  factory Ebook.fromJson(Map<String, dynamic> json) {
    print("Parsing single item: $json");
    return Ebook(
      id: json["id"],
      orderId: json["order_id"],
      ebookId: json["ebook_id"],
      videoId: json["video_id"],
      playlistId: json["playlist_id"],
      amount: json["amount"],
      transactionId: json["transaction_id"],
      createdAt: json["created_at"],
      title: json["title"],
      coverImage: json["cover_image"],
      invoiceLink: json["invoice_link"],
    );
  }
}