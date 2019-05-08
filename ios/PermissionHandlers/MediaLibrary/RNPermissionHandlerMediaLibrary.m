#import "RNPermissionHandlerMediaLibrary.h"

@import MediaPlayer;

@implementation RNPermissionHandlerMediaLibrary

+ (NSString * _Nonnull)uniqueRequestingId {
  return @"media-library";
}

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSAppleMusicUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
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
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  [MPMediaLibrary requestAuthorization:^(__unused MPMediaLibraryAuthorizationStatus status) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
