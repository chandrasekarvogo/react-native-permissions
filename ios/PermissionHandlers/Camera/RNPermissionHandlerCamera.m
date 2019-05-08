#import "RNPermissionHandlerCamera.h"

@import AVFoundation;

@implementation RNPermissionHandlerCamera

+ (NSString * _Nonnull)uniqueRequestingId {
  return @"camera";
}

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSCameraUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
    case AVAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case AVAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case AVAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case AVAuthorizationStatusAuthorized:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(__unused BOOL granted) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
