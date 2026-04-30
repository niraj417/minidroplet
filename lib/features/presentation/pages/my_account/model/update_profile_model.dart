class UpdateProfileModel {
  UpdateProfileModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final UpdateProfileDataModel? data;

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : UpdateProfileDataModel.fromJson(json["data"]),
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

class UpdateProfileDataModel {
  UpdateProfileDataModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.location,
    this.idLink,
    required this.aboutUs,
    required this.profile,
    this.emailVerifiedAt,
    required this.otpVerify,
    required this.mobile,
    required this.online,
    this.dob,
    this.gender,
    this.country,
    this.state,
    this.city,
    this.district,
    this.pincode,
    this.hometown,
    required this.address,
    this.parentsGender,
    this.parentName,
    this.babyBorned,
    this.babyAge,
    required this.otp,
    required this.rememberToken,
    required this.loginStatus,
    required this.apiToken,
    this.createdAt,
    required this.deviceName,
    required this.deviceToken,
    this.updatedAt,
    required this.deleatedAt,
    required this.profileCompletion,
  });

  final int id;
  final String name;
  final String email;
  final String password;
  final dynamic location;
  final dynamic idLink;
  final String aboutUs;
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
  final String address;
  final String? parentsGender;
  final String? parentName;
  final String? babyBorned;
  final String? babyAge;
  final int otp;
  final String rememberToken;
  final int loginStatus;
  final String apiToken;
  final DateTime? createdAt;
  final String deviceName;
  final String deviceToken;
  final DateTime? updatedAt;
  final int deleatedAt;
  final int profileCompletion;

  factory UpdateProfileDataModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileDataModel(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      password: json["password"] ?? "",
      location: json["location"],
      idLink: json["id_link"],
      aboutUs: json["about_us"] ?? "",
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
      address: json["address"] ?? "",
      parentsGender: json["parents_gender"],
      parentName: json["parent_name"],
      babyBorned: json["baby_borned"],
      babyAge: json["baby_age"],
      otp: json["otp"] ?? 0,
      rememberToken: json["remember_token"] ?? "",
      loginStatus: json["login_status"] ?? 0,
      apiToken: json["api_token"] ?? "",
      createdAt: json["created_at"] != null ? DateTime.tryParse(json["created_at"]) : null,
      deviceName: json["device_name"] ?? "",
      deviceToken: json["device_token"] ?? "",
      updatedAt: json["updated_at"] != null ? DateTime.tryParse(json["updated_at"]) : null,
      deleatedAt: json["deleated_at"] ?? 0,
      profileCompletion: json["profile_completion"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "password": password,
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
    "remember_token": rememberToken,
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
    return "$id, $name, $email, $password, $location, $idLink, $aboutUs, $profile, $emailVerifiedAt, $otpVerify, $mobile, $online, $dob, $gender, $country, $state, $city, $district, $pincode, $hometown, $address, $parentsGender, $parentName, $babyBorned, $babyAge, $otp, $rememberToken, $loginStatus, $apiToken, $createdAt, $deviceName, $deviceToken, $updatedAt, $deleatedAt $profileCompletion";
  }
}
