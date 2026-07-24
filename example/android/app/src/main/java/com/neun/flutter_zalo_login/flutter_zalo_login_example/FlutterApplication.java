package com.neun.flutter_zalo_login.flutter_zalo_login_example;

import android.app.Activity;
import android.app.Application;
import androidx.annotation.CallSuper;

import com.zing.zalo.zalosdk.oauth.ZaloSDKApplication;

public class FlutterApplication extends Application {
    @Override
    @CallSuper
    public void onCreate() {
        super.onCreate();
        // Initialize the Zalo SDK for the whole app process.
        ZaloSDKApplication.wrap(this);
    }

    private Activity mCurrentActivity = null;

    public Activity getCurrentActivity() {
        return mCurrentActivity;
    }

    public void setCurrentActivity(Activity mCurrentActivity) {
        this.mCurrentActivity = mCurrentActivity;
    }
}
