#import "FlutterZaloLoginPlugin.h"
#import <ZaloSDK/ZaloSDK.h>
#import <CommonCrypto/CommonCrypto.h>

@interface FlutterZaloLoginPlugin ()
// PKCE state kept between logIn and the later token exchange (getInfo).
@property(nonatomic, strong) NSString *codeVerifier;
@property(nonatomic, strong) NSString *oauthCode;
@property(nonatomic, assign) BOOL authenticated;
@end

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
        self.codeVerifier = [self randomCodeVerifier];
        NSString *codeChallenge = [self codeChallengeFromVerifier:self.codeVerifier];

        UIViewController *rootViewController =
                [UIApplication sharedApplication].delegate.window.rootViewController;

        // v4 uses the OAuth PKCE flow: pass a code_challenge; the returned
        // oauth code is later exchanged (with the verifier) for an access token.
        [[ZaloSDK sharedInstance] authenticateZaloWithAuthenType:ZAZAloSDKAuthenTypeViaZaloAppAndWebView
                                                parentController:rootViewController
                                                   codeChallenge:codeChallenge
                                                         extInfo:@{@"from_source": @"1"}
                                                         handler:^(ZOOauthResponseObject *response) {
            if ([response isSucess]) {
                self.oauthCode = response.oauthCode;
                self.authenticated = YES;
                result(@{
                    @"userId": response.userId ?: [NSNull null],
                    @"oauthCode": response.oauthCode ?: [NSNull null],
                    @"errorCode": [NSNumber numberWithInteger:response.errorCode],
                    @"errorMessage": response.errorMessage ?: [NSNull null],
                    @"displayName": response.displayName ?: [NSNull null],
                    @"dob": response.dob ?: [NSNull null],
                    @"gender": response.gender ?: [NSNull null],
                });
            } else if (response.errorCode != kZaloSDKErrorCodeUserCancel) {
                result(@{
                    @"errorCode": [NSNumber numberWithInteger:response.errorCode],
                    @"errorMessage": response.errorMessage ?: [NSNull null],
                });
            } else {
                result(@{
                    @"errorCode": [NSNumber numberWithInteger:response.errorCode],
                    @"errorMessage": @"User cancelled",
                });
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Login error: %@", exception.reason);
        result([FlutterError errorWithCode:@"login zalo"
                                   message:exception.reason
                                   details:exception.reason]);
    }
}

- (void)isAuthenticated:(FlutterResult)result {
    // v4 dropped the standalone isAuthenticated check; track local session state.
    result([NSNumber numberWithInt:self.authenticated ? 1 : 0]);
}

- (void)logOut:(FlutterResult)result {
    [[ZaloSDK sharedInstance] unauthenticate];
    self.authenticated = NO;
    self.oauthCode = nil;
    self.codeVerifier = nil;
    result([NSNumber numberWithInt:1]);
}

- (void)getInfo:(FlutterResult)result {
    // v4 requires an access token for the OpenAPI profile call. Exchange the
    // oauth code (+ verifier) first, then request the profile.
    [[ZaloSDK sharedInstance] getAccessTokenWithOAuthCode:self.oauthCode
                                             codeVerifier:(self.codeVerifier ?: @"")
                                        completionHandler:^(ZOTokenResponseObject *token) {
        NSString *accessToken = token.accessToken;
        if (accessToken == nil || accessToken.length == 0) {
            result([FlutterError errorWithCode:@"get_access_token"
                                       message:@"Cannot get access token"
                                       details:token.errorMessage]);
            return;
        }
        [[ZaloSDK sharedInstance] getZaloUserProfileWithAccessToken:accessToken
                                                           callback:^(ZOGraphResponseObject *response) {
            @try {
                result(response.data);
            }
            @catch (NSException *exception) {
                NSLog(@"Get profile error: %@", exception.reason);
                result([FlutterError errorWithCode:@"get_profile"
                                           message:exception.reason
                                           details:exception.reason]);
            }
        }];
    }];
}

#pragma mark - PKCE helpers (RFC 7636, S256)

- (NSString *)randomCodeVerifier {
    NSMutableData *data = [NSMutableData dataWithLength:32];
    SecRandomCopyBytes(kSecRandomDefault, 32, data.mutableBytes);
    return [self base64URLEncode:data];
}

- (NSString *)codeChallengeFromVerifier:(NSString *)verifier {
    NSData *verifierData = [verifier dataUsingEncoding:NSASCIIStringEncoding];
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(verifierData.bytes, (CC_LONG)verifierData.length, hash);
    NSData *hashData = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
    return [self base64URLEncode:hashData];
}

- (NSString *)base64URLEncode:(NSData *)data {
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
    return base64;
}

@end
