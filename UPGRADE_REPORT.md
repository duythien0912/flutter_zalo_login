# flutter_zalo_login — Upgrade Report (v0.1.10 → v0.2.0)

**Date:** 2026-07-24
**Repo:** https://github.com/duythien0912/flutter_zalo_login
**Environment:** Flutter 3.41.5 · Dart 3.11.3 · Java 17 · macOS · Android emulator API 36 · Xcode (iOS device build)

---

## 1. Goal

1. Clone the plugin and read its docs.
2. Update everything to the latest versions (Android, iOS, Flutter, Dart, Gradle, SDKs).
3. Write an E2E test with **Maestro** (test phone **0981722293**).
4. Write this report and cut a new release.

---

## 2. Starting state (all badly out of date)

| Area | Was | Problem |
|------|-----|---------|
| Android Zalo SDK | `com.zing.zalo.zalosdk:*:2.5.0819` | Published on **jcenter — shut down**, unresolvable |
| Android Gradle Plugin | 3.5.0 | Incompatible with Java 17 / modern Flutter |
| Gradle | 5.6.2 | Too old for AGP 8 |
| compileSdk / minSdk | 28 / 18 | Below Play requirements |
| Repositories | `jcenter()` | Dead |
| AndroidManifest | `package="..."` attr | Removed in AGP 8 (needs `namespace`) |
| settings.gradle | legacy `.flutter-plugins` loop | Replaced by plugins DSL |
| iOS ZaloSDK | unversion-pinned, deployment 8.0/9.0 | Stale, fat-framework era |
| Dart / Flutter | `>=2.18.0` / `>=3.3.0` | Old constraints |

---

## 3. What was changed

### Android — toolchain
- `jcenter()` → `mavenCentral()` everywhere.
- AGP **3.5.0 → 8.7.0**, Gradle **5.6.2 → 8.9**, Java **17** source/target.
- compileSdk **28 → 35**, minSdk **18 → 21**, targetSdk **34**.
- `settings.gradle` rewritten to the modern `pluginManagement` + plugins-DSL template.
- Manifests: removed deprecated `package=` (moved to `namespace`), added
  `android:exported`, `NormalTheme`, and an Android-11 `<queries>` entry for the Zalo app.
- `FlutterApplication.java`: dropped the removed `io.flutter.view.FlutterMain` call.

### Android — Zalo SDK v2 → v4 (native rewrite)
- Dependency: **`me.zalo:sdk-core` / `sdk-auth` / `sdk-openapi:4.2.0724`** (latest on Maven Central).
- Rewrote `FlutterZaloLoginPlugin.java` for the v4 **OAuth PKCE** flow:
  - generate `code_verifier` (32 random bytes, base64url) + `code_challenge` (SHA-256, S256);
  - `authenticateZaloWithAuthenType(activity, LoginVia.APP_OR_WEB, codeChallenge, listener)`;
  - `OAuthCompleteListener` is now a class — `onAuthenError(ErrorResponse)` (was `(int,String)`);
  - `isAuthenticate(codeVerifier, ValidateCallback)` (new signature);
  - profile now needs a token: `getAccessTokenByOAuthCode(...)` → `getProfile(context, accessToken, cb, fields)`.

### iOS — ZaloSDK v4.1 (native rewrite)
- Podspec: `ZaloSDK ~> 4.1` (xcframework), deployment target **12.0**, dropped the
  `VALID_ARCHS` i386 hack, added `swift_version`.
- Example `Podfile` rewritten to the current Flutter template (`flutter_ios_podfile_setup`).
- `Info.plist`: added `LSApplicationQueriesSchemes` (`zalo`, `zalosdk`, `zaloshareext`).
- Rewrote `FlutterZaloLoginPlugin.m` for v4.1 PKCE:
  - `authenticateZaloWithAuthenType:parentController:codeChallenge:extInfo:handler:`;
  - `getAccessTokenWithOAuthCode:codeVerifier:completionHandler:` → `getZaloUserProfileWithAccessToken:callback:`;
  - PKCE `code_challenge` via CommonCrypto `CC_SHA256` + base64url;
  - `isAuthenticated` tracks local session state (SDK removed the standalone check).

### Dart
- SDK constraints: Dart **`>=3.4.0 <4.0.0`**, Flutter **`>=3.22.0`**.
- Fixed a bug in `ZaloLogin.getInfo()` that invoked the method channel twice.
- Plugin version **0.1.10 → 0.2.0**.

---

## 4. Build results

| Artifact | Result | Size |
|----------|--------|------|
| `flutter build apk --debug` | ✅ Built | 138 MB |
| `flutter build apk --release` | ✅ Built | 42 MB |
| `flutter build ios --no-codesign --release` | ✅ Built `Runner.app` | 15 MB |
| `flutter analyze` | ✅ No issues found | — |

Debug APK installed and launched on emulator (API 36). `init()` returned the
Android hash key `3CzfNVcggf4JEy7mbNfrFOVolsw=`, confirming the v4 native path works.

---

## 5. E2E test (Maestro) — phone 0981722293

Flow: `.maestro/zalo_login_flow.yaml` · Run result: **all steps COMPLETED** (`maestro test` exit 0).

Steps exercised:
1. Launch app (clear state).
2. `Init Zalo` → assert `hashKey:` shown.
3. `Is Authenticated` → assert `false` on fresh install.
4. `Login Zalo` → opens the real Zalo OAuth login.
5. Enter test phone **0981722293** on the Zalo login page.

**Proof the migration works end-to-end** — the native plugin generated a valid v4
PKCE OAuth request (captured from logcat):

```
https://oauth.zaloapp.com/v4/permission?app_id=2025844058438788512
  &sign_key=3CzfNVcggf4JEy7mbNfrFOVolsw%3D&os=1&sdk_ver=260801
  &code_challenge=V-3rIqCG3TnzzYPlK9Acdwse0xTlaWT_1zJ7Qg7HBVM
```

`/v4/permission` + `code_challenge` = PKCE code path confirmed. Login opened the real
Zalo web login (`id.zalo.me`, "…kết nối với ứng dụng zaa2"); the test phone
`+84 0981722293` was entered into the phone field (screenshot `06_phone_entered.png`).

Screenshots (evidence): `.maestro/screenshots/01_launch.png` … `08_final.png`.

### Limitation (as flagged before starting)
Full authentication **cannot complete unattended**:
- the emulator has no Zalo app installed (SDK falls back to web login);
- completing login needs the real account **password/OTP SMS** for 0981722293;
- the example is registered under the original author's Zalo `appID`, and this
  build's signing hash is not registered in that Zalo dashboard.

The flow therefore validates everything up to and including phone-number entry on
the genuine Zalo login page — the furthest an automated test can reach.

---

## 6. Release

- Version bumped to **0.2.0** (`pubspec.yaml`, podspec) with a full `CHANGELOG.md` entry.
- Build artifacts staged under `dist/` (per request — build artifacts, no push/tag):
  - `dist/app-release.apk`
  - `dist/app-debug.apk`
  - `dist/Runner.app.zip` (iOS, no-codesign)

---

## 7. Follow-ups / notes
- To make login actually succeed, register your own Zalo app at
  https://developers.zalo.me, put its `appID` in `example/android/.../res/values/string.xml`
  and iOS `Info.plist`, and register the printed Android hash key + iOS bundle id.
- AGP warns only softly below 8.6; we are on 8.7.0.
- The iOS half compiles and links against ZaloSDK 4.1 but Zalo login can't run on the
  iOS Simulator (needs a real device / the Zalo app), so it was verified by build only.
