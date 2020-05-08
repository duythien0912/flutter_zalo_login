library flutter_zalo_login;

import 'package:flutter/services.dart';
import 'dart:convert';

class ZaloLogin {
  static const channel = MethodChannel("flutter_zalo_login");

  Future init() async {
    final dynamic result = await channel.invokeMethod('init');

    channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case 'loginSuccess':
          print("loginSuccess");
          print(call.arguments);
          return null;
        case 'loginError':
          print("loginError");
          print(call.arguments);
          return null;
        case 'getUserSuccess':
          print("getUserSuccess");
          print(call.arguments);
          return null;
        case 'getUserError':
          print("getUserError");
          print(call.arguments);
          return null;
        default:
          throw new MissingPluginException();
      }
    });

    return result;
  }

  Future<ZaloLoginResult> logIn() async {
    final Map<dynamic, dynamic> result = await channel.invokeMethod('logIn');

    return ZaloLoginResult.fromJson(result);
  }

  Future<void> logOut() async => channel.invokeMethod('logOut');

  Future<ZaloProfileModel> getInfo() async {
    final Map<dynamic, dynamic> result = await channel.invokeMethod('getInfo');

    return ZaloProfileModel.fromJson(result);
  }
}

ZaloLoginResult authorPostsFromJson(String str) =>
    ZaloLoginResult.fromJson(json.decode(str));

String authorPostsToJson(ZaloLoginResult data) => json.encode(data.toJson());

class ZaloLoginResult {
  String oauthCode;
  String errorMessage;
  int errorCode;
  String userId;

  ZaloLoginResult({
    this.oauthCode,
    this.errorMessage,
    this.errorCode,
    this.userId,
  });

  ZaloLoginResult copyWith({
    String oauthCode,
    String errorMessage,
    int errorCode,
    String userId,
  }) =>
      ZaloLoginResult(
        oauthCode: oauthCode ?? this.oauthCode,
        errorMessage: errorMessage ?? this.errorMessage,
        errorCode: errorCode ?? this.errorCode,
        userId: userId ?? this.userId,
      );

  factory ZaloLoginResult.fromJson(Map<dynamic, dynamic> json) =>
      ZaloLoginResult(
        oauthCode: json["oauthCode"] == null ? null : json["oauthCode"],
        errorMessage:
            json["errorMessage"] == null ? null : json["errorMessage"],
        errorCode: json["errorCode"] == null ? null : json["errorCode"],
        userId: json["userId"] == null ? null : json["userId"].toString(),
      );

  Map<dynamic, dynamic> toJson() => {
        "oauthCode": oauthCode == null ? null : oauthCode,
        "errorMessage": errorMessage == null ? null : errorMessage,
        "errorCode": errorCode == null ? null : errorCode,
        "userId": userId == null ? null : userId,
      };
}

ZaloProfileModel zaloProfileModelFromJson(String str) =>
    ZaloProfileModel.fromJson(json.decode(str));

String zaloProfileModelToJson(ZaloProfileModel data) =>
    json.encode(data.toJson());

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

  factory ZaloProfileModel.fromJson(Map<dynamic, dynamic> json) =>
      ZaloProfileModel(
        birthday: json["birthday"] == null ? null : json["birthday"],
        gender: json["gender"] == null ? null : json["gender"],
        name: json["name"] == null ? null : json["name"],
        id: json["id"] == null ? null : json["id"].toString(),
        picture:
            json["picture"] == null ? null : Picture.fromJson(json["picture"]),
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
