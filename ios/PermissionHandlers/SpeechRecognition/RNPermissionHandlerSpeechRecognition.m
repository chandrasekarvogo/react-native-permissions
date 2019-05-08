#import "RNPermissionHandlerSpeechRecognition.h"

@import Speech;

@implementation RNPermissionHandlerSpeechRecognition

+ (NSString * _Nonnull)uniqueRequestingId {
  return @"speech-recognition";
}

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSSpeechRecognitionUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([SFSpeechRecognizer authorizationStatus]) {
    case SFSpeechRecognizerAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case SFSpeechRecognizerAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case SFSpeechRecognizerAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case SFSpeechRecognizerAuthorizationStatusAuthorized:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  [SFSpeechRecognizer requestAuthorization:^(__unused SFSpeechRecognizerAuthorizationStatus status) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
