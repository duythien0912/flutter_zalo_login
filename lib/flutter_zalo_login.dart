library flutter_zalo_login;

import 'package:flutter/services.dart';

import 'models/zalo_login_result.dart';
import 'models/zalo_profile_model.dart';

export 'models/zalo_login_result.dart';
export 'models/zalo_profile_model.dart';

class ZaloLogin {
  static const channel = MethodChannel("flutter_zalo_login");

  Future init() async {
    final dynamic result = await channel.invokeMethod('init');
    return '$result';
  }

  Future<ZaloLoginResult> logIn() async {
    final Map<dynamic, dynamic> result = await channel.invokeMethod('logIn');

    return ZaloLoginResult.fromJson(result ?? {});
  }

  Future<void> logOut() async => channel.invokeMethod('logOut');

  Future<bool> isAuthenticated() async => await channel.invokeMethod('isAuthenticated') == 1;

  Future<ZaloProfileModel> getInfo() async {
    await channel.invokeMethod('getInfo');
    final Map<dynamic, dynamic> result = await channel.invokeMethod('getInfo');

    return ZaloProfileModel.fromJson(result ?? {});
  }
}
