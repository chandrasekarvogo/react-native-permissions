#import "RNPermissionHandlerMediaLibrary.h"

@import MediaPlayer;

@implementation RNPermissionHandlerMediaLibrary

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSAppleMusicUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
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

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  [MPMediaLibrary requestAuthorization:^(__unused MPMediaLibraryAuthorizationStatus status) {
    [self checkWithResolver:resolve withRejecter:reject];
  }];
}

@end
