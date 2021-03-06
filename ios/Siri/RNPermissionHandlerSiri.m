#import "RNPermissionHandlerSiri.h"

@import Intents;

@implementation RNPermissionHandlerSiri

+ (NSString * _Nonnull)handlerId {
  return @"siri";
}

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSSiriUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 10.0, *)) {
    switch ([INPreferences siriAuthorizationStatus]) {
      case INSiriAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case INSiriAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case INSiriAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
      case INSiriAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  if (@available(iOS 10.0, *)) {
    [INPreferences requestSiriAuthorization:^(__unused INSiriAuthorizationStatus status) {
      [self checkWithResolver:resolve rejecter:reject];
    }];
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

@end
