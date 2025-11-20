class LoginDataModel {
  LoginDataModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final Data? data;

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };

  @override
  String toString() {
    return "$status, $message, $data";
  }
}

class Data {
  Data({
    required this.id,
    required this.name,
    required this.email,
    required this.location,
    required this.idLink,
    required this.aboutUs,
    required this.profile,
    required this.emailVerifiedAt,
    required this.otpVerify,
    required this.mobile,
    required this.online,
    required this.dob,
    required this.gender,
    required this.country,
    required this.state,
    required this.city,
    required this.district,
    required this.pincode,
    required this.hometown,
    required this.address,
    required this.parentsGender,
    required this.parentName,
    required this.babyBorned,
    required this.babyAge,
    required this.otp,
    required this.loginStatus,
    required this.apiToken,
    required this.createdAt,
    required this.deviceName,
    required this.deviceToken,
    required this.updatedAt,
    required this.deleatedAt,
    required this.profileCompletion,
  });

  final int id;
  final String name;
  final String email;
  final dynamic location;
  final dynamic idLink;
  final dynamic aboutUs;
  final String profile;
  final dynamic emailVerifiedAt;
  final int otpVerify;
  final String mobile;
  final int online;
  final dynamic dob;
  final dynamic gender;
  final dynamic country;
  final dynamic state;
  final dynamic city;
  final dynamic district;
  final dynamic pincode;
  final dynamic hometown;
  final dynamic address;
  final dynamic parentsGender;
  final dynamic parentName;
  final dynamic babyBorned;
  final dynamic babyAge;
  final int otp;
  final int loginStatus;
  final String apiToken;
  final DateTime? createdAt;
  final String deviceName;
  final String deviceToken;
  final DateTime? updatedAt;
  final int deleatedAt;
  final int profileCompletion;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      location: json["location"],
      idLink: json["id_link"],
      aboutUs: json["about_us"],
      profile: json["profile"] ?? "",
      emailVerifiedAt: json["email_verified_at"],
      otpVerify: json["otp_verify"] ?? 0,
      mobile: json["mobile"] ?? "",
      online: json["online"] ?? 0,
      dob: json["dob"],
      gender: json["gender"],
      country: json["country"],
      state: json["state"],
      city: json["city"],
      district: json["district"],
      pincode: json["pincode"],
      hometown: json["hometown"],
      address: json["address"],
      parentsGender: json["parents_gender"],
      parentName: json["parent_name"],
      babyBorned: json["baby_borned"],
      babyAge: json["baby_age"],
      otp: json["otp"] ?? 0,
      loginStatus: json["login_status"] ?? 0,
      apiToken: json["api_token"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      deviceName: json["device_name"] ?? "",
      deviceToken: json["device_token"] ?? "",
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      deleatedAt: json["deleated_at"] ?? 0,
      profileCompletion: json["profile_completion"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "location": location,
    "id_link": idLink,
    "about_us": aboutUs,
    "profile": profile,
    "email_verified_at": emailVerifiedAt,
    "otp_verify": otpVerify,
    "mobile": mobile,
    "online": online,
    "dob": dob,
    "gender": gender,
    "country": country,
    "state": state,
    "city": city,
    "district": district,
    "pincode": pincode,
    "hometown": hometown,
    "address": address,
    "parents_gender": parentsGender,
    "parent_name": parentName,
    "baby_borned": babyBorned,
    "baby_age": babyAge,
    "otp": otp,
    "login_status": loginStatus,
    "api_token": apiToken,
    "created_at": createdAt?.toIso8601String(),
    "device_name": deviceName,
    "device_token": deviceToken,
    "updated_at": updatedAt?.toIso8601String(),
    "deleated_at": deleatedAt,
    "profile_completion": profileCompletion,
  };

  @override
  String toString() {
    return "$id, $name, $email, $location, $idLink, $aboutUs, $profile, $emailVerifiedAt, $otpVerify, $mobile, $online, $dob, $gender, $country, $state, $city, $district, $pincode, $hometown, $address, $parentsGender, $parentName, $babyBorned, $babyAge, $otp, $loginStatus, $apiToken, $createdAt, $deviceName, $deviceToken, $updatedAt, $deleatedAt $profileCompletion";
  }
}
