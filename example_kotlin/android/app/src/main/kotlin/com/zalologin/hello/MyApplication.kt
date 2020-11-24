package com.zalologin.hello

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.pathprovider.PathProviderPlugin
import com.zing.zalo.zalosdk.oauth.ZaloSDKApplication;

class MyApplication : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
  override fun onCreate() {
    super.onCreate();
    ZaloSDKApplication.wrap(this);
  }
  override fun registerWith(registry: PluginRegistry) {
    if (!registry!!.hasPlugin("com.neun.flutter_zalo_login.flutter_zalo_login")) {
        PathProviderPlugin.registerWith(registry!!.registrarFor("com.neun.flutter_zalo_login.flutter_zalo_login"))
    }
  }
}
