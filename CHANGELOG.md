## 0.2.0

* Migrate Android Zalo SDK from dead jcenter `com.zing.zalo.zalosdk:*:2.5.0819`
  to Maven Central `me.zalo:sdk-*:4.2.0724` (SDK v4).
* Rewrite Android native plugin for the v4 OAuth **PKCE** flow
  (`code_challenge` / `code_verifier`, access-token exchange before profile).
* Update iOS to `ZaloSDK ~> 4.1` (xcframework), deployment target 12.0.
* Modernize Android toolchain: AGP 8.5.2, Gradle 8.9, compileSdk 35,
  minSdk 21, Java 17, namespace, `jcenter()` → `mavenCentral()`,
  plugins-DSL `settings.gradle`.
* Modernize iOS example Podfile to the current Flutter template.
* Bump Dart SDK constraint to `>=3.4.0 <4.0.0`, Flutter `>=3.22.0`.
* Fix double method-channel invocation in `ZaloLogin.getInfo()`.
* Add Maestro E2E flow for the example app.

## 0.1.10

* [Thien] Update plugins from Dart 1 to Dart 3

## 0.1.9+1

* [Thien] Downgrade zalosdk version to `2.5.0819` because dev mode auto enable on ver `2.6`

## 0.1.9

* [Thien] Fix bug wrong type on iOS
* [Thien] Add code dart comment
* [Thien] Add TODO list

## 0.1.8

* [Thien] Fix bug ZaloSDK.Instance.authenticate not respones

## 0.1.7

* [Thien] Fix bug on android

## 0.1.6

* [Thien] Add kotlin code example

## 0.1.5

* [Thien] Fix android update format on pubspec

## 0.1.4

* [Thien] Update readme.md

## 0.1.3

* [Thien] Update readme.md

## 0.1.2

* [Thien] add auth code func update readme.md

## 0.1.1

* Fix login by app on IOS not return result.

## 0.1.0

* update description.

## 0.0.2

* setup example app.

## 0.0.1

* init.
