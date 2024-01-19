library flutter_zalo_login;

import 'package:flutter/services.dart';

import 'models/zalo_login_result.dart';
import 'models/zalo_profile_model.dart';

export 'models/zalo_login_result.dart';
export 'models/zalo_profile_model.dart';

/// [ZaloLogin] class for MethodChannel("flutter_zalo_login");
///
class ZaloLogin {
  static const channel = MethodChannel("flutter_zalo_login");

  /// You need to call function [init] first when using this plugins
  ///
  /// Ex: `ZaloLogin().init();`
  ///
  /// With Android it will show `hashcode` at console.log
  /// Add this `hashcode` to zalo login dashboard
  ///
  Future init() async {
    final dynamic result = await channel.invokeMethod('init');
    return '$result';
  }

  /// [logIn] will open WebOrApp Zalo login
  ///
  /// Ex: `ZaloLoginResult res = await ZaloLogin().logIn();`
  ///
  Future<ZaloLoginResult> logIn() async {
    final Map<dynamic, dynamic> result = await channel.invokeMethod('logIn');

    return ZaloLoginResult.fromJson(result);
  }

  /// [logOut] will clean Zalo session
  ///
  /// Ex: `await ZaloLogin().logOut();`
  ///
  Future<void> logOut() async => channel.invokeMethod('logOut');

  /// [isAuthenticated] will check is session out or not
  /// Ex: `bool isAuthenticated = await ZaloLogin().isAuthenticated();`
  Future<bool> isAuthenticated() async =>
      await channel.invokeMethod('isAuthenticated') == 1;

  /// [getInfo] will get account info from Zalo
  ///
  /// Ex: `ZaloProfileModel info = await ZaloLogin().getInfo();`
  ///
  /// More info: https://developers.zalo.me/docs/sdk/ios-sdk/open-api/lay-thong-tin-profile-post-490
  ///
  Future<ZaloProfileModel> getInfo() async {
    await channel.invokeMethod('getInfo');
    final Map<dynamic, dynamic> result = await channel.invokeMethod('getInfo');

    return ZaloProfileModel.fromJson(result);
  }

  /// TODO: Lấy danh sách bạn bè
  /// More info: https://developers.zalo.me/docs/sdk/android-sdk/open-api/lay-danh-sach-ban-be-post-437
  ///
  Future getFriendListUsedApp() async {}

  /// TODO: Gửi tin nhắn tới bạn bè
  /// More info: https://developers.zalo.me/docs/sdk/android-sdk/open-api/gui-tin-nhan-toi-ban-be-post-1205
  ///
  Future sendMsgToFriend() async {}

  /// TODO: Đăng bài viết
  /// More info: https://developers.zalo.me/docs/sdk/android-sdk/open-api/dang-bai-viet-post-1212
  ///
  Future postToWall() async {}

  /// TODO: Mời sử dụng ứng dụng
  /// More info: https://developers.zalo.me/docs/sdk/android-sdk/open-api/moi-su-dung-ung-dung-post-1218
  ///
  Future inviteFriendUseApp() async {}

  /// TODO: Gửi tin nhắn tới bạn bè
  /// More info: https://developers.zalo.me/docs/sdk/android-sdk/tuong-tac-voi-app-zalo/gui-tin-nhan-toi-ban-be-post-452
  Future shareMessage() async {}

  /// TODO: Đăng bài viết
  /// More info: https://developers.zalo.me/docs/sdk/android-sdk/tuong-tac-voi-app-zalo/dang-bai-viet-post-447
  ///
  Future shareFeed() async {}
}
