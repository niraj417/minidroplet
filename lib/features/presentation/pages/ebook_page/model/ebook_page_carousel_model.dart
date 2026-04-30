import 'package:tinydroplets/features/presentation/pages/ebook_page/model/all_ebook_model.dart';

class EbookPageCarouselModel {
  int? status;
  String? message;
  List<EbookPageCarouselData> data;

  EbookPageCarouselModel({
    this.status,
    this.message,
    required this.data,
  });

  factory EbookPageCarouselModel.fromJson(Map<String, dynamic> json) {
    return EbookPageCarouselModel(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => EbookPageCarouselData.fromJson(item))
          .toList(),
    );
  }
}

class EbookPageCarouselData {
  int carouselId;
  String carouselName;
  int categoryId;
  List<AllEbookDataModel> ebooks;

  EbookPageCarouselData({
    required this.carouselId,
    required this.carouselName,
    required this.categoryId,
    required this.ebooks,
  });

  factory EbookPageCarouselData.fromJson(Map<String, dynamic> json) {
    return EbookPageCarouselData(
      carouselId: json['carousel_id'] ?? 0,
      carouselName: json['carousel_name'] ?? '',
      categoryId: json['category_id'] ?? 0,
      ebooks: (json['ebooks'] as List)
          .map((item) => AllEbookDataModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carousel_id': carouselId,
      'carousel_name': carouselName,
      'category_id': categoryId,
      'ebooks': ebooks.map((ebook) => ebook.toJson()).toList(),
    };
  }
}