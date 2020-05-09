#import "FlutterZaloLoginPlugin.h"
#import <ZaloSDK/ZaloSDK.h>

@implementation FlutterZaloLoginPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_zalo_login"
            binaryMessenger:[registrar messenger]];
  FlutterZaloLoginPlugin* instance = [[FlutterZaloLoginPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"init" isEqualToString:call.method]) {
        [self init:result];
    } else if ([@"logIn" isEqualToString:call.method]) {
        [self logIn:result];
    } else if ([@"isAuthenticated" isEqualToString:call.method]) {
        [self isAuthenticated:result];
    } else if ([@"logOut" isEqualToString:call.method]) {
        [self logOut:result];
    } else if ([@"getInfo" isEqualToString:call.method]) {
        [self getInfo:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)init:(FlutterResult)result {
        NSString *zaloAppID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ZaloAppID"];
        NSLog(@"%@", zaloAppID);
        [[ZaloSDK sharedInstance] initializeWithAppId:zaloAppID];
        result([NSNumber numberWithInt:1]);
}

- (void)logIn:(FlutterResult)result {
    @try {
        [[ZaloSDK sharedInstance] unauthenticate];
        UIViewController *rootViewController =
                [UIApplication sharedApplication].delegate.window.rootViewController;

        [[ZaloSDK sharedInstance] authenticateZaloWithAuthenType:ZAZAloSDKAuthenTypeViaZaloAppAndWebView
                                  parentController:rootViewController
                                  handler:^(ZOOauthResponseObject *response) {
                                    if ([response isSucess]) {
                                        NSString *errorCode = [NSString stringWithFormat:@"%ld", (long) response.errorCode];

                                        result(@{
                                            @"userId": response.userId ?: [NSNull null],
                                            @"oauthCode": response.oauthCode ?: [NSNull null],
                                            @"errorCode": [NSNumber numberWithInt:response.errorCode] ?: [NSNull null],
                                            @"errorMessage": response.errorMessage ?: [NSNull null],
                                            @"displayName": response.displayName ?: [NSNull null],
                                            @"dob": response.dob ?: [NSNull null],
                                            @"gender": response.gender ?: [NSNull null],
                                        });
                                    } else if (response.errorCode != kZaloSDKErrorCodeUserCancel) {
                                        NSString *errorCode = [NSString stringWithFormat:@"%ld", (long) response.errorCode];
                                        NSString *message = response.errorMessage;

                                        result(@{
                                            @"errorCode": errorCode ?: [NSNull null],
                                            @"errorMessage": message ?: [NSNull null],
                                        });
                                    }
                                  }];
    }
    @catch (NSException *exception) {
        NSLog(@"Login error");

        NSLog(@"%@", exception.reason);
        result([FlutterError errorWithCode:@"login zalo"
                                   message:exception.reason
                                   details:exception.reason]);
    }

}

- (void)isAuthenticated:(FlutterResult)result {
    [[ZaloSDK sharedInstance] isAuthenticatedZaloWithCompletionHandler:
     ^(ZOOauthResponseObject *response) {

        if(response.errorCode == kZaloSDKErrorCodeNoneError) {
            result([NSNumber numberWithInt:1]);
        } else {
            result([NSNumber numberWithInt:0]);
        }
    }];
}

- (void)logOut:(FlutterResult)result {
    [[ZaloSDK sharedInstance] unauthenticate];
    result([NSNumber numberWithInt:1]);
}

- (void)getInfo:(FlutterResult)result {
    [[ZaloSDK sharedInstance] getZaloUserProfileWithCallback:
                                ^(ZOGraphResponseObject *response) {
        @try {
            result(response.data);
        }
        @catch (NSException *exception) {
            NSLog(@"Login error");

            NSLog(@"%@", exception.reason);
            result([FlutterError errorWithCode:@"login zalo"
                                    message:exception.reason
                                    details:exception.reason]);
        }
    }];
}

@end
