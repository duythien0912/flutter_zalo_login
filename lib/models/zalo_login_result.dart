import 'dart:convert';

ZaloLoginResult zaloLoginResultFromJson(String str) =>
    ZaloLoginResult.fromJson(json.decode(str));

String zaloLoginResultToJson(ZaloLoginResult data) =>
    json.encode(data.toJson());

class ZaloLoginResult {
  String? oauthCode;
  String? errorMessage;
  int? errorCode;
  String? userId;

  ZaloLoginResult({
    this.oauthCode,
    this.errorMessage,
    this.errorCode,
    this.userId,
  });

  ZaloLoginResult copyWith({
    String? oauthCode,
    String? errorMessage,
    int? errorCode,
    String? userId,
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
