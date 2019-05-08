#import "RNPermissionHandlerSiri.h"

@import Intents;

@implementation RNPermissionHandlerSiri

+ (NSString * _Nonnull)uniqueRequestingId {
  return @"siri";
}

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSSiriUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
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
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  [INPreferences requestSiriAuthorization:^(__unused INSiriAuthorizationStatus status) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
