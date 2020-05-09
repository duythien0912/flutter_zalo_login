<h1 align="center">
  <div>
    <img src="https://raw.githubusercontent.com/duythien0912/flutter_zalo_login/master/flutter.jpeg" height="150" />
    <img src="https://raw.githubusercontent.com/duythien0912/flutter_zalo_login/master/zalo.svg" width="150" height="150" />
  </div>

  <div>
  
  Flutter Zalo Login 
  </div>
</h1>


<div align="center">
  <img width="320px" src="https://raw.githubusercontent.com/duythien0912/flutter_zalo_login/master/login_zalo_ios.gif" style="margin-right: 16px;" />
  <img width="320px" src="https://raw.githubusercontent.com/duythien0912/flutter_zalo_login/master/login_zalo_android.gif" />
</div>


# Installation
Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  flutter_zalo_login:
```

# Usage

Call init function on initState
```dart
ZaloLogin().init();
```

Login function return type https://pub.dev/documentation/flutter_zalo_login/latest/flutter_zalo_login/ZaloLoginResult-class.html
| Properties        | Type      
| ------------- |:-------------:|
| userId      | String |
| errorCode      | int |
| errorMessage      | String |
| oauthCode      | String |
```dart
ZaloLoginResult res = await ZaloLogin().logIn();
```

Check is authenticated
```dart
bool isAuthenticated = await ZaloLogin().isAuthenticated();
```

Logout
```dart
await ZaloLogin().logOut();
```

Get info from user return type https://pub.dev/documentation/flutter_zalo_login/latest/flutter_zalo_login/ZaloProfileModel-class.html
| Properties        | Type      
| ------------- |:-------------:|
| id      | String |
| name      | String |
| birthday      | String |
| gender      | String |
| picture.data.url      | String |

```dart
ZaloProfileModel info = await ZaloLogin().getInfo();
```


# Setup Zalo developers

Go to this page: https://developers.zalo.me/app

Login and create new app

It will have 2 value

ID: `<YOUR_ZALO_APP_ID>`

Secret Key: `<YOUR_ZALO_APP_SECRET_KEY>`

> # Note

> ## Android will need your `<YOUR_ZALO_APP_ID>` and `Hash Key`
> Hash Key will be show on console log when you run `ZaloLogin().init();` like below

```bash
V/ZaloLogin(28268): Please add this Hash Key to Zalo developers dashboard for Login
V/ZaloLogin(28268): tUDfvw+YYoyciFpRM4WIRYeqtRI=
```

> ## IOS will need both `<YOUR_ZALO_APP_ID>` and `<YOUR_ZALO_APP_SECRET_KEY>`

After that config your BundleID, Package name, Hash key on zalo develop config

<div align="center">
  <img src="https://raw.githubusercontent.com/duythien0912/flutter_zalo_login/master/config.png" />
</div>


# IOS

Open `/ios/Runner/Info.plist` and add the following:

```
    ...
    <key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLName</key>
			<string>zalo</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>zalo-<YOUR_ZALO_APP_ID></string>
			</array>
		</dict>
	</array>
	<key>ZaloAppID</key>
	<string><YOUR_ZALO_APP_ID></string>
	<key>ZaloAppKey</key>
	<string><YOUR_ZALO_APP_SECRET_KEY></string>
    ...
```

After that, open `ios/Runner/AppDelegate.swift` and add code below: 

```swift
    ...
    override func application(
        _ application: UIApplication,
        open url: URL,
        sourceApplication: String?,
        annotation: Any
    ) -> Bool {
        return ZDKApplicationDelegate.sharedInstance().application(application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation
        )
    }

    @available(iOS 9.0, *)
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        return ZDKApplicationDelegate
            .sharedInstance()
            .application(app,
                            open: url as URL?,
                            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?,
                            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return false
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

```

If your project using Object-c add code to follow file `ios/Runner/AppDelegate.m`:
```objc

...

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
  return [[ZDKApplicationDelegate sharedInstance] application:application openURL:url options:options];
}
```

# Android
### Note this plugin need config

```
minSdkVersion 18
```

### Open to `/android/app/src/main/AndroidManifest.xml` and add config
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

### After that create new file `/android/app/src/main/res/values/string.xml`
```xml
<resources>
    <string name="app_name">zaa2</string>
    <string name="appID"><YOUR_ZALO_APP_ID></string>
    <string name="zalosdk_app_id"><YOUR_ZALO_APP_ID></string>
    <string name="zalosdk_login_protocol_schema">zalo-<YOUR_ZALO_APP_ID></string>
</resources>
```

### Create new file `/android/app/src/main/java/com/neun/flutter_zalo_login/flutter_zalo_login_example/FlutterApplication.java`

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

After that edit file `MainActivity`

If `Kotlin`
```kotlin
    import com.zing.zalo.zalosdk.oauth.ZaloSDK;

    override fun onActivityResult(requestCode:Int, resultCode:Int, data:Intent) {
        super.onActivityResult(requestCode, resultCode, data)
        ZaloSDK.Instance.onActivityResult(this, requestCode, resultCode, data)
    }
```

If `Java`
```java
    import com.zing.zalo.zalosdk.oauth.ZaloSDK;

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
      super.onActivityResult(requestCode, resultCode, data);
      ZaloSDK.Instance.onActivityResult(this, requestCode, resultCode, data);
    }
```

