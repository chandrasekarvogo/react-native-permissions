#import "RNPermissionHandlerMediaLibrary.h"

@import MediaPlayer;

@implementation RNPermissionHandlerMediaLibrary

+ (NSString * _Nonnull)handlerId {
  return @"media-library";
}

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSAppleMusicUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_SIMULATOR
  return resolve(RNPermissionStatusNotAvailable);
#else
  if (@available(iOS 9.3, *)) {
    switch ([MPMediaLibrary authorizationStatus]) {
      case MPMediaLibraryAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case MPMediaLibraryAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case MPMediaLibraryAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
      case MPMediaLibraryAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    resolve(RNPermissionStatusAuthorized);
  }
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  if (@available(iOS 9.3, *)) {
    [MPMediaLibrary requestAuthorization:^(__unused MPMediaLibraryAuthorizationStatus status) {
      [self checkWithResolver:resolve rejecter:reject];
    }];
  } else {
    resolve(RNPermissionStatusAuthorized);
  }
}

@end
