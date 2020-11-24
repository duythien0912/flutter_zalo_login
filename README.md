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

# 1. Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  flutter_zalo_login:
```

# 2. Usage

Call init function on initState

```dart
ZaloLogin().init();
```

Login function return type https://pub.dev/documentation/flutter_zalo_login/latest/flutter_zalo_login/ZaloLoginResult-class.html

|  Properties  |  Type  |
| :----------: | :----: |
|    userId    | String |
|  errorCode   |  int   |
| errorMessage | String |
|  oauthCode   | String |

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

|    Properties    |  Type  |
| :--------------: | :----: |
|        id        | String |
|       name       | String |
|     birthday     | String |
|      gender      | String |
| picture.data.url | String |

```dart
ZaloProfileModel info = await ZaloLogin().getInfo();
```

# 3. Setup Zalo developers

To make this plugin working we need to have there key:

- YOUR_ZALO_APP_ID
- Android Hash Key ( only Android )
- YOUR_ZALO_APP_SECRET_KEY ( only IOS )

First go to this page: https://developers.zalo.me and create account/new app

It will have 2 value

ID: `YOUR_ZALO_APP_ID`

Secret Key: `YOUR_ZALO_APP_SECRET_KEY`

## 3.1 :warning: Note

> IOS will need `YOUR_ZALO_APP_ID` and `YOUR_ZALO_APP_SECRET_KEY`

> Android will need `YOUR_ZALO_APP_ID` and `Hash Key`

Android Hash Key will be show on console log when you run `ZaloLogin().init();` like below

```bash
V/ZaloLogin(28932): ---------------------------------------------------------------------------
V/ZaloLogin(28932): |     Please add this Hash Key to Zalo developers dashboard for Login     |
V/ZaloLogin(28932): tUDfvw+YYoyciFpRM4WIRYeqtRI= <-- YOUR ANDROID HASH CODE
V/ZaloLogin(28932): ---------------------------------------------------------------------------
```

## Config your BundleID, Package name, Hash key on zalo develop

<div align="center">
  <img src="https://raw.githubusercontent.com/duythien0912/flutter_zalo_login/master/config.png" />
</div>

# 4. Setup for Android Kotlin

### 4.1 This plugin need minSdkVersion > 18 for working

Open `android/app/build.gradle` and edit

```gradle
minSdkVersion 18 // or bigger
```

### 4.2 Open to `/android/app/src/main/AndroidManifest.xml` and add config on bottom under flutterEmbedding

```xml
    <application
        android:name=".FlutterApplication"
        android:label="zaa_example"
        android:icon="@mipmap/ic_launcher">

        <!-- ... -->
        <!-- ... -->

        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />

        <!-- ADD HERE -->
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
        <!-- ADD HERE -->

        <!-- ... -->

    </application>
```

### 4.3 After that create new `string.xml` file on folder `/android/app/src/main/res/values/string.xml`

and change YOUR_ZALO_APP_ID to your app_id

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">zaa2</string>
    <string name="appID">YOUR_ZALO_APP_ID</string>
    <string name="zalosdk_app_id">YOUR_ZALO_APP_ID</string>
    <string name="zalosdk_login_protocol_schema">zalo-YOUR_ZALO_APP_ID</string>
</resources>
```

### 4.4 Create either MyApplication.kt in the same directory as MainActivity.

:warning: Replace package your.app.name with your app's package name. If you don't know your package name, you can find it at the 1st line in MainActivity.kt.

```kt
package your.app.name;  // <-- replace this

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
```

### 4.5 Edit MainActivity.kt

:warning: Replace package your.app.name with your app's package name. If you don't know your package name, you can find it at the 1st line in MainActivity.kt.

```kt
package your.app.name;  // <-- replace this

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import com.zing.zalo.zalosdk.oauth.ZaloSDK // <-- Add this

class MainActivity: FlutterActivity() {
    override fun onActivityResult(requestCode:Int, resultCode:Int, data:Intent) {
        super.onActivityResult(requestCode, resultCode, data)
        ZaloSDK.Instance.onActivityResult(this, requestCode, resultCode, data) // <-- Add this
    }
}
```

### 4.6 Now edit AndroidManifest.xml and provide a reference to your custom Application class:

:warning: MyApplication, MainActivity should be the same with the code have been edit

```xml
    <application
        android:name=".MyApplication"
        ...
        <activity
            android:name=".MainActivity"
```

### 4.7 Run app and call

```dart
    String hashKey = await ZaloLogin().init();
```

if project have been setup success it will show like this:

```bash
V/ZaloLogin(28932): ---------------------------------------------------------------------------
V/ZaloLogin(28932): |     Please add this Hash Key to Zalo developers dashboard for Login     |
V/ZaloLogin(28932): tUDfvw+YYoyciFpRM4WIRYeqtRI= <-- YOUR ANDROID HASH CODE
V/ZaloLogin(28932): ---------------------------------------------------------------------------
```

### 4.8 Add HASH CODE to zalo android setup dashboard

# 5. Android JAVA

Same with `4. Setup for Android Kotlin`

Check folder `example/android` for java code version of
`MyApplication.kt` and `MainActivity.kt`

# 6. Setup for iOS

## 6.1 Open `/ios/Runner/Info.plist` and add the following:

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

## 6.2 After that, open `ios/Runner/AppDelegate.swift` and add code below:

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

## 6.3 If your project using Object-c add code to follow file `ios/Runner/AppDelegate.m`:

```objc

...

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
  return [[ZDKApplicationDelegate sharedInstance] application:application openURL:url options:options];
}
```
