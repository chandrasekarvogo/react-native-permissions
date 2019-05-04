#import "RNPermissionHandlerSpeechRecognition.h"

@import Speech;

@implementation RNPermissionHandlerSpeechRecognition

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSSpeechRecognitionUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
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

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  [SFSpeechRecognizer requestAuthorization:^(__unused SFSpeechRecognizerAuthorizationStatus status) {
    [self checkWithResolver:resolve withRejecter:reject];
  }];
}

@end
