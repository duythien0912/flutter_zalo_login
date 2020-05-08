package com.neun.flutter_zalo_login.flutter_zalo_login_example;

import android.app.Activity;
import android.app.Application;
import androidx.annotation.CallSuper;
import io.flutter.view.FlutterMain;

import com.zing.zalo.zalosdk.oauth.ZaloSDKApplication;

public class FlutterApplication extends Application {
    @Override
    @CallSuper
    public void onCreate() {
        super.onCreate();
        ZaloSDKApplication.wrap(this);
        FlutterMain.startInitialization(this);
    }

    private Activity mCurrentActivity = null;

    public Activity getCurrentActivity() {
        return mCurrentActivity;
    }

    public void setCurrentActivity(Activity mCurrentActivity) {
        this.mCurrentActivity = mCurrentActivity;
    }
}
