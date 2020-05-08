# flutter_zalo_login

Demonstrates how to use the flutter_zalo_login plugin.

## Setup Android

```
minSdkVersion 18
```

Add to /android/app/src/main/AndroidManifest.xml
```xml
    <application
        android:name=".FlutterApplication" 
        android:label="zaa_example"
        android:icon="@mipmap/ic_launcher">
        
        <!-- ... -->
        <!-- ... -->

        <!-- add new line -->
        <meta-data
            android:name="com.zing.zalo.zalosdk.appID"
            android:value="@string/appID" />
        <activity
                android:name="com.zing.zalo.zalosdk.oauth.BrowserLoginActivity">
            <intent-filter>
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="android.intent.category.BROWSABLE"/>
                <data android:scheme="@string/zalosdk_login_protocol_schema"/>
            </intent-filter>
        </activity>
    </application>
```


Create new file /android/app/src/main/res/values/string.xml
```xml
<resources>
    <string name="app_name">zaa2</string>
    <string name="appID">2025844058438788512</string>
    <string name="zalosdk_app_id">2025844058438788512</string>
    <string name="zalosdk_login_protocol_schema">zalo-2025844058438788512</string>
</resources>
```

Create new file /android/app/src/main/java/com/neun/flutter_zalo_login/flutter_zalo_login_example/FlutterApplication.java

```java
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
```

Edit file MainActivity

If kotlin
```kotlin
    import com.zing.zalo.zalosdk.oauth.ZaloSDK;

    override fun onActivityResult(requestCode:Int, resultCode:Int, data:Intent) {
        super.onActivityResult(requestCode, resultCode, data)
        ZaloSDK.Instance.onActivityResult(this, requestCode, resultCode, data)
    }
```

If java
```java
    import com.zing.zalo.zalosdk.oauth.ZaloSDK;

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
      super.onActivityResult(requestCode, resultCode, data);
      ZaloSDK.Instance.onActivityResult(this, requestCode, resultCode, data);
    }
```


## Setup IOS

Add to /ios/Runner/Info.plist

```.plist
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLName</key>
			<string>zalo</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>zalo-2025844058438788512</string>
			</array>
		</dict>
	</array>
	<key>ZaloAppID</key>
	<string>2025844058438788512</string>
	<key>ZaloAppKey</key>
	<string>bhyoUXT7H8043XM2eXJ1</string>
```