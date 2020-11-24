package com.zalologin.hello

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import com.zing.zalo.zalosdk.oauth.ZaloSDK

class MainActivity: FlutterActivity() {
    override fun onActivityResult(requestCode:Int, resultCode:Int, data:Intent) {
        super.onActivityResult(requestCode, resultCode, data)
        ZaloSDK.Instance.onActivityResult(this, requestCode, resultCode, data)
    }
}

