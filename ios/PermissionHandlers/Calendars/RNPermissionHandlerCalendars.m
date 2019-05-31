#import "RNPermissionHandlerCalendars.h"

@import EventKit;

@implementation RNPermissionHandlerCalendars

+ (NSString * _Nonnull)handlerId {
  return @"calendars";
}

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSCalendarsUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
    case EKAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case EKAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case EKAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case EKAuthorizationStatusAuthorized:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  [[EKEventStore new] requestAccessToEntityType:EKEntityTypeEvent completion:^(__unused BOOL granted, NSError * _Nullable error) {
    if (error != nil) {
      reject(error);
    } else {
      [self checkWithResolver:resolve rejecter:reject];
    }
  }];
}

@end
