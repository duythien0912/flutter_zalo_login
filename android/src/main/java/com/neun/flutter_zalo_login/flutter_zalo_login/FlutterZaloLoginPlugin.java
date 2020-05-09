package com.neun.flutter_zalo_login.flutter_zalo_login;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.pm.PackageInfo;
import android.content.pm.Signature;
import android.util.Base64;
import android.util.Log;

import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.ArrayList;
import java.util.List;
import java.security.MessageDigest;

import com.zing.zalo.zalosdk.oauth.FeedData;
import com.zing.zalo.zalosdk.oauth.LoginVia;
import com.zing.zalo.zalosdk.oauth.OAuthCompleteListener;
import com.zing.zalo.zalosdk.oauth.OauthResponse;
import com.zing.zalo.zalosdk.oauth.OpenAPIService;
import com.zing.zalo.zalosdk.oauth.ValidateOAuthCodeCallback;
import com.zing.zalo.zalosdk.oauth.ZaloOpenAPICallback;
import com.zing.zalo.zalosdk.oauth.ZaloPluginCallback;
import com.zing.zalo.zalosdk.oauth.ZaloSDK;
import com.zing.zalo.zalosdk.oauth.ZaloSDKApplication;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * FlutterZaloLoginPlugin
 */
public class FlutterZaloLoginPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private static final String CHANNEL_NAME = "flutter_zalo_login";
    private static final String LOG_TAG = "ZaloLogin";

    private static Context _context;
    private static Activity _activity;

    private static ZaloSDK _mSDk = ZaloSDK.Instance;
    // private static ZaloOpenApi _mOpenAPI;
    private static Result _result;

    private static MethodChannel _channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        _context = flutterPluginBinding.getApplicationContext();

        _channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), CHANNEL_NAME);

        _channel.setMethodCallHandler(new FlutterZaloLoginPlugin());
    }

    public static void registerWith(Registrar registrar) {
        _context = registrar.context();
        _activity = registrar.activity();

        _channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        _channel.setMethodCallHandler(new FlutterZaloLoginPlugin());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        _result = result;
        if (call.method.equals("getPlatformVersion")) {
            _result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("init")) {
            String hashkey = getApplicationHashKey(_context);
            Log.v(LOG_TAG, "Please add this Hash Key to Zalo developers dashboard for Login");
            Log.v(LOG_TAG, hashkey);

            _result.success(hashkey);
        } else if (call.method.equals("logIn")) {
            _mSDk.unauthenticate();
            _mSDk.authenticate(_activity, LoginVia.APP_OR_WEB, new OAuthCompleteListener() {
                @Override
                public void onGetOAuthComplete(OauthResponse response) {
                    Map<String, Object> result = new HashMap<>();

                    result.put("userId", response.getuId());
                    result.put("oauthCode", response.getOauthCode());
                    result.put("errorCode", response.getErrorCode());
                    result.put("errorMessage", response.getErrorMessage());

                    _result.success(result);
                }

                @Override
                public void onAuthenError(int errorCode, String message) {
                    Map<String, Object> result = new HashMap<>();

                    result.put("errorCode", errorCode);
                    result.put("errorMessage", message);

                    _result.success(result);
                }
            });
        } else if (call.method.equals("isAuthenticated")) {
            _mSDk.isAuthenticate(new ValidateOAuthCodeCallback() {
                @Override
                public void onValidateComplete(boolean validated, int errorCode, long userId, String oauthCode) {
                    if(validated) {
                        _result.success(1);
                    } else {
                        _result.success(0);
                    }
                }
            });
        } else if (call.method.equals("logOut")) {
            _mSDk.unauthenticate();

            _result.success(1);
        } else if (call.method.equals("getInfo")) {
            final String[] fields = {"id", "birthday", "gender", "picture", "name"};
            _mSDk.getProfile(_activity, new ZaloOpenAPICallback() {
                @Override
                public void onResult(JSONObject response) {
                    try {
                        Map<String, Object> result = jsonToMap(response);

                        _result.success(result);
                    } catch (JSONException e) {

                        _result.success("Get Info error");
                    }
                }
            }, fields);
        } else {
            _result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivity() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        _activity = binding.getActivity();
    }

    public static String getApplicationHashKey(Context ctx) {
        try {
            PackageInfo info = ctx.getPackageManager().getPackageInfo(ctx.getPackageName(), PackageManager.GET_SIGNATURES);

            for (Signature signature : info.signatures) {
                MessageDigest md = MessageDigest.getInstance("SHA");
                md.update(signature.toByteArray());
                String sig = Base64.encodeToString(md.digest(), Base64.DEFAULT).trim();
                if (sig.trim().length() > 0) {
                    return sig;
                }
            }
            return "";
        } catch (Exception e) {
            return "";
        }
    }

    public static Map<String, Object> jsonToMap(JSONObject json) throws JSONException {
        Map<String, Object> retMap = new HashMap<String, Object>();

        if (json != JSONObject.NULL) {
            retMap = toMap(json);
        }

        return retMap;
    }

    public static Map<String, Object> toMap(JSONObject jsonObj) throws JSONException {
        Map<String, Object> map = new HashMap<String, Object>();
        Iterator<String> keys = jsonObj.keys();

        while (keys.hasNext()) {
            String key = keys.next();
            Object value = jsonObj.get(key);
            if (value instanceof JSONArray) {
                value = toList((JSONArray) value);
            } else if (value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            map.put(key, value);
        }

        return map;
    }

    public static List<Object> toList(JSONArray array) throws JSONException {
        List<Object> list = new ArrayList<Object>();

        for (int i = 0; i < array.length(); i++) {
            Object value = array.get(i);
            if (value instanceof JSONArray) {
                value = toList((JSONArray) value);
            } else if (value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            list.add(value);
        }

        return list;
    }

}
