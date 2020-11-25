import 'dart:convert';

ZaloProfileModel zaloProfileModelFromJson(String str) => ZaloProfileModel.fromJson(json.decode(str));

String zaloProfileModelToJson(ZaloProfileModel data) => json.encode(data.toJson());

class ZaloProfileModel {
  String birthday;
  String gender;
  String name;
  String id;
  Picture picture;

  ZaloProfileModel({
    this.birthday,
    this.gender,
    this.name,
    this.id,
    this.picture,
  });

  ZaloProfileModel copyWith({
    String birthday,
    String gender,
    String name,
    String id,
    Picture picture,
  }) =>
      ZaloProfileModel(
        birthday: birthday ?? this.birthday,
        gender: gender ?? this.gender,
        name: name ?? this.name,
        id: id ?? this.id,
        picture: picture ?? this.picture,
      );

  factory ZaloProfileModel.fromJson(Map<dynamic, dynamic> json) => ZaloProfileModel(
        birthday: json["birthday"] == null ? null : json["birthday"],
        gender: json["gender"] == null ? null : json["gender"],
        name: json["name"] == null ? null : json["name"],
        id: json["id"] == null ? null : json["id"].toString(),
        picture: json["picture"] == null ? null : Picture.fromJson(json["picture"]),
      );

  Map<dynamic, dynamic> toJson() => {
        "birthday": birthday == null ? null : birthday,
        "gender": gender == null ? null : gender,
        "name": name == null ? null : name,
        "id": id == null ? null : id,
        "picture": picture == null ? null : picture.toJson(),
      };
}

class Picture {
  Data data;

  Picture({
    this.data,
  });

  Picture copyWith({
    Data data,
  }) =>
      Picture(
        data: data ?? this.data,
      );

  factory Picture.fromJson(Map<dynamic, dynamic> json) => Picture(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<dynamic, dynamic> toJson() => {
        "data": data == null ? null : data.toJson(),
      };
}

class Data {
  String url;

  Data({
    this.url,
  });

  Data copyWith({
    String url,
  }) =>
      Data(
        url: url ?? this.url,
      );

  factory Data.fromJson(Map<dynamic, dynamic> json) => Data(
        url: json["url"] == null ? null : json["url"],
      );

  Map<dynamic, dynamic> toJson() => {
        "url": url == null ? null : url,
      };
}
