package com.neun.flutter_zalo_login.flutter_zalo_login;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
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
import java.security.SecureRandom;

import com.zing.zalo.zalosdk.oauth.LoginVia;
import com.zing.zalo.zalosdk.oauth.OAuthCompleteListener;
import com.zing.zalo.zalosdk.oauth.OauthResponse;
import com.zing.zalo.zalosdk.oauth.ZaloOpenAPICallback;
import com.zing.zalo.zalosdk.oauth.ZaloSDK;
import com.zing.zalo.zalosdk.oauth.model.ErrorResponse;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * FlutterZaloLoginPlugin
 *
 * Migrated to Zalo SDK v4 (me.zalo:sdk-*:4.2.0724). v4 uses the OAuth PKCE
 * flow: login sends a `code_challenge` derived from a locally-kept
 * `code_verifier`; the returned oauth code is later exchanged (with the same
 * verifier) for an access token used by the OpenAPI profile call.
 */
public class FlutterZaloLoginPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private static final String CHANNEL_NAME = "flutter_zalo_login";
    private static final String LOG_TAG = "ZaloLogin";

    private static Context _context;
    private static Activity _activity;

    private static final ZaloSDK _mSDk = ZaloSDK.Instance;
    private static Result _result;
    private static MethodChannel _channel;

    // PKCE state kept between logIn() and the later token exchange (getInfo).
    private static String _codeVerifier;
    private static String _oauthCode;
    // Local session flag. The v4 SDK's server-side isAuthenticate is unreliable
    // for the web/oauth-code flow, so we track success locally (mirrors iOS).
    private static boolean _authenticated = false;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        _context = flutterPluginBinding.getApplicationContext();
        _channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
        _channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        _result = result;
        switch (call.method) {
            case "getPlatformVersion":
                _result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "init":
                String hashkey = getApplicationHashKey(_context);
                Log.v(LOG_TAG, "---------------------------------------------------------------------------");
                Log.v(LOG_TAG, "|     Please add this Hash Key to Zalo developers dashboard for Login     |");
                Log.v(LOG_TAG, hashkey);
                Log.v(LOG_TAG, "---------------------------------------------------------------------------");
                _result.success(hashkey);
                break;
            case "logIn":
                logIn();
                break;
            case "isAuthenticated":
                _result.success(_authenticated ? 1 : 0);
                break;
            case "logOut":
                _mSDk.unauthenticate();
                _codeVerifier = null;
                _oauthCode = null;
                _authenticated = false;
                _result.success(1);
                break;
            case "getInfo":
                getInfo();
                break;
            default:
                _result.notImplemented();
        }
    }

    private void logIn() {
        _mSDk.unauthenticate();
        _codeVerifier = generateCodeVerifier();
        String codeChallenge = generateCodeChallenge(_codeVerifier);

        OAuthCompleteListener listener = new OAuthCompleteListener() {
            @Override
            public void onGetOAuthComplete(OauthResponse response) {
                _oauthCode = response.getOauthCode();
                _authenticated = _oauthCode != null && !_oauthCode.isEmpty();
                Map<String, Object> result = new HashMap<>();
                result.put("userId", String.valueOf(response.getuId()));
                result.put("oauthCode", response.getOauthCode());
                result.put("errorCode", response.getErrorCode());
                result.put("errorMessage", response.getErrorMessage());
                _result.success(result);
            }

            @Override
            public void onAuthenError(ErrorResponse errorResponse) {
                Map<String, Object> result = new HashMap<>();
                result.put("errorCode", errorResponse.getErrorCode());
                result.put("errorMessage", errorResponse.getErrorMsg());
                _result.success(result);
            }
        };

        _mSDk.authenticateZaloWithAuthenType(_activity, LoginVia.APP_OR_WEB, codeChallenge, listener);
    }

    private void getInfo() {
        final String[] fields = {"id", "birthday", "gender", "picture", "name"};

        // v4 requires an access token for the OpenAPI profile call. Exchange
        // the oauth code (+ verifier) first, then request the profile.
        Log.v(LOG_TAG, "getInfo: oauthCode=" + _oauthCode + " verifier=" + safeVerifier());
        _mSDk.getAccessTokenByOAuthCode(_context, _oauthCode, safeVerifier(), new ZaloOpenAPICallback() {
            @Override
            public void onResult(JSONObject tokenResponse) {
                Log.v(LOG_TAG, "getAccessTokenByOAuthCode -> " + tokenResponse);
                String accessToken = tokenResponse == null ? null : tokenResponse.optString("access_token", null);
                if (accessToken == null || accessToken.isEmpty()) {
                    _result.success("Get access token error");
                    return;
                }
                _mSDk.getProfile(_context, accessToken, new ZaloOpenAPICallback() {
                    @Override
                    public void onResult(JSONObject response) {
                        Log.v(LOG_TAG, "getProfile -> " + response);
                        try {
                            _result.success(jsonToMap(response));
                        } catch (JSONException e) {
                            _result.success("Get Info error");
                        }
                    }
                }, fields);
            }
        });
    }

    private static String safeVerifier() {
        return _codeVerifier == null ? "" : _codeVerifier;
    }

    // --- PKCE helpers (RFC 7636, S256) ---------------------------------------

    private static String generateCodeVerifier() {
        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        return Base64.encodeToString(bytes, Base64.URL_SAFE | Base64.NO_WRAP | Base64.NO_PADDING);
    }

    private static String generateCodeChallenge(String verifier) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(verifier.getBytes("US-ASCII"));
            return Base64.encodeToString(digest, Base64.URL_SAFE | Base64.NO_WRAP | Base64.NO_PADDING);
        } catch (Exception e) {
            return verifier;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (_channel != null) {
            _channel.setMethodCallHandler(null);
            _channel = null;
        }
    }

    @Override
    public void onDetachedFromActivity() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        _activity = binding.getActivity();
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
