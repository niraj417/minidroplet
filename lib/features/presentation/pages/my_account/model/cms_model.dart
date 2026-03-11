class CmsModel {
  CmsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final CmsDataModel? data;

  factory CmsModel.fromJson(Map<String, dynamic> json){
    return CmsModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : CmsDataModel.fromJson(json["data"]),
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

class CmsDataModel {
  CmsDataModel({
    required this.privacyPolicy,
    required this.termsConditions,
    required this.contactUs,
    required this.aboutUs,
  });

  final AboutUs? privacyPolicy;
  final AboutUs? termsConditions;
  final AboutUs? contactUs;
  final AboutUs? aboutUs;

  factory CmsDataModel.fromJson(Map<String, dynamic> json){
    return CmsDataModel(
      privacyPolicy: json["privacy_policy"] == null ? null : AboutUs.fromJson(json["privacy_policy"]),
      termsConditions: json["terms_conditions"] == null ? null : AboutUs.fromJson(json["terms_conditions"]),
      contactUs: json["contact_us"] == null ? null : AboutUs.fromJson(json["contact_us"]),
      aboutUs: json["about_us"] == null ? null : AboutUs.fromJson(json["about_us"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "privacy_policy": privacyPolicy?.toJson(),
    "terms_conditions": termsConditions?.toJson(),
    "contact_us": contactUs?.toJson(),
    "about_us": aboutUs?.toJson(),
  };

  @override
  String toString(){
    return "$privacyPolicy, $termsConditions, $contactUs, $aboutUs, ";
  }
}

class AboutUs {
  AboutUs({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String type;
  final String title;
  final String description;
  final int status;
  final DateTime? createdAt;

  factory AboutUs.fromJson(Map<String, dynamic> json){
    return AboutUs(
      id: json["id"] ?? 0,
      type: json["type"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "title": title,
    "description": description,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $type, $title, $description, $status, $createdAt, ";
  }
}
