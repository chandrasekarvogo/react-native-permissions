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
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  [SKCloudServiceController requestAuthorization:^(__unused SKCloudServiceAuthorizationStatus status) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
