#import "RNPermissionHandlerMicrophone.h"

@import AVFoundation;

@implementation RNPermissionHandlerMicrophone

+ (NSString * _Nonnull)uniqueRequestingId {
  return @"microphone";
}

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSMicrophoneUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio]) {
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
  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(__unused BOOL granted) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
