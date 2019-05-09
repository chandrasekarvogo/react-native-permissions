#import "RNPermissionHandlerStoreKit.h"

@import StoreKit;

@implementation RNPermissionHandlerStoreKit

+ (NSString * _Nonnull)uniqueRequestingId {
  return @"storekit";
}

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 9.3, *)) {
    switch ([SKCloudServiceController authorizationStatus]) {
      case SKCloudServiceAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case SKCloudServiceAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case SKCloudServiceAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
      case SKCloudServiceAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  if (@available(iOS 9.3, *)) {
    [SKCloudServiceController requestAuthorization:^(__unused SKCloudServiceAuthorizationStatus status) {
      [self checkWithResolver:resolve rejecter:reject];
    }];
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

@end
